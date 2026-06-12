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

   Decode_Error : exception;

end Proto_JSON;
