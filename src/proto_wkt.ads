with Interfaces;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;
with JSON;

--  Well-known types (google.protobuf.*) as Ada records with their binary wire
--  (de)serialization and their special proto3-JSON forms.
--
--  This phase covers Empty and the nine scalar wrapper types. Each wrapper is,
--  on the wire, a message with a single `value` field (number 1); in JSON it is
--  rendered as the bare wrapped value (e.g. Int32Value{5} <-> JSON 5), not an
--  object. A wrapper present with its default value serializes to empty bytes,
--  which is how it stays distinct from an absent field (presence is carried by
--  the enclosing optional/holder, as for any message field).
package Proto_WKT is

   package U renames Ada.Strings.Unbounded;

   ---------------------------------------------------------------------------
   --  google.protobuf.Empty
   ---------------------------------------------------------------------------

   type Empty is null record;

   function Serialize (X : Empty) return String;
   function Parse_Empty (Data : String) return Empty;
   function To_JSON (X : Empty) return JSON.JSON_Value;
   function From_JSON (V : JSON.JSON_Value) return Empty;

   ---------------------------------------------------------------------------
   --  Scalar wrapper types
   ---------------------------------------------------------------------------

   type Double_Value is record Value : Interfaces.IEEE_Float_64 := 0.0; end record;
   type Float_Value  is record Value : Interfaces.IEEE_Float_32 := 0.0; end record;
   type Int64_Value  is record Value : Interfaces.Integer_64 := 0; end record;
   type UInt64_Value is record Value : Interfaces.Unsigned_64 := 0; end record;
   type Int32_Value  is record Value : Interfaces.Integer_32 := 0; end record;
   type UInt32_Value is record Value : Interfaces.Unsigned_32 := 0; end record;
   type Bool_Value   is record Value : Boolean := False; end record;
   type String_Value is record Value : U.Unbounded_String; end record;
   type Bytes_Value  is record Value : U.Unbounded_String; end record;

   function Serialize (X : Double_Value) return String;
   function Serialize (X : Float_Value) return String;
   function Serialize (X : Int64_Value) return String;
   function Serialize (X : UInt64_Value) return String;
   function Serialize (X : Int32_Value) return String;
   function Serialize (X : UInt32_Value) return String;
   function Serialize (X : Bool_Value) return String;
   function Serialize (X : String_Value) return String;
   function Serialize (X : Bytes_Value) return String;

   function Parse_Double_Value (Data : String) return Double_Value;
   function Parse_Float_Value (Data : String) return Float_Value;
   function Parse_Int64_Value (Data : String) return Int64_Value;
   function Parse_UInt64_Value (Data : String) return UInt64_Value;
   function Parse_Int32_Value (Data : String) return Int32_Value;
   function Parse_UInt32_Value (Data : String) return UInt32_Value;
   function Parse_Bool_Value (Data : String) return Bool_Value;
   function Parse_String_Value (Data : String) return String_Value;
   function Parse_Bytes_Value (Data : String) return Bytes_Value;

   function To_JSON (X : Double_Value) return JSON.JSON_Value;
   function To_JSON (X : Float_Value) return JSON.JSON_Value;
   function To_JSON (X : Int64_Value) return JSON.JSON_Value;
   function To_JSON (X : UInt64_Value) return JSON.JSON_Value;
   function To_JSON (X : Int32_Value) return JSON.JSON_Value;
   function To_JSON (X : UInt32_Value) return JSON.JSON_Value;
   function To_JSON (X : Bool_Value) return JSON.JSON_Value;
   function To_JSON (X : String_Value) return JSON.JSON_Value;
   function To_JSON (X : Bytes_Value) return JSON.JSON_Value;

   function From_JSON (V : JSON.JSON_Value) return Double_Value;
   function From_JSON (V : JSON.JSON_Value) return Float_Value;
   function From_JSON (V : JSON.JSON_Value) return Int64_Value;
   function From_JSON (V : JSON.JSON_Value) return UInt64_Value;
   function From_JSON (V : JSON.JSON_Value) return Int32_Value;
   function From_JSON (V : JSON.JSON_Value) return UInt32_Value;
   function From_JSON (V : JSON.JSON_Value) return Bool_Value;
   function From_JSON (V : JSON.JSON_Value) return String_Value;
   function From_JSON (V : JSON.JSON_Value) return Bytes_Value;

   ---------------------------------------------------------------------------
   --  Duration and Timestamp ({ seconds:int64=1, nanos:int32=2 } on the wire)
   --  JSON: Duration is "<secs>[.<frac>]s"; Timestamp is an RFC 3339 UTC string.
   ---------------------------------------------------------------------------

   type Duration is record
      Seconds : Interfaces.Integer_64 := 0;
      Nanos   : Interfaces.Integer_32 := 0;
   end record;

   type Timestamp is record
      Seconds : Interfaces.Integer_64 := 0;   --  since 1970-01-01T00:00:00Z
      Nanos   : Interfaces.Integer_32 := 0;
   end record;

   function Serialize (X : Duration) return String;
   function Parse_Duration (Data : String) return Duration;
   function To_JSON (X : Duration) return JSON.JSON_Value;
   function From_JSON (V : JSON.JSON_Value) return Duration;

   function Serialize (X : Timestamp) return String;
   function Parse_Timestamp (Data : String) return Timestamp;
   function To_JSON (X : Timestamp) return JSON.JSON_Value;
   function From_JSON (V : JSON.JSON_Value) return Timestamp;

   ---------------------------------------------------------------------------
   --  FieldMask (repeated string paths=1). JSON is one comma-joined string of
   --  the paths with each path's segments rendered in lowerCamelCase.
   ---------------------------------------------------------------------------

   use type U.Unbounded_String;
   package Path_Vectors is new Ada.Containers.Vectors (Positive, U.Unbounded_String);

   type Field_Mask is record
      Paths : Path_Vectors.Vector;
   end record;

   function Serialize (X : Field_Mask) return String;
   function Parse_Field_Mask (Data : String) return Field_Mask;
   function To_JSON (X : Field_Mask) return JSON.JSON_Value;
   function From_JSON (V : JSON.JSON_Value) return Field_Mask;

   ---------------------------------------------------------------------------
   --  Struct / Value / ListValue -- dynamic, recursive JSON-shaped values.
   --  Backed by the JSON DOM directly (JSON conversion is pass-through); the
   --  binary form is the google.protobuf.Value/Struct/ListValue wire encoding.
   ---------------------------------------------------------------------------

   type Value      is record Val : JSON.JSON_Value; end record;   --  any JSON
   type Struct     is record Val : JSON.JSON_Value; end record;   --  a JSON object
   type List_Value is record Val : JSON.JSON_Value; end record;   --  a JSON array

   function Serialize (X : Value) return String;
   function Serialize (X : Struct) return String;
   function Serialize (X : List_Value) return String;

   function Parse_Value (Data : String) return Value;
   function Parse_Struct (Data : String) return Struct;
   function Parse_List_Value (Data : String) return List_Value;

   function To_JSON (X : Value) return JSON.JSON_Value;
   function To_JSON (X : Struct) return JSON.JSON_Value;
   function To_JSON (X : List_Value) return JSON.JSON_Value;

   function From_JSON (V : JSON.JSON_Value) return Value;
   function From_JSON (V : JSON.JSON_Value) return Struct;
   function From_JSON (V : JSON.JSON_Value) return List_Value;

end Proto_WKT;

