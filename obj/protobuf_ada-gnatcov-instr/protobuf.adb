pragma Style_Checks (Off); pragma Warnings (Off);
with Ada.Containers.Vectors;
with Ada.Streams;
with Ada.Strings.Unbounded;
with Ada.Unchecked_Conversion;
with Interfaces;

with GNATcov_RTS.Buffers.PB_protobuf;package body Protobuf is
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

   procedure Append_Byte (Target : in out Unbounded_String; Value : Unsigned_8) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,0);Append (Target, Character'Val (Integer (Value)));
   end Append_Byte;

   function Read_Byte (Data : String; Position : Positive) return Unsigned_8 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,1);return Unsigned_8 (Character'Pos (Data (Position)));
   end Read_Byte;

   procedure Append_Varint (Target : in out Unbounded_String; Value : Unsigned_64) is
      Discard_UNIT_BODY2:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,2);Remaining : Unsigned_64 := Value;
   begin
      loop
         declare
            Discard_UNIT_BODY3:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,3);Byte : Unsigned_8 := Unsigned_8 (Remaining and 16#7F#);
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,4);Remaining := Shift_Right (Remaining, 7);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,5);if Remaining = 0 then
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,6);Append_Byte (Target, Byte);
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,7);exit;
            else
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,8);Append_Byte (Target, Byte or 16#80#);
            end if;
         end;
      end loop;
   end Append_Varint;

   function Decode_Varint (Data : String; Cursor : in out Natural) return Unsigned_64 is
      Discard_UNIT_BODY9:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,9);Shift : Natural := 0;
      Discard_UNIT_BODY10:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,10);Value : Unsigned_64 := 0;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,11);while Cursor <= Data'Last loop
         declare
            Discard_UNIT_BODY12:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,12);Byte : constant Unsigned_8 := Read_Byte (Data, Cursor);
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,13);Cursor := Cursor + 1;
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,14);Value := Value or Shift_Left (Unsigned_64 (Byte and 16#7F#), Shift);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,15);if (Byte and 16#80#) = 0 then
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,16);return Value;
            end if;
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,17);Shift := Shift + 7;
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,18);if Shift >= 64 then
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,19);raise Parse_Error with "varint overflow";
            end if;
         end;
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,20);raise Parse_Error with "truncated varint";
   end Decode_Varint;

   procedure Append_Fixed32 (Target : in out Unbounded_String; Value : Unsigned_32) is
      Discard_UNIT_BODY21:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,21);Tmp : Unsigned_32 := Value;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,22);for I in 1 .. 4 loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,23);Append_Byte (Target, Unsigned_8 (Tmp and 16#FF#));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,24);Tmp := Shift_Right (Tmp, 8);
      end loop;
   end Append_Fixed32;

   procedure Append_Fixed64 (Target : in out Unbounded_String; Value : Unsigned_64) is
      Discard_UNIT_BODY25:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,25);Tmp : Unsigned_64 := Value;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,26);for I in 1 .. 8 loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,27);Append_Byte (Target, Unsigned_8 (Tmp and 16#FF#));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,28);Tmp := Shift_Right (Tmp, 8);
      end loop;
   end Append_Fixed64;

   function Decode_Fixed32 (Data : String; Cursor : in out Natural) return Unsigned_32 is
      Discard_UNIT_BODY29:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,29);Value : Unsigned_32 := 0;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,30);if Cursor + 3 > Data'Last then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,31);raise Parse_Error with "truncated fixed32";
      end if;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,32);for I in 0 .. 3 loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,33);Value := Value or Shift_Left (Unsigned_32 (Read_Byte (Data, Cursor + I)), 8 * I);
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,34);Cursor := Cursor + 4;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,35);return Value;
   end Decode_Fixed32;

   function Decode_Fixed64 (Data : String; Cursor : in out Natural) return Unsigned_64 is
      Discard_UNIT_BODY36:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,36);Value : Unsigned_64 := 0;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,37);if Cursor + 7 > Data'Last then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,38);raise Parse_Error with "truncated fixed64";
      end if;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,39);for I in 0 .. 7 loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,40);Value := Value or Shift_Left (Unsigned_64 (Read_Byte (Data, Cursor + I)), 8 * I);
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,41);Cursor := Cursor + 8;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,42);return Value;
   end Decode_Fixed64;

   function Wire_Code (Kind : Wire_Type) return Unsigned_64 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,43);case Kind is
         when Varint_Wire =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,44);return 0;
         when Fixed64_Wire =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,45);return 1;
         when Length_Delimited_Wire =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,46);return 2;
         when Fixed32_Wire =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,47);return 5;
      end case;
   end Wire_Code;

   procedure Append_Tag
     (Target : in out Unbounded_String;
      Number : Field_Number;
      Kind   : Wire_Type) is
      Discard_UNIT_BODY48:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,48);Tag : constant Unsigned_64 := Shift_Left (Unsigned_64 (Number), 3) or Wire_Code (Kind);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,49);Append_Varint (Target, Tag);
   end Append_Tag;

   function ZigZag_Encode_32 (Value : Integer_32) return Unsigned_32 is
      Discard_UNIT_BODY50:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,50);U : constant Unsigned_32 := To_Unsigned_32 (Value);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,51);return Shift_Left (U, 1) xor (0 - Shift_Right (U, 31));
   end ZigZag_Encode_32;

   function ZigZag_Decode_32 (Value : Unsigned_32) return Integer_32 is
      Discard_UNIT_BODY52:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,52);Sign : constant Unsigned_32 := 0 - (Value and 1);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,53);return To_Signed_32 (Shift_Right (Value, 1) xor Sign);
   end ZigZag_Decode_32;

   function ZigZag_Encode_64 (Value : Integer_64) return Unsigned_64 is
      Discard_UNIT_BODY54:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,54);U : constant Unsigned_64 := To_Unsigned_64 (Value);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,55);return Shift_Left (U, 1) xor (0 - Shift_Right (U, 63));
   end ZigZag_Encode_64;

   function ZigZag_Decode_64 (Value : Unsigned_64) return Integer_64 is
      Discard_UNIT_BODY56:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,56);Sign : constant Unsigned_64 := 0 - (Value and 1);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,57);return To_Signed_64 (Shift_Right (Value, 1) xor Sign);
   end ZigZag_Decode_64;

   procedure Clear (Buffer : in out Message_Buffer) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,58);Buffer.Data := Null_Unbounded_String;
   end Clear;

   function To_String (Buffer : Message_Buffer) return String is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,59);return Ada.Strings.Unbounded.To_String (Buffer.Data);
   end To_String;

   function Serialize_To_String (Buffer : Message_Buffer) return String is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,60);return To_String (Buffer);
   end Serialize_To_String;

   procedure Write_To_Stream
     (Buffer : Message_Buffer;
      Stream : not null access Ada.Streams.Root_Stream_Type'Class) is
      Discard_UNIT_BODY61:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,61);Data : constant String := To_String (Buffer);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,62);if Data'Length = 0 then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,63);return;
      end if;

      declare
         Discard_UNIT_BODY64:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,64);Bytes : Ada.Streams.Stream_Element_Array
           (1 .. Ada.Streams.Stream_Element_Offset (Data'Length));
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,65);for I in Data'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,66);Bytes (Ada.Streams.Stream_Element_Offset (I - Data'First + 1)) :=
              Ada.Streams.Stream_Element (Character'Pos (Data (I)));
         end loop;
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,67);Ada.Streams.Write (Stream.all, Bytes);
      end;
   end Write_To_Stream;

   procedure Add_Int32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_32) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,68);Append_Tag (Buffer.Data, Number, Varint_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,69);Append_Varint (Buffer.Data, To_Unsigned_64 (Integer_64 (Value)));
   end Add_Int32;

   procedure Add_Int64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_64) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,70);Append_Tag (Buffer.Data, Number, Varint_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,71);Append_Varint (Buffer.Data, To_Unsigned_64 (Value));
   end Add_Int64;

   procedure Add_UInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Unsigned_32) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,72);Append_Tag (Buffer.Data, Number, Varint_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,73);Append_Varint (Buffer.Data, Unsigned_64 (Value));
   end Add_UInt32;

   procedure Add_UInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Unsigned_64) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,74);Append_Tag (Buffer.Data, Number, Varint_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,75);Append_Varint (Buffer.Data, Value);
   end Add_UInt64;

   procedure Add_SInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_32) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,76);Append_Tag (Buffer.Data, Number, Varint_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,77);Append_Varint (Buffer.Data, Unsigned_64 (ZigZag_Encode_32 (Value)));
   end Add_SInt32;

   procedure Add_SInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_64) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,78);Append_Tag (Buffer.Data, Number, Varint_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,79);Append_Varint (Buffer.Data, ZigZag_Encode_64 (Value));
   end Add_SInt64;

   procedure Add_Bool (Buffer : in out Message_Buffer; Number : Field_Number; Value : Boolean) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,80);Append_Tag (Buffer.Data, Number, Varint_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,81);if Value then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,82);Append_Byte (Buffer.Data, 1);
      else
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,83);Append_Byte (Buffer.Data, 0);
      end if;
   end Add_Bool;

   procedure Add_Enum (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_32) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,84);Add_Int32 (Buffer, Number, Value);
   end Add_Enum;

   procedure Add_Fixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Unsigned_32) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,85);Append_Tag (Buffer.Data, Number, Fixed32_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,86);Append_Fixed32 (Buffer.Data, Value);
   end Add_Fixed32;

   procedure Add_Fixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Unsigned_64) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,87);Append_Tag (Buffer.Data, Number, Fixed64_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,88);Append_Fixed64 (Buffer.Data, Value);
   end Add_Fixed64;

   procedure Add_SFixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_32) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,89);Add_Fixed32 (Buffer, Number, To_Unsigned_32 (Value));
   end Add_SFixed32;

   procedure Add_SFixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Integer_64) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,90);Add_Fixed64 (Buffer, Number, To_Unsigned_64 (Value));
   end Add_SFixed64;

   procedure Add_Float (Buffer : in out Message_Buffer; Number : Field_Number; Value : Float32) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,91);Add_Fixed32 (Buffer, Number, Float_To_Bits (Value));
   end Add_Float;

   procedure Add_Double (Buffer : in out Message_Buffer; Number : Field_Number; Value : Float64) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,92);Add_Fixed64 (Buffer, Number, Double_To_Bits (Value));
   end Add_Double;

   procedure Add_String (Buffer : in out Message_Buffer; Number : Field_Number; Value : String) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,93);Append_Tag (Buffer.Data, Number, Length_Delimited_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,94);Append_Varint (Buffer.Data, Unsigned_64 (Value'Length));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,95);Append (Buffer.Data, Value);
   end Add_String;

   procedure Add_Bytes (Buffer : in out Message_Buffer; Number : Field_Number; Value : String) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,96);Add_String (Buffer, Number, Value);
   end Add_Bytes;

   procedure Add_Message (Buffer : in out Message_Buffer; Number : Field_Number; Encoded_Message : String) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,97);Add_Bytes (Buffer, Number, Encoded_Message);
   end Add_Message;

   procedure Add_Packed_Encoded
     (Buffer : in out Message_Buffer;
      Number : Field_Number;
      Payload : Unbounded_String) is
      Discard_UNIT_BODY98:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,98);Encoded : constant String := To_String (Payload);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,99);Append_Tag (Buffer.Data, Number, Length_Delimited_Wire);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,100);Append_Varint (Buffer.Data, Unsigned_64 (Encoded'Length));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,101);Append (Buffer.Data, Encoded);
   end Add_Packed_Encoded;

   procedure Add_Packed_Int32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int32_Array) is
      Discard_UNIT_BODY102:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,102);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,103);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,104);Append_Varint (Payload, To_Unsigned_64 (Integer_64 (V)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,105);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Int32;

   procedure Add_Packed_Int64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int64_Array) is
      Discard_UNIT_BODY106:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,106);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,107);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,108);Append_Varint (Payload, To_Unsigned_64 (V));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,109);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Int64;

   procedure Add_Packed_UInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : UInt32_Array) is
      Discard_UNIT_BODY110:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,110);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,111);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,112);Append_Varint (Payload, Unsigned_64 (V));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,113);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_UInt32;

   procedure Add_Packed_UInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : UInt64_Array) is
      Discard_UNIT_BODY114:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,114);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,115);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,116);Append_Varint (Payload, V);
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,117);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_UInt64;

   procedure Add_Packed_SInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int32_Array) is
      Discard_UNIT_BODY118:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,118);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,119);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,120);Append_Varint (Payload, Unsigned_64 (ZigZag_Encode_32 (V)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,121);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_SInt32;

   procedure Add_Packed_SInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int64_Array) is
      Discard_UNIT_BODY122:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,122);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,123);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,124);Append_Varint (Payload, ZigZag_Encode_64 (V));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,125);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_SInt64;

   procedure Add_Packed_Bool (Buffer : in out Message_Buffer; Number : Field_Number; Values : Bool_Array) is
      Discard_UNIT_BODY126:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,126);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,127);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,128);if V then
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,129);Append_Byte (Payload, 1);
         else
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,130);Append_Byte (Payload, 0);
         end if;
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,131);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Bool;

   procedure Add_Packed_Enum (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int32_Array) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,132);Add_Packed_Int32 (Buffer, Number, Values);
   end Add_Packed_Enum;

   procedure Add_Packed_Fixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Fixed32_Array) is
      Discard_UNIT_BODY133:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,133);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,134);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,135);Append_Fixed32 (Payload, V);
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,136);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Fixed32;

   procedure Add_Packed_Fixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Fixed64_Array) is
      Discard_UNIT_BODY137:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,137);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,138);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,139);Append_Fixed64 (Payload, V);
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,140);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Fixed64;

   procedure Add_Packed_SFixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : SFixed32_Array) is
      Discard_UNIT_BODY141:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,141);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,142);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,143);Append_Fixed32 (Payload, To_Unsigned_32 (V));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,144);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_SFixed32;

   procedure Add_Packed_SFixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : SFixed64_Array) is
      Discard_UNIT_BODY145:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,145);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,146);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,147);Append_Fixed64 (Payload, To_Unsigned_64 (V));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,148);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_SFixed64;

   procedure Add_Packed_Float (Buffer : in out Message_Buffer; Number : Field_Number; Values : Float_Array) is
      Discard_UNIT_BODY149:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,149);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,150);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,151);Append_Fixed32 (Payload, Float_To_Bits (V));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,152);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Float;

   procedure Add_Packed_Double (Buffer : in out Message_Buffer; Number : Field_Number; Values : Double_Array) is
      Discard_UNIT_BODY153:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,153);Payload : Unbounded_String;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,154);for V of Values loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,155);Append_Fixed64 (Payload, Double_To_Bits (V));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,156);Add_Packed_Encoded (Buffer, Number, Payload);
   end Add_Packed_Double;

   function Decode_Packed_Int32 (Bytes : String) return Int32_Array is
      Discard_UNIT_BODY157:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,157);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY158:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,158);Values : Int32_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,159);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,160);Values.Append (To_Signed_32 (Unsigned_32 (Decode_Varint (Bytes, Cursor) and 16#FFFF_FFFF#)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,161);return Result : Int32_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,162);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,163);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Int32;

   function Decode_Packed_Int64 (Bytes : String) return Int64_Array is
      Discard_UNIT_BODY164:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,164);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY165:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,165);Values : Int64_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,166);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,167);Values.Append (To_Signed_64 (Decode_Varint (Bytes, Cursor)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,168);return Result : Int64_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,169);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,170);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Int64;

   function Decode_Packed_UInt32 (Bytes : String) return UInt32_Array is
      Discard_UNIT_BODY171:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,171);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY172:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,172);Values : UInt32_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,173);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,174);Values.Append (Unsigned_32 (Decode_Varint (Bytes, Cursor) and 16#FFFF_FFFF#));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,175);return Result : UInt32_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,176);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,177);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_UInt32;

   function Decode_Packed_UInt64 (Bytes : String) return UInt64_Array is
      Discard_UNIT_BODY178:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,178);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY179:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,179);Values : UInt64_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,180);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,181);Values.Append (Decode_Varint (Bytes, Cursor));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,182);return Result : UInt64_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,183);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,184);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_UInt64;

   function Decode_Packed_SInt32 (Bytes : String) return Int32_Array is
      Discard_UNIT_BODY185:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,185);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY186:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,186);Values : Int32_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,187);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,188);Values.Append (ZigZag_Decode_32 (Unsigned_32 (Decode_Varint (Bytes, Cursor) and 16#FFFF_FFFF#)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,189);return Result : Int32_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,190);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,191);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_SInt32;

   function Decode_Packed_SInt64 (Bytes : String) return Int64_Array is
      Discard_UNIT_BODY192:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,192);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY193:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,193);Values : Int64_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,194);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,195);Values.Append (ZigZag_Decode_64 (Decode_Varint (Bytes, Cursor)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,196);return Result : Int64_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,197);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,198);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_SInt64;

   function Decode_Packed_Bool (Bytes : String) return Bool_Array is
      Discard_UNIT_BODY199:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,199);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY200:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,200);Values : Bool_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,201);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,202);Values.Append (Decode_Varint (Bytes, Cursor) /= 0);
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,203);return Result : Bool_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,204);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,205);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Bool;

   function Decode_Packed_Fixed32 (Bytes : String) return Fixed32_Array is
      Discard_UNIT_BODY206:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,206);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY207:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,207);Values : Fixed32_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,208);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,209);Values.Append (Decode_Fixed32 (Bytes, Cursor));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,210);return Result : Fixed32_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,211);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,212);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Fixed32;

   function Decode_Packed_Fixed64 (Bytes : String) return Fixed64_Array is
      Discard_UNIT_BODY213:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,213);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY214:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,214);Values : Fixed64_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,215);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,216);Values.Append (Decode_Fixed64 (Bytes, Cursor));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,217);return Result : Fixed64_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,218);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,219);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Fixed64;

   function Decode_Packed_SFixed32 (Bytes : String) return SFixed32_Array is
      Discard_UNIT_BODY220:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,220);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY221:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,221);Values : SFixed32_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,222);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,223);Values.Append (To_Signed_32 (Decode_Fixed32 (Bytes, Cursor)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,224);return Result : SFixed32_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,225);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,226);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_SFixed32;

   function Decode_Packed_SFixed64 (Bytes : String) return SFixed64_Array is
      Discard_UNIT_BODY227:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,227);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY228:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,228);Values : SFixed64_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,229);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,230);Values.Append (To_Signed_64 (Decode_Fixed64 (Bytes, Cursor)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,231);return Result : SFixed64_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,232);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,233);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_SFixed64;

   function Decode_Packed_Float (Bytes : String) return Float_Array is
      Discard_UNIT_BODY234:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,234);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY235:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,235);Values : Float_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,236);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,237);Values.Append (Bits_To_Float (Decode_Fixed32 (Bytes, Cursor)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,238);return Result : Float_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,239);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,240);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Float;

   function Decode_Packed_Double (Bytes : String) return Double_Array is
      Discard_UNIT_BODY241:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,241);Cursor : Natural := Bytes'First;
      Discard_UNIT_BODY242:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,242);Values : Double_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,243);while Cursor <= Bytes'Last loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,244);Values.Append (Bits_To_Double (Decode_Fixed64 (Bytes, Cursor)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,245);return Result : Double_Array (1 .. Integer (Values.Length)) do
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,246);for I in Result'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,247);Result (I) := Values (Natural (I - Result'First));
         end loop;
      end return;
   end Decode_Packed_Double;

   function Parse_From_String (Data : String) return Parsed_Field_Vectors.Vector is
      Discard_UNIT_BODY248:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,248);Result : Parsed_Field_Vectors.Vector;
      Discard_UNIT_BODY249:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,249);Cursor : Natural := Data'First;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,250);while Cursor <= Data'Last loop
         declare
            Discard_UNIT_BODY251:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,251);Tag : constant Unsigned_64 := Decode_Varint (Data, Cursor);
            Discard_UNIT_BODY252:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,252);Number : constant Unsigned_64 := Shift_Right (Tag, 3);
            Discard_UNIT_BODY253:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,253);Kind_Code : constant Unsigned_64 := Tag and 7;
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,254);if Number = 0 or else Number > Unsigned_64 (Field_Number'Last) then
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,255);raise Parse_Error with "invalid field number";
            end if;

            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,256);case Kind_Code is
               when 0 =>
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,257);Result.Append
                    (Parsed_Field'
                       (Kind => Varint_Wire,
                        Number => Field_Number (Number),
                        Varint_Value => Decode_Varint (Data, Cursor)));
               when 1 =>
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,258);Result.Append
                    (Parsed_Field'
                       (Kind => Fixed64_Wire,
                        Number => Field_Number (Number),
                        Fixed64_Value => Decode_Fixed64 (Data, Cursor)));
               when 2 =>
                  declare
                     Discard_UNIT_BODY259:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,259);Length : constant Unsigned_64 := Decode_Varint (Data, Cursor);
                     Discard_UNIT_BODY260:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,260);Last : Natural;
                  begin
                     GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,261);if Length > Unsigned_64 (Natural'Last) then
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,262);raise Parse_Error with "length too large";
                     end if;
                     GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,263);Last := Cursor + Natural (Length) - 1;
                     GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,264);if Natural (Length) = 0 then
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,265);Result.Append
                          (Parsed_Field'
                             (Kind => Length_Delimited_Wire,
                              Number => Field_Number (Number),
                              Bytes_Value => To_Unbounded_String ("")));
                     else
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,266);if Last > Data'Last then
                           GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,267);raise Parse_Error with "truncated length-delimited field";
                        end if;
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,268);Result.Append
                          (Parsed_Field'
                             (Kind => Length_Delimited_Wire,
                              Number => Field_Number (Number),
                              Bytes_Value => To_Unbounded_String (Data (Cursor .. Last))));
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,269);Cursor := Last + 1;
                     end if;
                  end;
               when 5 =>
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,270);Result.Append
                    (Parsed_Field'
                       (Kind => Fixed32_Wire,
                        Number => Field_Number (Number),
                        Fixed32_Value => Decode_Fixed32 (Data, Cursor)));
               when others =>
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,271);raise Parse_Error with "unsupported wire type";
            end case;
         end;
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,272);return Result;
   end Parse_From_String;

   function Deserialize_From_String (Data : String) return Parsed_Field_Vectors.Vector is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,273);return Parse_From_String (Data);
   end Deserialize_From_String;

   function Parse_From_Stream
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Length : Natural) return Parsed_Field_Vectors.Vector is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,274);if Length = 0 then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,275);return Parse_From_String ("");
      end if;

      declare
         Discard_UNIT_BODY276:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,276);Bytes : Ada.Streams.Stream_Element_Array
           (1 .. Ada.Streams.Stream_Element_Offset (Length));
         Discard_UNIT_BODY277:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,277);Last  : Ada.Streams.Stream_Element_Offset := 0;
         Discard_UNIT_BODY278:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,278);Read_Up_To : Ada.Streams.Stream_Element_Offset := 0;
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,279);while Read_Up_To < Bytes'Last loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,280);Ada.Streams.Read
              (Stream.all,
               Bytes (Read_Up_To + 1 .. Bytes'Last),
               Last);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,281);if Last < Read_Up_To + 1 then
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,282);raise Parse_Error with "truncated stream input";
            end if;
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,283);Read_Up_To := Last;
         end loop;

         declare
            Discard_UNIT_BODY284:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,284);Data : String (1 .. Length);
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,285);for I in Data'Range loop
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,286);Data (I) :=
                 Character'Val
                   (Bytes (Ada.Streams.Stream_Element_Offset (I)));
            end loop;
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,287);return Parse_From_String (Data);
         end;
      end;
   end Parse_From_Stream;

   function Check_Kind (Field : Parsed_Field; Expected : Wire_Type) return Parsed_Field is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,288);if Field.Kind /= Expected then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,289);raise Parse_Error with "wire type mismatch";
      end if;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,290);return Field;
   end Check_Kind;

   function As_Int32 (Field : Parsed_Field) return Integer_32 is
      Discard_UNIT_BODY291:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,291);F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,292);return To_Signed_32 (Unsigned_32 (F.Varint_Value and 16#FFFF_FFFF#));
   end As_Int32;

   function As_Int64 (Field : Parsed_Field) return Integer_64 is
      Discard_UNIT_BODY293:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,293);F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,294);return To_Signed_64 (F.Varint_Value);
   end As_Int64;

   function As_UInt32 (Field : Parsed_Field) return Unsigned_32 is
      Discard_UNIT_BODY295:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,295);F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,296);return Unsigned_32 (F.Varint_Value and 16#FFFF_FFFF#);
   end As_UInt32;

   function As_UInt64 (Field : Parsed_Field) return Unsigned_64 is
      Discard_UNIT_BODY297:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,297);F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,298);return F.Varint_Value;
   end As_UInt64;

   function As_SInt32 (Field : Parsed_Field) return Integer_32 is
      Discard_UNIT_BODY299:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,299);F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,300);return ZigZag_Decode_32 (Unsigned_32 (F.Varint_Value and 16#FFFF_FFFF#));
   end As_SInt32;

   function As_SInt64 (Field : Parsed_Field) return Integer_64 is
      Discard_UNIT_BODY301:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,301);F : constant Parsed_Field := Check_Kind (Field, Varint_Wire);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,302);return ZigZag_Decode_64 (F.Varint_Value);
   end As_SInt64;

   function As_Bool (Field : Parsed_Field) return Boolean is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,303);return As_UInt64 (Field) /= 0;
   end As_Bool;

   function As_Enum (Field : Parsed_Field) return Integer_32 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,304);return As_Int32 (Field);
   end As_Enum;

   function As_Fixed32 (Field : Parsed_Field) return Unsigned_32 is
      Discard_UNIT_BODY305:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,305);F : constant Parsed_Field := Check_Kind (Field, Fixed32_Wire);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,306);return F.Fixed32_Value;
   end As_Fixed32;

   function As_Fixed64 (Field : Parsed_Field) return Unsigned_64 is
      Discard_UNIT_BODY307:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,307);F : constant Parsed_Field := Check_Kind (Field, Fixed64_Wire);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,308);return F.Fixed64_Value;
   end As_Fixed64;

   function As_SFixed32 (Field : Parsed_Field) return Integer_32 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,309);return To_Signed_32 (As_Fixed32 (Field));
   end As_SFixed32;

   function As_SFixed64 (Field : Parsed_Field) return Integer_64 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,310);return To_Signed_64 (As_Fixed64 (Field));
   end As_SFixed64;

   function As_Float (Field : Parsed_Field) return Float32 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,311);return Bits_To_Float (As_Fixed32 (Field));
   end As_Float;

   function As_Double (Field : Parsed_Field) return Float64 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,312);return Bits_To_Double (As_Fixed64 (Field));
   end As_Double;

   function As_String (Field : Parsed_Field) return String is
      Discard_UNIT_BODY313:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,313);F : constant Parsed_Field := Check_Kind (Field, Length_Delimited_Wire);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,314);return To_String (F.Bytes_Value);
   end As_String;

   function As_Bytes (Field : Parsed_Field) return String is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,315);return As_String (Field);
   end As_Bytes;

   function As_Message_Bytes (Field : Parsed_Field) return String is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf.Statement_Buffer,316);return As_Bytes (Field);
   end As_Message_Bytes;

end Protobuf;

