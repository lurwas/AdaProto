with Ada.Containers.Vectors;
with Ada.Streams;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Interfaces;

package body Protobuf is
   use Ada.Strings.Unbounded;
   use Interfaces;
   use type Ada.Streams.Stream_Element_Offset;

   function To_Signed_32 is new Ada.Unchecked_Conversion (Unsigned_32, Integer_32);
   function To_Unsigned_32 is new Ada.Unchecked_Conversion (Integer_32, Unsigned_32);
   function To_Signed_64 is new Ada.Unchecked_Conversion (Unsigned_64, Integer_64);
   function To_Unsigned_64 is new Ada.Unchecked_Conversion (Integer_64, Unsigned_64);
   function Bits_To_Float is new Ada.Unchecked_Conversion (Unsigned_32, Float32);
   function Float_To_Bits is new Ada.Unchecked_Conversion (Float32, Unsigned_32);
   function Bits_To_Double is new Ada.Unchecked_Conversion (Unsigned_64, Float64);
   function Double_To_Bits is new Ada.Unchecked_Conversion (Float64, Unsigned_64);

   package Int32_Vectors is new Ada.Containers.Vectors (Natural, Integer_32);
   package Int64_Vectors is new Ada.Containers.Vectors (Natural, Integer_64);
   package UInt32_Vectors is new Ada.Containers.Vectors (Natural, Unsigned_32);
   package UInt64_Vectors is new Ada.Containers.Vectors (Natural, Unsigned_64);
   package Bool_Vectors is new Ada.Containers.Vectors (Natural, Boolean);
   package Fixed32_Vectors is new Ada.Containers.Vectors (Natural, Unsigned_32);
   package Fixed64_Vectors is new Ada.Containers.Vectors (Natural, Unsigned_64);
   package SFixed32_Vectors is new Ada.Containers.Vectors (Natural, Integer_32);
   package SFixed64_Vectors is new Ada.Containers.Vectors (Natural, Integer_64);
   package Float_Vectors is new Ada.Containers.Vectors (Natural, Float32);
   package Double_Vectors is new Ada.Containers.Vectors (Natural, Float64);

   procedure Free is new Ada.Unchecked_Deallocation (String, Byte_Array_Access);

   Initial_Capacity : constant := 64;

   --  A 64-bit varint occupies at most ceil (64 / 7) = 10 bytes on the wire.
   Max_Varint_Bytes : constant := 10;

   --  Ensure Storage can hold at least Extra more bytes past Used, growing it
   --  geometrically so a run of appends costs amortized O(1) per byte. After a
   --  call, Storage (Buffer.Used + 1 .. Buffer.Used + Extra) may be written
   --  directly without any further bounds growth.
   procedure Reserve (Buffer : in out Message_Buffer; Extra : Natural) is
      Needed : constant Natural := Buffer.Used + Extra;
   begin
      if Buffer.Storage = null then
         Buffer.Storage := new String (1 .. Natural'Max (Initial_Capacity, Extra));
      elsif Needed > Buffer.Storage'Length then
         declare
            New_Capacity : Natural := Buffer.Storage'Length;
         begin
            loop
               New_Capacity := New_Capacity * 2;
               exit when New_Capacity >= Needed;
            end loop;
            declare
               Grown : constant Byte_Array_Access := new String (1 .. New_Capacity);
            begin
               Grown (1 .. Buffer.Used) := Buffer.Storage (1 .. Buffer.Used);
               Free (Buffer.Storage);
               Buffer.Storage := Grown;
            end;
         end;
      end if;
   end Reserve;

   --  Store a single byte that the caller has already reserved room for.
   procedure Put (Buffer : in out Message_Buffer; Value : Unsigned_8) with Inline is
   begin
      Buffer.Used := Buffer.Used + 1;
      Buffer.Storage (Buffer.Used) := Character'Val (Integer (Value));
   end Put;

   procedure Append_Byte (Buffer : in out Message_Buffer; Value : Unsigned_8) is
   begin
      Reserve (Buffer, 1);
      Put (Buffer, Value);
   end Append_Byte;

   --  The single growth point for appending a run of raw bytes (strings,
   --  pre-encoded packed payloads).
   procedure Append_Raw (Buffer : in out Message_Buffer; Value : String) is
   begin
      if Value'Length = 0 then
         return;
      end if;
      Reserve (Buffer, Value'Length);
      Buffer.Storage (Buffer.Used + 1 .. Buffer.Used + Value'Length) := Value;
      Buffer.Used := Buffer.Used + Value'Length;
   end Append_Raw;

   function Read_Byte (Data : String; Position : Positive) return Unsigned_8 is
   begin
      return Unsigned_8 (Character'Pos (Data (Position)));
   end Read_Byte;

   procedure Append_Varint (Buffer : in out Message_Buffer; Value : Unsigned_64) is
      Remaining : Unsigned_64 := Value;
   begin
      --  Reserve the worst case once, then store each byte without re-checking.
      Reserve (Buffer, Max_Varint_Bytes);
      loop
         declare
            Byte : constant Unsigned_8 := Unsigned_8 (Remaining and 16#7F#);
         begin
            Remaining := Shift_Right (Remaining, 7);
            if Remaining = 0 then
               Put (Buffer, Byte);
               exit;
            else
               Put (Buffer, Byte or 16#80#);
            end if;
         end;
      end loop;
   end Append_Varint;

   function Decode_Varint (Data : String; Cursor : in out Natural) return Unsigned_64 is
      Shift : Natural := 0;
      Value : Unsigned_64 := 0;
   begin
      while Cursor <= Data'Last loop
         declare
            Byte : constant Unsigned_8 := Read_Byte (Data, Cursor);
         begin
            Cursor := Cursor + 1;
            Value := Value or Shift_Left (Unsigned_64 (Byte and 16#7F#), Shift);
            if (Byte and 16#80#) = 0 then
               return Value;
            end if;
            Shift := Shift + 7;
            if Shift >= 64 then
               raise Parse_Error with "varint overflow";
            end if;
         end;
      end loop;
      raise Parse_Error with "truncated varint";
   end Decode_Varint;

   --  Write the low Width bytes of Value little-endian. Shared by every
   --  fixed32/fixed64-family encoder; reserves once, then stores directly.
   procedure Append_Little_Endian
     (Buffer : in out Message_Buffer;
      Value  : Unsigned_64;
      Width  : Positive)
   is
      Tmp : Unsigned_64 := Value;
   begin
      Reserve (Buffer, Width);
      for I in 1 .. Width loop
         Put (Buffer, Unsigned_8 (Tmp and 16#FF#));
         Tmp := Shift_Right (Tmp, 8);
      end loop;
   end Append_Little_Endian;

   procedure Append_Fixed32 (Buffer : in out Message_Buffer; Value : Unsigned_32) is
   begin
      Append_Little_Endian (Buffer, Unsigned_64 (Value), 4);
   end Append_Fixed32;

   procedure Append_Fixed64 (Buffer : in out Message_Buffer; Value : Unsigned_64) is
   begin
      Append_Little_Endian (Buffer, Value, 8);
   end Append_Fixed64;

   function Decode_Fixed32 (Data : String; Cursor : in out Natural) return Unsigned_32 is
      Value : Unsigned_32 := 0;
   begin
      if Cursor + 3 > Data'Last then
         raise Parse_Error with "truncated fixed32";
      end if;
      for I in 0 .. 3 loop
         Value := Value or Shift_Left (Unsigned_32 (Read_Byte (Data, Cursor + I)), 8 * I);
      end loop;
      Cursor := Cursor + 4;
      return Value;
   end Decode_Fixed32;

   function Decode_Fixed64 (Data : String; Cursor : in out Natural) return Unsigned_64 is
      Value : Unsigned_64 := 0;
   begin
      if Cursor + 7 > Data'Last then
         raise Parse_Error with "truncated fixed64";
      end if;
      for I in 0 .. 7 loop
         Value := Value or Shift_Left (Unsigned_64 (Read_Byte (Data, Cursor + I)), 8 * I);
      end loop;
      Cursor := Cursor + 8;
      return Value;
   end Decode_Fixed64;

   function Wire_Code (Kind : Wire_Type) return Unsigned_64 is
   begin
      case Kind is
         when Varint_Wire =>
            return 0;
         when Fixed64_Wire =>
            return 1;
         when Length_Delimited_Wire =>
            return 2;
         when Fixed32_Wire =>
            return 5;
      end case;
   end Wire_Code;

   procedure Append_Tag
     (Buffer : in out Message_Buffer;
      Number : Field_Number;
      Kind   : Wire_Type) is
      Tag : constant Unsigned_64 := Shift_Left (Unsigned_64 (Number), 3) or Wire_Code (Kind);
   begin
      Append_Varint (Buffer, Tag);
   end Append_Tag;

   function ZigZag_Encode_32 (Value : Integer_32) return Unsigned_32 is
      U : constant Unsigned_32 := To_Unsigned_32 (Value);
   begin
      return Shift_Left (U, 1) xor (0 - Shift_Right (U, 31));
   end ZigZag_Encode_32;

   function ZigZag_Decode_32 (Value : Unsigned_32) return Integer_32 is
      Sign : constant Unsigned_32 := 0 - (Value and 1);
   begin
      return To_Signed_32 (Shift_Right (Value, 1) xor Sign);
   end ZigZag_Decode_32;

   function ZigZag_Encode_64 (Value : Integer_64) return Unsigned_64 is
      U : constant Unsigned_64 := To_Unsigned_64 (Value);
   begin
      return Shift_Left (U, 1) xor (0 - Shift_Right (U, 63));
   end ZigZag_Encode_64;

   function ZigZag_Decode_64 (Value : Unsigned_64) return Integer_64 is
      Sign : constant Unsigned_64 := 0 - (Value and 1);
   begin
      return To_Signed_64 (Shift_Right (Value, 1) xor Sign);
   end ZigZag_Decode_64;

   procedure Clear (Buffer : in out Message_Buffer) is
   begin
      --  Keep Storage allocated so a reused buffer avoids re-growing.
      Buffer.Used := 0;
   end Clear;

   function To_String (Buffer : Message_Buffer) return String is
   begin
      if Buffer.Storage = null then
         return "";
      end if;
      return Buffer.Storage (1 .. Buffer.Used);
   end To_String;

   overriding procedure Finalize (Buffer : in out Message_Buffer) is
   begin
      Free (Buffer.Storage);
   end Finalize;

   function Serialize_To_String (Buffer : Message_Buffer) return String is
   begin
      return To_String (Buffer);
   end Serialize_To_String;

   procedure Write_To_Stream
     (Buffer : Message_Buffer;
      Stream : not null access Ada.Streams.Root_Stream_Type'Class) is
      Data : constant String := To_String (Buffer);
   begin
      if Data'Length = 0 then
         return;
      end if;

      declare
         Bytes : Ada.Streams.Stream_Element_Array
           (1 .. Ada.Streams.Stream_Element_Offset (Data'Length));
      begin
         for I in Data'Range loop
            Bytes (Ada.Streams.Stream_Element_Offset (I - Data'First + 1)) :=
              Ada.Streams.Stream_Element (Character'Pos (Data (I)));
         end loop;
         Ada.Streams.Write (Stream.all, Bytes);
      end;
   end Write_To_Stream;

   procedure Add_Int32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_32) is
   begin
      Append_Tag (Buffer, Number, Varint_Wire);
      Append_Varint (Buffer, To_Unsigned_64 (Integer_64 (Value)));
   end Add_Int32;

   procedure Add_Int64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_64) is
   begin
      Append_Tag (Buffer, Number, Varint_Wire);
      Append_Varint (Buffer, To_Unsigned_64 (Value));
   end Add_Int64;

   procedure Add_UInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Unsigned_32) is
   begin
      Append_Tag (Buffer, Number, Varint_Wire);
      Append_Varint (Buffer, Unsigned_64 (Value));
   end Add_UInt32;

   procedure Add_UInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Unsigned_64) is
   begin
      Append_Tag (Buffer, Number, Varint_Wire);
      Append_Varint (Buffer, Value);
   end Add_UInt64;

   procedure Add_SInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_32) is
   begin
      Append_Tag (Buffer, Number, Varint_Wire);
      Append_Varint (Buffer, Unsigned_64 (ZigZag_Encode_32 (Value)));
   end Add_SInt32;

   procedure Add_SInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_64) is
   begin
      Append_Tag (Buffer, Number, Varint_Wire);
      Append_Varint (Buffer, ZigZag_Encode_64 (Value));
   end Add_SInt64;

   procedure Add_Bool (Buffer : in out Message_Buffer; Number : Field_Number; Value : Boolean) is
   begin
      Append_Tag (Buffer, Number, Varint_Wire);
      if Value then
         Append_Byte (Buffer, 1);
      else
         Append_Byte (Buffer, 0);
      end if;
   end Add_Bool;

   procedure Add_Enum (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_32) is
   begin
      Add_Int32 (Buffer, Number, Value);
   end Add_Enum;

   procedure Add_Fixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Unsigned_32) is
   begin
      Append_Tag (Buffer, Number, Fixed32_Wire);
      Append_Fixed32 (Buffer, Value);
   end Add_Fixed32;

   procedure Add_Fixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Unsigned_64) is
   begin
      Append_Tag (Buffer, Number, Fixed64_Wire);
      Append_Fixed64 (Buffer, Value);
   end Add_Fixed64;

   procedure Add_SFixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_32) is
   begin
      Add_Fixed32 (Buffer, Number, To_Unsigned_32 (Value));
   end Add_SFixed32;

   procedure Add_SFixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_64) is
   begin
      Add_Fixed64 (Buffer, Number, To_Unsigned_64 (Value));
   end Add_SFixed64;

   procedure Add_Float (Buffer : in out Message_Buffer; Number : Field_Number; Value : Float32) is
   begin
      Add_Fixed32 (Buffer, Number, Float_To_Bits (Value));
   end Add_Float;

   procedure Add_Double (Buffer : in out Message_Buffer; Number : Field_Number; Value : Float64) is
   begin
      Add_Fixed64 (Buffer, Number, Double_To_Bits (Value));
   end Add_Double;

   procedure Add_String (Buffer : in out Message_Buffer; Number : Field_Number; Value : String) is
   begin
      Append_Tag (Buffer, Number, Length_Delimited_Wire);
      Append_Varint (Buffer, Unsigned_64 (Value'Length));
      Append_Raw (Buffer, Value);
   end Add_String;

   procedure Add_Bytes (Buffer : in out Message_Buffer; Number : Field_Number; Value : String) is
   begin
      Add_String (Buffer, Number, Value);
   end Add_Bytes;

   procedure Add_Message (Buffer : in out Message_Buffer; Number : Field_Number; Encoded_Message : String) is
   begin
      Add_Bytes (Buffer, Number, Encoded_Message);
   end Add_Message;

   procedure Add_Packed_Encoded
     (Buffer : in out Message_Buffer;
      Number : Field_Number;
      Payload : Message_Buffer) is
   begin
      --  Splice the already-encoded payload bytes in directly; no intermediate
      --  String copy is needed.
      Append_Tag (Buffer, Number, Length_Delimited_Wire);
      Append_Varint (Buffer, Unsigned_64 (Payload.Used));
      if Payload.Used > 0 then
         Append_Raw (Buffer, Payload.Storage (1 .. Payload.Used));
      end if;
   end Add_Packed_Encoded;

   procedure Add_Packed_Int32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int32_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Varint (Payload, To_Unsigned_64 (Integer_64 (V)));
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Int32;

   procedure Add_Packed_Int64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int64_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Varint (Payload, To_Unsigned_64 (V));
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Int64;

   procedure Add_Packed_UInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : UInt32_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Varint (Payload, Unsigned_64 (V));
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_UInt32;

   procedure Add_Packed_UInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : UInt64_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Varint (Payload, V);
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_UInt64;

   procedure Add_Packed_SInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int32_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Varint (Payload, Unsigned_64 (ZigZag_Encode_32 (V)));
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_SInt32;

   procedure Add_Packed_SInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int64_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Varint (Payload, ZigZag_Encode_64 (V));
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_SInt64;

   procedure Add_Packed_Bool (Buffer : in out Message_Buffer; Number : Field_Number; Values : Bool_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         if V then
            Append_Byte (Payload, 1);
         else
            Append_Byte (Payload, 0);
         end if;
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Bool;

   procedure Add_Packed_Enum (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int32_Array) is
   begin
      Add_Packed_Int32 (Buffer, Number, Values);
   end Add_Packed_Enum;

   procedure Add_Packed_Fixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Fixed32_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Fixed32 (Payload, V);
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Fixed32;

   procedure Add_Packed_Fixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Fixed64_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Fixed64 (Payload, V);
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Fixed64;

   procedure Add_Packed_SFixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : SFixed32_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Fixed32 (Payload, To_Unsigned_32 (V));
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_SFixed32;

   procedure Add_Packed_SFixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : SFixed64_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Fixed64 (Payload, To_Unsigned_64 (V));
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_SFixed64;

   procedure Add_Packed_Float (Buffer : in out Message_Buffer; Number : Field_Number; Values : Float_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Fixed32 (Payload, Float_To_Bits (V));
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Float;

   procedure Add_Packed_Double (Buffer : in out Message_Buffer; Number : Field_Number; Values : Double_Array) is
      Payload : Message_Buffer;
   begin
      for V of Values loop
         Append_Fixed64 (Payload, Double_To_Bits (V));
      end loop;
      Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Double;

   function Decode_Packed_Int32 (Bytes : String) return Int32_Array is
      Cursor : Natural := Bytes'First;
      Values : Int32_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (To_Signed_32 (Unsigned_32 (Decode_Varint (Bytes, Cursor) and 16#FFFF_FFFF#)));
      end loop;
      return Result : Int32_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Int32;

   function Decode_Packed_Int64 (Bytes : String) return Int64_Array is
      Cursor : Natural := Bytes'First;
      Values : Int64_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (To_Signed_64 (Decode_Varint (Bytes, Cursor)));
      end loop;
      return Result : Int64_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Int64;

   function Decode_Packed_UInt32 (Bytes : String) return UInt32_Array is
      Cursor : Natural := Bytes'First;
      Values : UInt32_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (Unsigned_32 (Decode_Varint (Bytes, Cursor) and 16#FFFF_FFFF#));
      end loop;
      return Result : UInt32_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_UInt32;

   function Decode_Packed_UInt64 (Bytes : String) return UInt64_Array is
      Cursor : Natural := Bytes'First;
      Values : UInt64_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (Decode_Varint (Bytes, Cursor));
      end loop;
      return Result : UInt64_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_UInt64;

   function Decode_Packed_SInt32 (Bytes : String) return Int32_Array is
      Cursor : Natural := Bytes'First;
      Values : Int32_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (ZigZag_Decode_32 (Unsigned_32 (Decode_Varint (Bytes, Cursor) and 16#FFFF_FFFF#)));
      end loop;
      return Result : Int32_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_SInt32;

   function Decode_Packed_SInt64 (Bytes : String) return Int64_Array is
      Cursor : Natural := Bytes'First;
      Values : Int64_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (ZigZag_Decode_64 (Decode_Varint (Bytes, Cursor)));
      end loop;
      return Result : Int64_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_SInt64;

   function Decode_Packed_Bool (Bytes : String) return Bool_Array is
      Cursor : Natural := Bytes'First;
      Values : Bool_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (Decode_Varint (Bytes, Cursor) /= 0);
      end loop;
      return Result : Bool_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Bool;

   function Decode_Packed_Fixed32 (Bytes : String) return Fixed32_Array is
      Cursor : Natural := Bytes'First;
      Values : Fixed32_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (Decode_Fixed32 (Bytes, Cursor));
      end loop;
      return Result : Fixed32_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Fixed32;

   function Decode_Packed_Fixed64 (Bytes : String) return Fixed64_Array is
      Cursor : Natural := Bytes'First;
      Values : Fixed64_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (Decode_Fixed64 (Bytes, Cursor));
      end loop;
      return Result : Fixed64_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Fixed64;

   function Decode_Packed_SFixed32 (Bytes : String) return SFixed32_Array is
      Cursor : Natural := Bytes'First;
      Values : SFixed32_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (To_Signed_32 (Decode_Fixed32 (Bytes, Cursor)));
      end loop;
      return Result : SFixed32_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_SFixed32;

   function Decode_Packed_SFixed64 (Bytes : String) return SFixed64_Array is
      Cursor : Natural := Bytes'First;
      Values : SFixed64_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (To_Signed_64 (Decode_Fixed64 (Bytes, Cursor)));
      end loop;
      return Result : SFixed64_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_SFixed64;

   function Decode_Packed_Float (Bytes : String) return Float_Array is
      Cursor : Natural := Bytes'First;
      Values : Float_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (Bits_To_Float (Decode_Fixed32 (Bytes, Cursor)));
      end loop;
      return Result : Float_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Float;

   function Decode_Packed_Double (Bytes : String) return Double_Array is
      Cursor : Natural := Bytes'First;
      Values : Double_Vectors.Vector;
   begin
      while Cursor <= Bytes'Last loop
         Values.Append (Bits_To_Double (Decode_Fixed64 (Bytes, Cursor)));
      end loop;
      return Result : Double_Array (1 .. Integer (Values.Length)) do
         for I in Result'Range loop
            Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Double;

   function Parse_From_String (Data : String) return Parsed_Field_Vectors.Vector is
      Result : Parsed_Field_Vectors.Vector;
      Cursor : Natural := Data'First;
   begin
      while Cursor <= Data'Last loop
         declare
            Tag : constant Unsigned_64 := Decode_Varint (Data, Cursor);
            Number : constant Unsigned_64 := Shift_Right (Tag, 3);
            Kind_Code : constant Unsigned_64 := Tag and 7;
         begin
            if Number = 0 or else Number > Unsigned_64 (Field_Number'Last) then
               raise Parse_Error with "invalid field number";
            end if;

            case Kind_Code is
               when 0 =>
                  Result.Append
                    (Parsed_Field'
                       (Kind => Varint_Wire,
                        Number => Field_Number (Number),
                        Varint_Value => Decode_Varint (Data, Cursor)));
               when 1 =>
                  Result.Append
                    (Parsed_Field'
                       (Kind => Fixed64_Wire,
                        Number => Field_Number (Number),
                        Fixed64_Value => Decode_Fixed64 (Data, Cursor)));
               when 2 =>
                  declare
                     Length : constant Unsigned_64 := Decode_Varint (Data, Cursor);
                     Last : Natural;
                  begin
                     if Length > Unsigned_64 (Natural'Last) then
                        raise Parse_Error with "length too large";
                     end if;
                     Last := Cursor + Natural (Length) - 1;
                     if Natural (Length) = 0 then
                        Result.Append
                          (Parsed_Field'
                             (Kind => Length_Delimited_Wire,
                              Number => Field_Number (Number),
                              Bytes_Value => To_Unbounded_String ("")));
                     else
                        if Last > Data'Last then
                           raise Parse_Error with "truncated length-delimited field";
                        end if;
                        Result.Append
                          (Parsed_Field'
                             (Kind => Length_Delimited_Wire,
                              Number => Field_Number (Number),
                              Bytes_Value => To_Unbounded_String (Data (Cursor .. Last))));
                        Cursor := Last + 1;
                     end if;
                  end;
               when 5 =>
                  Result.Append
                    (Parsed_Field'
                       (Kind => Fixed32_Wire,
                        Number => Field_Number (Number),
                        Fixed32_Value => Decode_Fixed32 (Data, Cursor)));
               when others =>
                  raise Parse_Error with "unsupported wire type";
            end case;
         end;
      end loop;
      return Result;
   end Parse_From_String;

   function Deserialize_From_String (Data : String) return Parsed_Field_Vectors.Vector is
   begin
      return Parse_From_String (Data);
   end Deserialize_From_String;

   function Parse_From_Stream
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Length : Natural) return Parsed_Field_Vectors.Vector is
   begin
      if Length = 0 then
         return Parse_From_String ("");
      end if;

      declare
         Bytes : Ada.Streams.Stream_Element_Array
           (1 .. Ada.Streams.Stream_Element_Offset (Length));
         Last  : Ada.Streams.Stream_Element_Offset := 0;
         Read_Up_To : Ada.Streams.Stream_Element_Offset := 0;
      begin
         while Read_Up_To < Bytes'Last loop
            Ada.Streams.Read
              (Stream.all,
               Bytes (Read_Up_To + 1 .. Bytes'Last),
               Last);
            if Last < Read_Up_To + 1 then
               raise Parse_Error with "truncated stream input";
            end if;
            Read_Up_To := Last;
         end loop;

         declare
            Data : String (1 .. Length);
         begin
            for I in Data'Range loop
               Data (I) :=
                 Character'Val
                   (Bytes (Ada.Streams.Stream_Element_Offset (I)));
            end loop;
            return Parse_From_String (Data);
         end;
      end;
   end Parse_From_Stream;

   function Check_Kind (Field : Parsed_Field; Expected : Wire_Type) return Parsed_Field is
   begin
      if Field.Kind /= Expected then
         raise Parse_Error with "wire type mismatch";
      end if;
      return Field;
   end Check_Kind;

   function As_Int32 (Field : Parsed_Field) return Integer_32 is
      F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      return To_Signed_32 (Unsigned_32 (F.Varint_Value and 16#FFFF_FFFF#));
   end As_Int32;

   function As_Int64 (Field : Parsed_Field) return Integer_64 is
      F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      return To_Signed_64 (F.Varint_Value);
   end As_Int64;

   function As_UInt32 (Field : Parsed_Field) return Unsigned_32 is
      F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      return Unsigned_32 (F.Varint_Value and 16#FFFF_FFFF#);
   end As_UInt32;

   function As_UInt64 (Field : Parsed_Field) return Unsigned_64 is
      F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      return F.Varint_Value;
   end As_UInt64;

   function As_SInt32 (Field : Parsed_Field) return Integer_32 is
      F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      return ZigZag_Decode_32 (Unsigned_32 (F.Varint_Value and 16#FFFF_FFFF#));
   end As_SInt32;

   function As_SInt64 (Field : Parsed_Field) return Integer_64 is
      F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      return ZigZag_Decode_64 (F.Varint_Value);
   end As_SInt64;

   function As_Bool (Field : Parsed_Field) return Boolean is
   begin
      return As_UInt64 (Field) /= 0;
   end As_Bool;

   function As_Enum (Field : Parsed_Field) return Integer_32 is
   begin
      return As_Int32 (Field);
   end As_Enum;

   function As_Fixed32 (Field : Parsed_Field) return Unsigned_32 is
      F : constant Parsed_Field := Check_Kind (Field, Fixed32_Wire);
   begin
      return F.Fixed32_Value;
   end As_Fixed32;

   function As_Fixed64 (Field : Parsed_Field) return Unsigned_64 is
      F : constant Parsed_Field := Check_Kind (Field, Fixed64_Wire);
   begin
      return F.Fixed64_Value;
   end As_Fixed64;

   function As_SFixed32 (Field : Parsed_Field) return Integer_32 is
   begin
      return To_Signed_32 (As_Fixed32 (Field));
   end As_SFixed32;

   function As_SFixed64 (Field : Parsed_Field) return Integer_64 is
   begin
      return To_Signed_64 (As_Fixed64 (Field));
   end As_SFixed64;

   function As_Float (Field : Parsed_Field) return Float32 is
   begin
      return Bits_To_Float (As_Fixed32 (Field));
   end As_Float;

   function As_Double (Field : Parsed_Field) return Float64 is
   begin
      return Bits_To_Double (As_Fixed64 (Field));
   end As_Double;

   function As_String (Field : Parsed_Field) return String is
      F : constant Parsed_Field := Check_Kind (Field, Length_Delimited_Wire);
   begin
      return To_String (F.Bytes_Value);
   end As_String;

   function As_Bytes (Field : Parsed_Field) return String is
   begin
      return As_String (Field);
   end As_Bytes;

   function As_Message_Bytes (Field : Parsed_Field) return String is
   begin
      return As_Bytes (Field);
   end As_Message_Bytes;

end Protobuf;
