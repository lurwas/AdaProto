with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with Interfaces;              use Interfaces;
with Protobuf;
with Proto_JSON;

package body Proto_WKT is

   --  Find the single wrapper field (number 1) in a parsed message, if present.
   generic
      type Result_Type is private;
      with function Extract (F : Protobuf.Parsed_Field) return Result_Type;
   function Field1 (Data : String; Default : Result_Type) return Result_Type;

   function Field1 (Data : String; Default : Result_Type) return Result_Type is
      Fields : constant Protobuf.Parsed_Field_Vectors.Vector :=
        Protobuf.Parse_From_String (Data);
   begin
      return R : Result_Type := Default do
         for F of Fields loop
            if F.Number = 1 then
               R := Extract (F);
            end if;
         end loop;
      end return;
   end Field1;

   ---------------------------------------------------------------------------
   --  Empty
   ---------------------------------------------------------------------------

   function Serialize (X : Empty) return String is ("");
   function To_JSON (X : Empty) return JSON.JSON_Value is (JSON.Empty_Object);
   function From_JSON (V : JSON.JSON_Value) return Empty is (null record);
   function Parse_Empty (Data : String) return Empty is (null record);

   ---------------------------------------------------------------------------
   --  Wrappers: binary serialize (field 1, with default omission)
   ---------------------------------------------------------------------------

   function Serialize (X : Double_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      if X.Value /= 0.0 then
         Protobuf.Add_Double (B, 1, X.Value);
      end if;
      return Protobuf.To_String (B);
   end Serialize;

   function Serialize (X : Float_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      if X.Value /= 0.0 then
         Protobuf.Add_Float (B, 1, X.Value);
      end if;
      return Protobuf.To_String (B);
   end Serialize;

   function Serialize (X : Int64_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      if X.Value /= 0 then
         Protobuf.Add_Int64 (B, 1, X.Value);
      end if;
      return Protobuf.To_String (B);
   end Serialize;

   function Serialize (X : UInt64_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      if X.Value /= 0 then
         Protobuf.Add_UInt64 (B, 1, X.Value);
      end if;
      return Protobuf.To_String (B);
   end Serialize;

   function Serialize (X : Int32_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      if X.Value /= 0 then
         Protobuf.Add_Int32 (B, 1, X.Value);
      end if;
      return Protobuf.To_String (B);
   end Serialize;

   function Serialize (X : UInt32_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      if X.Value /= 0 then
         Protobuf.Add_UInt32 (B, 1, X.Value);
      end if;
      return Protobuf.To_String (B);
   end Serialize;

   function Serialize (X : Bool_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      if X.Value then
         Protobuf.Add_Bool (B, 1, X.Value);
      end if;
      return Protobuf.To_String (B);
   end Serialize;

   function Serialize (X : String_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      if Length (X.Value) > 0 then
         Protobuf.Add_String (B, 1, To_String (X.Value));
      end if;
      return Protobuf.To_String (B);
   end Serialize;

   function Serialize (X : Bytes_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      if Length (X.Value) > 0 then
         Protobuf.Add_Bytes (B, 1, To_String (X.Value));
      end if;
      return Protobuf.To_String (B);
   end Serialize;

   ---------------------------------------------------------------------------
   --  Wrappers: binary parse
   ---------------------------------------------------------------------------

   function E_Double (F : Protobuf.Parsed_Field) return Double_Value is
     ((Value => Protobuf.As_Double (F)));
   function P_Double is new Field1 (Double_Value, E_Double);
   function Parse_Double_Value (Data : String) return Double_Value is
     (P_Double (Data, (Value => 0.0)));

   function E_Float (F : Protobuf.Parsed_Field) return Float_Value is
     ((Value => Protobuf.As_Float (F)));
   function P_Float is new Field1 (Float_Value, E_Float);
   function Parse_Float_Value (Data : String) return Float_Value is
     (P_Float (Data, (Value => 0.0)));

   function E_Int64 (F : Protobuf.Parsed_Field) return Int64_Value is
     ((Value => Protobuf.As_Int64 (F)));
   function P_Int64 is new Field1 (Int64_Value, E_Int64);
   function Parse_Int64_Value (Data : String) return Int64_Value is
     (P_Int64 (Data, (Value => 0)));

   function E_UInt64 (F : Protobuf.Parsed_Field) return UInt64_Value is
     ((Value => Protobuf.As_UInt64 (F)));
   function P_UInt64 is new Field1 (UInt64_Value, E_UInt64);
   function Parse_UInt64_Value (Data : String) return UInt64_Value is
     (P_UInt64 (Data, (Value => 0)));

   function E_Int32 (F : Protobuf.Parsed_Field) return Int32_Value is
     ((Value => Protobuf.As_Int32 (F)));
   function P_Int32 is new Field1 (Int32_Value, E_Int32);
   function Parse_Int32_Value (Data : String) return Int32_Value is
     (P_Int32 (Data, (Value => 0)));

   function E_UInt32 (F : Protobuf.Parsed_Field) return UInt32_Value is
     ((Value => Protobuf.As_UInt32 (F)));
   function P_UInt32 is new Field1 (UInt32_Value, E_UInt32);
   function Parse_UInt32_Value (Data : String) return UInt32_Value is
     (P_UInt32 (Data, (Value => 0)));

   function E_Bool (F : Protobuf.Parsed_Field) return Bool_Value is
     ((Value => Protobuf.As_Bool (F)));
   function P_Bool is new Field1 (Bool_Value, E_Bool);
   function Parse_Bool_Value (Data : String) return Bool_Value is
     (P_Bool (Data, (Value => False)));

   function E_String (F : Protobuf.Parsed_Field) return String_Value is
     ((Value => To_Unbounded_String
                  (Proto_JSON.Checked_UTF8 (Protobuf.As_String (F)))));
   function P_String is new Field1 (String_Value, E_String);
   function Parse_String_Value (Data : String) return String_Value is
     (P_String (Data, (Value => Null_Unbounded_String)));

   function E_Bytes (F : Protobuf.Parsed_Field) return Bytes_Value is
     ((Value => To_Unbounded_String (Protobuf.As_Bytes (F))));
   function P_Bytes is new Field1 (Bytes_Value, E_Bytes);
   function Parse_Bytes_Value (Data : String) return Bytes_Value is
     (P_Bytes (Data, (Value => Null_Unbounded_String)));

   ---------------------------------------------------------------------------
   --  Wrappers: JSON (the bare wrapped value)
   ---------------------------------------------------------------------------

   function To_JSON (X : Double_Value) return JSON.JSON_Value is
     (Proto_JSON.Double_To_JSON (X.Value));
   function To_JSON (X : Float_Value) return JSON.JSON_Value is
     (Proto_JSON.Float_To_JSON (X.Value));
   function To_JSON (X : Int64_Value) return JSON.JSON_Value is
     (JSON.To_Value (Proto_JSON.Image (X.Value)));
   function To_JSON (X : UInt64_Value) return JSON.JSON_Value is
     (JSON.To_Value (Proto_JSON.Image (X.Value)));
   function To_JSON (X : Int32_Value) return JSON.JSON_Value is
     (JSON.Number (Proto_JSON.Image (Integer_64 (X.Value))));
   function To_JSON (X : UInt32_Value) return JSON.JSON_Value is
     (JSON.Number (Proto_JSON.Image (Unsigned_64 (X.Value))));
   function To_JSON (X : Bool_Value) return JSON.JSON_Value is
     (JSON.To_Value (X.Value));
   function To_JSON (X : String_Value) return JSON.JSON_Value is
     (JSON.To_Value (To_String (X.Value)));
   function To_JSON (X : Bytes_Value) return JSON.JSON_Value is
     (JSON.To_Value (Proto_JSON.To_Base64 (To_String (X.Value))));

   function From_JSON (V : JSON.JSON_Value) return Double_Value is
     ((Value => Proto_JSON.To_Double (Proto_JSON.Scalar_Text (V))));
   function From_JSON (V : JSON.JSON_Value) return Float_Value is
     ((Value => Proto_JSON.To_Float (Proto_JSON.Scalar_Text (V))));
   function From_JSON (V : JSON.JSON_Value) return Int64_Value is
     ((Value => Proto_JSON.To_Int64 (Proto_JSON.Scalar_Text (V))));
   function From_JSON (V : JSON.JSON_Value) return UInt64_Value is
     ((Value => Proto_JSON.To_UInt64 (Proto_JSON.Scalar_Text (V))));
   function From_JSON (V : JSON.JSON_Value) return Int32_Value is
     ((Value => Integer_32 (Proto_JSON.To_Int64 (Proto_JSON.Scalar_Text (V)))));
   function From_JSON (V : JSON.JSON_Value) return UInt32_Value is
     ((Value => Unsigned_32 (Proto_JSON.To_UInt64 (Proto_JSON.Scalar_Text (V)))));
   function From_JSON (V : JSON.JSON_Value) return Bool_Value is
     ((Value => JSON.As_Boolean (V)));
   function From_JSON (V : JSON.JSON_Value) return String_Value is
     ((Value => To_Unbounded_String
                  (Proto_JSON.Checked_UTF8 (JSON.As_String (V)))));
   function From_JSON (V : JSON.JSON_Value) return Bytes_Value is
     ((Value => To_Unbounded_String (Proto_JSON.From_Base64 (JSON.As_String (V)))));

end Proto_WKT;
