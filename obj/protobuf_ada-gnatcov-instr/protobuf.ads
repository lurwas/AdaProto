pragma Style_Checks (Off); pragma Warnings (Off);
with Ada.Containers.Vectors;
with Ada.Streams;
with Ada.Strings.Unbounded;
with Interfaces;

with GNATcov_RTS.Buffers.PS_protobuf;package Protobuf is
   pragma Preelaborate;

   Parse_Error : exception;
   Encode_Error : exception;

   subtype Field_Number is Positive range 1 .. 2 ** 29 - 1;

   type Wire_Type is
     (Varint_Wire,
      Fixed64_Wire,
      Length_Delimited_Wire,
      Fixed32_Wire);

   type Parsed_Field (Kind : Wire_Type := Varint_Wire) is record
      Number : Field_Number;
      case Kind is
         when Varint_Wire =>
            Varint_Value : Interfaces.Unsigned_64;
         when Fixed64_Wire =>
            Fixed64_Value : Interfaces.Unsigned_64;
         when Length_Delimited_Wire =>
            Bytes_Value : Ada.Strings.Unbounded.Unbounded_String;
         when Fixed32_Wire =>
            Fixed32_Value : Interfaces.Unsigned_32;
      end case;
   end record;

   package Parsed_Field_Vectors is new Ada.Containers.Vectors
     (Index_Type => Natural,
      Element_Type => Parsed_Field);

   type Message_Buffer is limited private;

   type Int32_Array is array (Positive range <>) of Interfaces.Integer_32;
   type Int64_Array is array (Positive range <>) of Interfaces.Integer_64;
   type UInt32_Array is array (Positive range <>) of Interfaces.Unsigned_32;
   type UInt64_Array is array (Positive range <>) of Interfaces.Unsigned_64;
   type Bool_Array is array (Positive range <>) of Boolean;
   type SFixed32_Array is array (Positive range <>) of Interfaces.Integer_32;
   type SFixed64_Array is array (Positive range <>) of Interfaces.Integer_64;
   type Fixed32_Array is array (Positive range <>) of Interfaces.Unsigned_32;
   type Fixed64_Array is array (Positive range <>) of Interfaces.Unsigned_64;
   subtype Float32 is Interfaces.IEEE_Float_32;
   subtype Float64 is Interfaces.IEEE_Float_64;

   type Float_Array is array (Positive range <>) of Float32;
   type Double_Array is array (Positive range <>) of Float64;

   ---------------------------------------------------------------------------------------
   -- Clears all encoded data in the target message buffer.
   -- Buffer: Message buffer to reset.
   ---------------------------------------------------------------------------------------
   procedure Clear (Buffer : in out Message_Buffer);

   ---------------------------------------------------------------------------------------
   -- Returns the encoded message bytes currently stored in Buffer.
   -- Buffer: Message buffer containing encoded data.
   ---------------------------------------------------------------------------------------
   function To_String (Buffer : Message_Buffer) return String;

   ---------------------------------------------------------------------------------------
   -- Returns the encoded message bytes currently stored in Buffer.
   -- This is an explicit serialization alias of To_String.
   -- Buffer: Message buffer containing encoded data.
   ---------------------------------------------------------------------------------------
   function Serialize_To_String (Buffer : Message_Buffer) return String;

   ---------------------------------------------------------------------------------------
   -- Writes the encoded message bytes in Buffer to Stream using buffered I/O.
   -- Buffer: Message buffer containing encoded data.
   -- Stream: Destination stream receiving encoded bytes.
   ---------------------------------------------------------------------------------------
   procedure Write_To_Stream
     (Buffer : Message_Buffer;
      Stream : not null access Ada.Streams.Root_Stream_Type'Class);

   ---------------------------------------------------------------------------------------
   -- Appends an int32 field encoded as protobuf varint.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: int32 field value.
   ---------------------------------------------------------------------------------------
   procedure Add_Int32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Integer_32);

   ---------------------------------------------------------------------------------------
   -- Appends an int64 field encoded as protobuf varint.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: int64 field value.
   ---------------------------------------------------------------------------------------
   procedure Add_Int64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Integer_64);

   ---------------------------------------------------------------------------------------
   -- Appends a uint32 field encoded as protobuf varint.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: uint32 field value.
   ---------------------------------------------------------------------------------------
   procedure Add_UInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Unsigned_32);

   ---------------------------------------------------------------------------------------
   -- Appends a uint64 field encoded as protobuf varint.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: uint64 field value.
   ---------------------------------------------------------------------------------------
   procedure Add_UInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Unsigned_64);

   ---------------------------------------------------------------------------------------
   -- Appends a sint32 field encoded with ZigZag + varint.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: sint32 field value.
   ---------------------------------------------------------------------------------------
   procedure Add_SInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Integer_32);

   ---------------------------------------------------------------------------------------
   -- Appends a sint64 field encoded with ZigZag + varint.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: sint64 field value.
   ---------------------------------------------------------------------------------------
   procedure Add_SInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Integer_64);

   ---------------------------------------------------------------------------------------
   -- Appends a bool field encoded as protobuf varint.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: Boolean field value.
   ---------------------------------------------------------------------------------------
   procedure Add_Bool (Buffer : in out Message_Buffer; Number : Field_Number; Value : Boolean);

   ---------------------------------------------------------------------------------------
   -- Appends an enum field encoded as protobuf varint.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: Enum numeric value.
   ---------------------------------------------------------------------------------------
   procedure Add_Enum (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Integer_32);

   ---------------------------------------------------------------------------------------
   -- Appends a fixed32 field encoded as 4 little-endian bytes.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: fixed32 field value.
   ---------------------------------------------------------------------------------------
   procedure Add_Fixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Unsigned_32);

   ---------------------------------------------------------------------------------------
   -- Appends a fixed64 field encoded as 8 little-endian bytes.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: fixed64 field value.
   ---------------------------------------------------------------------------------------
   procedure Add_Fixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Unsigned_64);

   ---------------------------------------------------------------------------------------
   -- Appends an sfixed32 field encoded as 4 little-endian bytes.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: sfixed32 field value.
   ---------------------------------------------------------------------------------------
   procedure Add_SFixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Integer_32);

   ---------------------------------------------------------------------------------------
   -- Appends an sfixed64 field encoded as 8 little-endian bytes.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: sfixed64 field value.
   ---------------------------------------------------------------------------------------
   procedure Add_SFixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Value : Interfaces.Integer_64);

   ---------------------------------------------------------------------------------------
   -- Appends a float field encoded as protobuf fixed32 bits.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: 32-bit IEEE float value.
   ---------------------------------------------------------------------------------------
   procedure Add_Float (Buffer : in out Message_Buffer; Number : Field_Number; Value : Float32);

   ---------------------------------------------------------------------------------------
   -- Appends a double field encoded as protobuf fixed64 bits.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: 64-bit IEEE float value.
   ---------------------------------------------------------------------------------------
   procedure Add_Double (Buffer : in out Message_Buffer; Number : Field_Number; Value : Float64);

   ---------------------------------------------------------------------------------------
   -- Appends a UTF-8 string field as length-delimited bytes.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: String field contents.
   ---------------------------------------------------------------------------------------
   procedure Add_String (Buffer : in out Message_Buffer; Number : Field_Number; Value : String);

   ---------------------------------------------------------------------------------------
   -- Appends a bytes field as length-delimited raw bytes.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Value: Raw bytes.
   ---------------------------------------------------------------------------------------
   procedure Add_Bytes (Buffer : in out Message_Buffer; Number : Field_Number; Value : String);

   ---------------------------------------------------------------------------------------
   -- Appends a nested message field from pre-encoded bytes.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Encoded_Message: Pre-encoded nested message bytes.
   ---------------------------------------------------------------------------------------
   procedure Add_Message (Buffer : in out Message_Buffer; Number : Field_Number; Encoded_Message : String);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated int32 values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of int32 values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_Int32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int32_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated int64 values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of int64 values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_Int64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int64_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated uint32 values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of uint32 values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_UInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : UInt32_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated uint64 values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of uint64 values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_UInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : UInt64_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated sint32 values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of sint32 values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_SInt32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int32_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated sint64 values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of sint64 values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_SInt64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int64_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated bool values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of bool values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_Bool (Buffer : in out Message_Buffer; Number : Field_Number; Values : Bool_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated enum values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of enum numeric values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_Enum (Buffer : in out Message_Buffer; Number : Field_Number; Values : Int32_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated fixed32 values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of fixed32 values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_Fixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Fixed32_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated fixed64 values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of fixed64 values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_Fixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : Fixed64_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated sfixed32 values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of sfixed32 values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_SFixed32 (Buffer : in out Message_Buffer; Number : Field_Number; Values : SFixed32_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated sfixed64 values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of sfixed64 values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_SFixed64 (Buffer : in out Message_Buffer; Number : Field_Number; Values : SFixed64_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated float values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of float values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_Float (Buffer : in out Message_Buffer; Number : Field_Number; Values : Float_Array);

   ---------------------------------------------------------------------------------------
   -- Appends packed repeated double values.
   -- Buffer: Message buffer to append into.
   -- Number: Protobuf field number.
   -- Values: Collection of double values.
   ---------------------------------------------------------------------------------------
   procedure Add_Packed_Double (Buffer : in out Message_Buffer; Number : Field_Number; Values : Double_Array);

   ---------------------------------------------------------------------------------------
   -- Decodes packed int32 payload bytes into int32 values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_Int32 (Bytes : String) return Int32_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed int64 payload bytes into int64 values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_Int64 (Bytes : String) return Int64_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed uint32 payload bytes into uint32 values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_UInt32 (Bytes : String) return UInt32_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed uint64 payload bytes into uint64 values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_UInt64 (Bytes : String) return UInt64_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed sint32 payload bytes into sint32 values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_SInt32 (Bytes : String) return Int32_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed sint64 payload bytes into sint64 values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_SInt64 (Bytes : String) return Int64_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed bool payload bytes into bool values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_Bool (Bytes : String) return Bool_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed fixed32 payload bytes into fixed32 values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_Fixed32 (Bytes : String) return Fixed32_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed fixed64 payload bytes into fixed64 values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_Fixed64 (Bytes : String) return Fixed64_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed sfixed32 payload bytes into sfixed32 values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_SFixed32 (Bytes : String) return SFixed32_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed sfixed64 payload bytes into sfixed64 values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_SFixed64 (Bytes : String) return SFixed64_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed float payload bytes into float values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_Float (Bytes : String) return Float_Array;

   ---------------------------------------------------------------------------------------
   -- Decodes packed double payload bytes into double values.
   -- Bytes: Packed payload bytes (length-delimited field contents only).
   ---------------------------------------------------------------------------------------
   function Decode_Packed_Double (Bytes : String) return Double_Array;

   ---------------------------------------------------------------------------------------
   -- Parses encoded protobuf data from a String into raw parsed fields.
   -- Data: Encoded protobuf bytes.
   ---------------------------------------------------------------------------------------
   function Parse_From_String (Data : String) return Parsed_Field_Vectors.Vector;

   ---------------------------------------------------------------------------------------
   -- Parses encoded protobuf data from a String into raw parsed fields.
   -- This is an explicit deserialization alias of Parse_From_String.
   -- Data: Encoded protobuf bytes.
   ---------------------------------------------------------------------------------------
   function Deserialize_From_String (Data : String) return Parsed_Field_Vectors.Vector;

   ---------------------------------------------------------------------------------------
   -- Parses encoded protobuf data from a Stream into raw parsed fields.
   -- Stream: Source stream containing protobuf bytes.
   -- Length: Number of bytes to read from Stream.
   ---------------------------------------------------------------------------------------
   function Parse_From_Stream
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Length : Natural) return Parsed_Field_Vectors.Vector;

   ---------------------------------------------------------------------------------------
   -- Converts a varint field to int32.
   -- Field: Parsed field with varint wire type.
   ---------------------------------------------------------------------------------------
   function As_Int32 (Field : Parsed_Field) return Interfaces.Integer_32;

   ---------------------------------------------------------------------------------------
   -- Converts a varint field to int64.
   -- Field: Parsed field with varint wire type.
   ---------------------------------------------------------------------------------------
   function As_Int64 (Field : Parsed_Field) return Interfaces.Integer_64;

   ---------------------------------------------------------------------------------------
   -- Converts a varint field to uint32.
   -- Field: Parsed field with varint wire type.
   ---------------------------------------------------------------------------------------
   function As_UInt32 (Field : Parsed_Field) return Interfaces.Unsigned_32;

   ---------------------------------------------------------------------------------------
   -- Converts a varint field to uint64.
   -- Field: Parsed field with varint wire type.
   ---------------------------------------------------------------------------------------
   function As_UInt64 (Field : Parsed_Field) return Interfaces.Unsigned_64;

   ---------------------------------------------------------------------------------------
   -- Converts a ZigZag varint field to sint32.
   -- Field: Parsed field with varint wire type.
   ---------------------------------------------------------------------------------------
   function As_SInt32 (Field : Parsed_Field) return Interfaces.Integer_32;

   ---------------------------------------------------------------------------------------
   -- Converts a ZigZag varint field to sint64.
   -- Field: Parsed field with varint wire type.
   ---------------------------------------------------------------------------------------
   function As_SInt64 (Field : Parsed_Field) return Interfaces.Integer_64;

   ---------------------------------------------------------------------------------------
   -- Converts a varint field to bool.
   -- Field: Parsed field with varint wire type.
   ---------------------------------------------------------------------------------------
   function As_Bool (Field : Parsed_Field) return Boolean;

   ---------------------------------------------------------------------------------------
   -- Converts a varint field to enum numeric value.
   -- Field: Parsed field with varint wire type.
   ---------------------------------------------------------------------------------------
   function As_Enum (Field : Parsed_Field) return Interfaces.Integer_32;

   ---------------------------------------------------------------------------------------
   -- Converts a fixed32 field to unsigned 32-bit value.
   -- Field: Parsed field with fixed32 wire type.
   ---------------------------------------------------------------------------------------
   function As_Fixed32 (Field : Parsed_Field) return Interfaces.Unsigned_32;

   ---------------------------------------------------------------------------------------
   -- Converts a fixed64 field to unsigned 64-bit value.
   -- Field: Parsed field with fixed64 wire type.
   ---------------------------------------------------------------------------------------
   function As_Fixed64 (Field : Parsed_Field) return Interfaces.Unsigned_64;

   ---------------------------------------------------------------------------------------
   -- Converts a fixed32 field to signed 32-bit value.
   -- Field: Parsed field with fixed32 wire type.
   ---------------------------------------------------------------------------------------
   function As_SFixed32 (Field : Parsed_Field) return Interfaces.Integer_32;

   ---------------------------------------------------------------------------------------
   -- Converts a fixed64 field to signed 64-bit value.
   -- Field: Parsed field with fixed64 wire type.
   ---------------------------------------------------------------------------------------
   function As_SFixed64 (Field : Parsed_Field) return Interfaces.Integer_64;

   ---------------------------------------------------------------------------------------
   -- Converts a fixed32 field to IEEE float value.
   -- Field: Parsed field with fixed32 wire type.
   ---------------------------------------------------------------------------------------
   function As_Float (Field : Parsed_Field) return Float32;

   ---------------------------------------------------------------------------------------
   -- Converts a fixed64 field to IEEE double value.
   -- Field: Parsed field with fixed64 wire type.
   ---------------------------------------------------------------------------------------
   function As_Double (Field : Parsed_Field) return Float64;

   ---------------------------------------------------------------------------------------
   -- Converts a length-delimited field to String.
   -- Field: Parsed field with length-delimited wire type.
   ---------------------------------------------------------------------------------------
   function As_String (Field : Parsed_Field) return String;

   ---------------------------------------------------------------------------------------
   -- Converts a length-delimited field to raw bytes.
   -- Field: Parsed field with length-delimited wire type.
   ---------------------------------------------------------------------------------------
   function As_Bytes (Field : Parsed_Field) return String;

   ---------------------------------------------------------------------------------------
   -- Returns a length-delimited nested-message payload as raw bytes.
   -- Field: Parsed field with length-delimited wire type.
   ---------------------------------------------------------------------------------------
   function As_Message_Bytes (Field : Parsed_Field) return String;

private
   type Message_Buffer is limited record
      Data : Ada.Strings.Unbounded.Unbounded_String;
   end record;
end Protobuf;

