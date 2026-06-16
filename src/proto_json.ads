with Interfaces;
with JSON;

--  Runtime helpers shared by protoc-ada-generated To_JSON / From_JSON code,
--  implementing the parts of the proto3 <-> JSON mapping that need real logic
--  (64-bit integers as strings, float special values, base64 bytes).
package Proto_JSON is

   --  Decimal text, no leading space, for use as a JSON number or string.
   function Image (V : Interfaces.Integer_64) return String;
   function Image (V : Interfaces.Unsigned_64) return String;

   --  proto3 JSON renders float/double as a number, except the non-finite
   --  values which become the strings "NaN", "Infinity", "-Infinity".
   function Float_To_JSON (V : Interfaces.IEEE_Float_32) return JSON.JSON_Value;
   function Double_To_JSON (V : Interfaces.IEEE_Float_64) return JSON.JSON_Value;

   --  bytes <-> standard base64 (the proto3 JSON representation of `bytes`).
   function To_Base64 (S : String) return String;
   function From_Base64 (S : String) return String;

   --  proto3 requires `string` fields to be well-formed UTF-8. Checked_UTF8
   --  returns S unchanged, or raises Decode_Error if it is not valid UTF-8.
   function Is_Valid_UTF8 (S : String) return Boolean;
   function Checked_UTF8 (S : String) return String;

   --  Parsing helpers for generated From_JSON code. The numeric text of a JSON
   --  value (proto3 JSON accepts numbers either bare or quoted as strings).
   function Scalar_Text (V : JSON.JSON_Value) return String;

   --  The value of a JSON string, or Decode_Error if V is not a JSON string.
   --  proto3 requires `string` and `bytes` fields to be JSON strings (a bare
   --  number or bool for such a field is a parse error).
   function Checked_String (V : JSON.JSON_Value) return String;

   --  Strict proto3 JSON integer parsing. The text must be a base-10 integer
   --  (optionally signed, no leading '+', no leading zeros except a lone "0",
   --  no surrounding whitespace) or an integer-VALUED decimal/exponent form
   --  (e.g. "10.0", "1e2"); anything else -- a non-integral value, a malformed
   --  literal, or a value outside the target type's range -- raises
   --  Decode_Error. The 32-bit variants additionally enforce the 32-bit range.
   function To_Int32  (Text : String) return Interfaces.Integer_32;
   function To_Int64  (Text : String) return Interfaces.Integer_64;
   function To_UInt32 (Text : String) return Interfaces.Unsigned_32;
   function To_UInt64 (Text : String) return Interfaces.Unsigned_64;

   --  Strict proto3 JSON float/double parsing: a finite value in range, or one
   --  of the tokens "NaN"/"Infinity"/"-Infinity". Out-of-range or malformed
   --  input raises Decode_Error.
   function To_Double (Text : String) return Interfaces.IEEE_Float_64;
   function To_Float (Text : String) return Interfaces.IEEE_Float_32;

   Decode_Error : exception;

end Proto_JSON;
