with Ada.Finalization;

--  A small JSON DOM with a recursive-descent parser and a compact writer.
--
--  Numbers are kept as their raw textual form so that 64-bit integer
--  precision and the proto3 JSON special tokens ("NaN", "Infinity") survive a
--  round-trip without going through a floating-point type. JSON_Value has value
--  semantics (assignment deep-copies, finalization frees); a default-
--  initialised value behaves as JSON null.
package JSON is

   type Value_Kind is
     (JSON_Null, JSON_Bool, JSON_Number, JSON_String, JSON_Array, JSON_Object);

   type JSON_Value is private;

   Parse_Error : exception;

   ---------------------------------------------------------------------------
   --  Constructors
   ---------------------------------------------------------------------------

   function Null_Value return JSON_Value;
   function To_Value (B : Boolean) return JSON_Value;
   function Number (Text : String) return JSON_Value;   --  raw numeric literal
   function To_Value (S : String) return JSON_Value;     --  string value
   function Empty_Array return JSON_Value;
   function Empty_Object return JSON_Value;

   procedure Append (Arr : in out JSON_Value; Item : JSON_Value);
   procedure Insert (Obj : in out JSON_Value; Key : String; Item : JSON_Value);

   ---------------------------------------------------------------------------
   --  Queries
   ---------------------------------------------------------------------------

   function Kind (V : JSON_Value) return Value_Kind;
   function As_Boolean (V : JSON_Value) return Boolean;
   function As_Number (V : JSON_Value) return String;
   function As_String (V : JSON_Value) return String;

   function Length (V : JSON_Value) return Natural;        --  array or object
   function Element (V : JSON_Value; Index : Positive) return JSON_Value;
   function Has (V : JSON_Value; Key : String) return Boolean;
   function Get (V : JSON_Value; Key : String) return JSON_Value;
   function Key (V : JSON_Value; Index : Positive) return String;

   ---------------------------------------------------------------------------
   --  Text
   ---------------------------------------------------------------------------

   function Serialize (V : JSON_Value) return String;
   function Parse (Text : String) return JSON_Value;

private

   type Node;
   type Node_Access is access Node;

   type JSON_Value is new Ada.Finalization.Controlled with record
      N : Node_Access := null;
   end record;

   overriding procedure Adjust (V : in out JSON_Value);
   overriding procedure Finalize (V : in out JSON_Value);

end JSON;
