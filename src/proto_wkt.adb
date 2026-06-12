with Ada.Characters.Handling;  use Ada.Characters.Handling;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Interfaces;                use Interfaces;
with Protobuf;
with Proto_JSON;

package body Proto_WKT is

   use type JSON.Value_Kind;

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

   ---------------------------------------------------------------------------
   --  Duration / Timestamp: shared { seconds=1, nanos=2 } binary form
   ---------------------------------------------------------------------------

   function Serialize_SN (Seconds : Integer_64; Nanos : Integer_32) return String is
      B : Protobuf.Message_Buffer;
   begin
      if Seconds /= 0 then
         Protobuf.Add_Int64 (B, 1, Seconds);
      end if;
      if Nanos /= 0 then
         Protobuf.Add_Int32 (B, 2, Nanos);
      end if;
      return Protobuf.To_String (B);
   end Serialize_SN;

   procedure Parse_SN (Data : String; Seconds : out Integer_64; Nanos : out Integer_32)
   is
      Fields : constant Protobuf.Parsed_Field_Vectors.Vector :=
        Protobuf.Parse_From_String (Data);
   begin
      Seconds := 0;
      Nanos := 0;
      for F of Fields loop
         if F.Number = 1 then
            Seconds := Protobuf.As_Int64 (F);
         elsif F.Number = 2 then
            Nanos := Protobuf.As_Int32 (F);
         end if;
      end loop;
   end Parse_SN;

   function Serialize (X : Duration) return String is
     (Serialize_SN (X.Seconds, X.Nanos));
   function Serialize (X : Timestamp) return String is
     (Serialize_SN (X.Seconds, X.Nanos));

   function Parse_Duration (Data : String) return Duration is
      R : Duration;
   begin
      Parse_SN (Data, R.Seconds, R.Nanos);
      return R;
   end Parse_Duration;

   function Parse_Timestamp (Data : String) return Timestamp is
      R : Timestamp;
   begin
      Parse_SN (Data, R.Seconds, R.Nanos);
      return R;
   end Parse_Timestamp;

   ---------------------------------------------------------------------------
   --  Date arithmetic (Howard Hinnant's civil <-> days-since-epoch)
   ---------------------------------------------------------------------------

   function Days_From_Civil (Y0 : Integer_64; M, D : Integer) return Integer_64 is
      Y   : constant Integer_64 := Y0 - (if M <= 2 then 1 else 0);
      Era : constant Integer_64 := (if Y >= 0 then Y else Y - 399) / 400;
      YOE : constant Integer_64 := Y - Era * 400;
      MP  : constant Integer_64 := (if M > 2 then Integer_64 (M) - 3
                                    else Integer_64 (M) + 9);
      DOY : constant Integer_64 := (153 * MP + 2) / 5 + Integer_64 (D) - 1;
      DOE : constant Integer_64 := YOE * 365 + YOE / 4 - YOE / 100 + DOY;
   begin
      return Era * 146097 + DOE - 719468;
   end Days_From_Civil;

   procedure Civil_From_Days
     (Z0 : Integer_64; Y : out Integer_64; M : out Integer; D : out Integer)
   is
      Z   : constant Integer_64 := Z0 + 719468;
      Era : constant Integer_64 := (if Z >= 0 then Z else Z - 146096) / 146097;
      DOE : constant Integer_64 := Z - Era * 146097;
      YOE : constant Integer_64 :=
        (DOE - DOE / 1460 + DOE / 36524 - DOE / 146096) / 365;
      DOY : constant Integer_64 := DOE - (365 * YOE + YOE / 4 - YOE / 100);
      MP  : constant Integer_64 := (5 * DOY + 2) / 153;
      Dd  : constant Integer_64 := DOY - (153 * MP + 2) / 5 + 1;
      Mm  : constant Integer_64 := (if MP < 10 then MP + 3 else MP - 9);
   begin
      Y := YOE + Era * 400 + (if Mm <= 2 then 1 else 0);
      M := Integer (Mm);
      D := Integer (Dd);
   end Civil_From_Days;

   --  Zero-padded decimal of a non-negative value, at least Width digits.
   function Pad (N : Integer_64; Width : Positive) return String is
      Img : constant String := Proto_JSON.Image (Unsigned_64 (N));
   begin
      if Img'Length >= Width then
         return Img;
      else
         return (1 .. Width - Img'Length => '0') & Img;
      end if;
   end Pad;

   --  Fractional-second text: "" if zero, else "." + 3/6/9 digits.
   function Frac (Nanos : Natural) return String is
      F   : String (1 .. 9);
      N   : Natural := Nanos;
      Len : Natural := 9;
   begin
      if Nanos = 0 then
         return "";
      end if;
      for I in reverse 1 .. 9 loop
         F (I) := Character'Val (Character'Pos ('0') + N mod 10);
         N := N / 10;
      end loop;
      while Len > 3 and then F (Len - 2 .. Len) = "000" loop
         Len := Len - 3;
      end loop;
      return "." & F (1 .. Len);
   end Frac;

   ---------------------------------------------------------------------------
   --  Duration JSON
   ---------------------------------------------------------------------------

   function To_JSON (X : Duration) return JSON.JSON_Value is
      Neg : constant Boolean := X.Seconds < 0 or else X.Nanos < 0;
   begin
      return JSON.To_Value
        ((if Neg then "-" else "")
         & Proto_JSON.Image (abs X.Seconds)
         & Frac (Natural (abs X.Nanos)) & "s");
   end To_JSON;

   function Frac_To_Nanos (Frac_Digits : String) return Natural is
      Padded : String (1 .. 9) := (others => '0');
      Len    : constant Natural := Natural'Min (9, Frac_Digits'Length);
   begin
      Padded (1 .. Len) :=
        Frac_Digits (Frac_Digits'First .. Frac_Digits'First + Len - 1);
      return Natural'Value (Padded);
   end Frac_To_Nanos;

   function From_JSON (V : JSON.JSON_Value) return Duration is
      S    : constant String := JSON.As_String (V);
      Last : Natural := S'Last;
      Neg  : Boolean := False;
      P    : Natural := S'First;
      Dot  : Natural := 0;
   begin
      if Last < S'First or else S (Last) /= 's' then
         raise Proto_JSON.Decode_Error with "duration must end in 's'";
      end if;
      Last := Last - 1;
      if P <= Last and then S (P) = '-' then
         Neg := True;
         P := P + 1;
      end if;
      for I in P .. Last loop
         if S (I) = '.' then
            Dot := I;
         end if;
      end loop;
      declare
         Int_Part  : constant String :=
           (if Dot = 0 then S (P .. Last) else S (P .. Dot - 1));
         Frac_Part : constant String :=
           (if Dot = 0 then "" else S (Dot + 1 .. Last));
         Secs  : constant Integer_64 := Integer_64'Value (Int_Part);
         Nanos : constant Integer_32 := Integer_32 (Frac_To_Nanos (Frac_Part));
      begin
         return (Seconds => (if Neg then -Secs else Secs),
                 Nanos   => (if Neg then -Nanos else Nanos));
      end;
   end From_JSON;

   ---------------------------------------------------------------------------
   --  Timestamp JSON (RFC 3339, always emitted in UTC with a trailing Z)
   ---------------------------------------------------------------------------

   function To_JSON (X : Timestamp) return JSON.JSON_Value is
      Secs_Of_Day : constant Integer_64 := X.Seconds mod 86400;
      Days        : constant Integer_64 := (X.Seconds - Secs_Of_Day) / 86400;
      Y : Integer_64;
      M : Integer;
      D : Integer;
   begin
      Civil_From_Days (Days, Y, M, D);
      return JSON.To_Value
        (Pad (Y, 4) & "-" & Pad (Integer_64 (M), 2) & "-" & Pad (Integer_64 (D), 2)
         & "T" & Pad (Secs_Of_Day / 3600, 2)
         & ":" & Pad ((Secs_Of_Day mod 3600) / 60, 2)
         & ":" & Pad (Secs_Of_Day mod 60, 2)
         & Frac (Natural (X.Nanos)) & "Z");
   end To_JSON;

   function From_JSON (V : JSON.JSON_Value) return Timestamp is
      S : constant String := JSON.As_String (V);
      P : Natural := S'First;

      function Num (Count : Positive) return Integer_64 is
         R : Integer_64 := 0;
      begin
         for I in 1 .. Count loop
            if P > S'Last or else S (P) not in '0' .. '9' then
               raise Proto_JSON.Decode_Error with "bad RFC3339 timestamp";
            end if;
            R := R * 10 + Integer_64 (Character'Pos (S (P)) - Character'Pos ('0'));
            P := P + 1;
         end loop;
         return R;
      end Num;

      procedure Expect (C : Character) is
      begin
         if P > S'Last or else (S (P) /= C and then S (P) /= To_Lower (C)) then
            raise Proto_JSON.Decode_Error with "bad RFC3339 timestamp";
         end if;
         P := P + 1;
      end Expect;

      Year, Mon, Day, Hr, Mi, Se : Integer_64;
      Nanos       : Natural := 0;
      Offset_Secs : Integer_64 := 0;
   begin
      Year := Num (4); Expect ('-');
      Mon  := Num (2); Expect ('-');
      Day  := Num (2); Expect ('T');
      Hr   := Num (2); Expect (':');
      Mi   := Num (2); Expect (':');
      Se   := Num (2);

      if P <= S'Last and then S (P) = '.' then
         P := P + 1;
         declare
            Start : constant Natural := P;
         begin
            while P <= S'Last and then S (P) in '0' .. '9' loop
               P := P + 1;
            end loop;
            Nanos := Frac_To_Nanos (S (Start .. P - 1));
         end;
      end if;

      if P > S'Last then
         raise Proto_JSON.Decode_Error with "RFC3339 timestamp needs a zone";
      elsif S (P) = 'Z' or else S (P) = 'z' then
         P := P + 1;
      else
         declare
            Sign : constant Integer_64 := (if S (P) = '-' then -1 else 1);
         begin
            P := P + 1;
            declare
               OH : constant Integer_64 := Num (2);
            begin
               Expect (':');
               Offset_Secs := Sign * (OH * 3600 + Num (2) * 60);
            end;
         end;
      end if;

      return
        (Seconds => Days_From_Civil (Year, Integer (Mon), Integer (Day)) * 86400
                    + Hr * 3600 + Mi * 60 + Se - Offset_Secs,
         Nanos   => Integer_32 (Nanos));
   end From_JSON;

   ---------------------------------------------------------------------------
   --  FieldMask
   ---------------------------------------------------------------------------

   function Serialize (X : Field_Mask) return String is
      B : Protobuf.Message_Buffer;
   begin
      for P of X.Paths loop
         Protobuf.Add_String (B, 1, To_String (P));
      end loop;
      return Protobuf.To_String (B);
   end Serialize;

   function Parse_Field_Mask (Data : String) return Field_Mask is
      R      : Field_Mask;
      Fields : constant Protobuf.Parsed_Field_Vectors.Vector :=
        Protobuf.Parse_From_String (Data);
   begin
      for F of Fields loop
         if F.Number = 1 then
            R.Paths.Append (To_Unbounded_String (Protobuf.As_String (F)));
         end if;
      end loop;
      return R;
   end Parse_Field_Mask;

   --  snake_case -> lowerCamelCase, leaving the '.' path separators alone.
   function Snake_To_Camel (S : String) return String is
      R  : Unbounded_String;
      Up : Boolean := False;
   begin
      for C of S loop
         if C = '_' then
            Up := True;
         elsif C = '.' then
            Append (R, '.');
            Up := False;
         elsif Up then
            Append (R, To_Upper (C));
            Up := False;
         else
            Append (R, C);
         end if;
      end loop;
      return To_String (R);
   end Snake_To_Camel;

   function Camel_To_Snake (S : String) return String is
      R : Unbounded_String;
   begin
      for C of S loop
         if C in 'A' .. 'Z' then
            Append (R, '_');
            Append (R, To_Lower (C));
         else
            Append (R, C);
         end if;
      end loop;
      return To_String (R);
   end Camel_To_Snake;

   function To_JSON (X : Field_Mask) return JSON.JSON_Value is
      R     : Unbounded_String;
      First : Boolean := True;
   begin
      for P of X.Paths loop
         if not First then
            Append (R, ',');
         end if;
         First := False;
         Append (R, Snake_To_Camel (To_String (P)));
      end loop;
      return JSON.To_Value (To_String (R));
   end To_JSON;

   function From_JSON (V : JSON.JSON_Value) return Field_Mask is
      S     : constant String := JSON.As_String (V);
      R     : Field_Mask;
      Start : Natural := S'First;
   begin
      if S'Length = 0 then
         return R;
      end if;
      for I in S'Range loop
         if S (I) = ',' then
            R.Paths.Append
              (To_Unbounded_String (Camel_To_Snake (S (Start .. I - 1))));
            Start := I + 1;
         end if;
      end loop;
      R.Paths.Append (To_Unbounded_String (Camel_To_Snake (S (Start .. S'Last))));
      return R;
   end From_JSON;

   ---------------------------------------------------------------------------
   --  Struct / Value / ListValue binary <-> JSON DOM (recursive)
   ---------------------------------------------------------------------------

   function Encode_Value (J : JSON.JSON_Value) return String;
   function Encode_Struct (J : JSON.JSON_Value) return String;
   function Encode_List (J : JSON.JSON_Value) return String;
   function Decode_Value (Data : String) return JSON.JSON_Value;
   function Decode_Struct (Data : String) return JSON.JSON_Value;
   function Decode_List (Data : String) return JSON.JSON_Value;

   function Encode_Value (J : JSON.JSON_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      case JSON.Kind (J) is
         when JSON.JSON_Null =>
            Protobuf.Add_Int32 (B, 1, 0);                 --  null_value
         when JSON.JSON_Number =>
            Protobuf.Add_Double
              (B, 2, Proto_JSON.To_Double (JSON.As_Number (J)));
         when JSON.JSON_String =>
            Protobuf.Add_String (B, 3, JSON.As_String (J));
         when JSON.JSON_Bool =>
            Protobuf.Add_Bool (B, 4, JSON.As_Boolean (J));
         when JSON.JSON_Object =>
            Protobuf.Add_Message (B, 5, Encode_Struct (J));
         when JSON.JSON_Array =>
            Protobuf.Add_Message (B, 6, Encode_List (J));
      end case;
      return Protobuf.To_String (B);
   end Encode_Value;

   function Encode_Struct (J : JSON.JSON_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      for I in 1 .. JSON.Length (J) loop
         declare
            Entry_B : Protobuf.Message_Buffer;
         begin
            Protobuf.Add_String (Entry_B, 1, JSON.Key (J, I));
            Protobuf.Add_Message
              (Entry_B, 2, Encode_Value (JSON.Get (J, JSON.Key (J, I))));
            Protobuf.Add_Message (B, 1, Protobuf.To_String (Entry_B));
         end;
      end loop;
      return Protobuf.To_String (B);
   end Encode_Struct;

   function Encode_List (J : JSON.JSON_Value) return String is
      B : Protobuf.Message_Buffer;
   begin
      for I in 1 .. JSON.Length (J) loop
         Protobuf.Add_Message (B, 1, Encode_Value (JSON.Element (J, I)));
      end loop;
      return Protobuf.To_String (B);
   end Encode_List;

   function Decode_Value (Data : String) return JSON.JSON_Value is
      Fields : constant Protobuf.Parsed_Field_Vectors.Vector :=
        Protobuf.Parse_From_String (Data);
      R : JSON.JSON_Value := JSON.Null_Value;
   begin
      for F of Fields loop
         case Natural (F.Number) is
            when 1 => R := JSON.Null_Value;
            when 2 => R := Proto_JSON.Double_To_JSON (Protobuf.As_Double (F));
            when 3 => R := JSON.To_Value
                             (Proto_JSON.Checked_UTF8 (Protobuf.As_String (F)));
            when 4 => R := JSON.To_Value (Protobuf.As_Bool (F));
            when 5 => R := Decode_Struct (Protobuf.As_Message_Bytes (F));
            when 6 => R := Decode_List (Protobuf.As_Message_Bytes (F));
            when others => null;
         end case;
      end loop;
      return R;
   end Decode_Value;

   function Decode_Struct (Data : String) return JSON.JSON_Value is
      Fields : constant Protobuf.Parsed_Field_Vectors.Vector :=
        Protobuf.Parse_From_String (Data);
      R : JSON.JSON_Value := JSON.Empty_Object;
   begin
      for F of Fields loop
         if F.Number = 1 then
            declare
               Entry_Fields : constant Protobuf.Parsed_Field_Vectors.Vector :=
                 Protobuf.Parse_From_String (Protobuf.As_Message_Bytes (F));
               Key : Unbounded_String;
               Val : JSON.JSON_Value := JSON.Null_Value;
            begin
               for EF of Entry_Fields loop
                  if EF.Number = 1 then
                     Key := To_Unbounded_String (Protobuf.As_String (EF));
                  elsif EF.Number = 2 then
                     Val := Decode_Value (Protobuf.As_Message_Bytes (EF));
                  end if;
               end loop;
               JSON.Insert (R, To_String (Key), Val);
            end;
         end if;
      end loop;
      return R;
   end Decode_Struct;

   function Decode_List (Data : String) return JSON.JSON_Value is
      Fields : constant Protobuf.Parsed_Field_Vectors.Vector :=
        Protobuf.Parse_From_String (Data);
      R : JSON.JSON_Value := JSON.Empty_Array;
   begin
      for F of Fields loop
         if F.Number = 1 then
            JSON.Append (R, Decode_Value (Protobuf.As_Message_Bytes (F)));
         end if;
      end loop;
      return R;
   end Decode_List;

   function Serialize (X : Value) return String is (Encode_Value (X.Val));
   function Serialize (X : Struct) return String is (Encode_Struct (X.Val));
   function Serialize (X : List_Value) return String is (Encode_List (X.Val));

   function Parse_Value (Data : String) return Value is
     ((Val => Decode_Value (Data)));
   function Parse_Struct (Data : String) return Struct is
     ((Val => Decode_Struct (Data)));
   function Parse_List_Value (Data : String) return List_Value is
     ((Val => Decode_List (Data)));

   function To_JSON (X : Value) return JSON.JSON_Value is (X.Val);
   function To_JSON (X : Struct) return JSON.JSON_Value is (X.Val);
   function To_JSON (X : List_Value) return JSON.JSON_Value is (X.Val);

   function From_JSON (V : JSON.JSON_Value) return Value is ((Val => V));
   function From_JSON (V : JSON.JSON_Value) return Struct is ((Val => V));
   function From_JSON (V : JSON.JSON_Value) return List_Value is ((Val => V));

end Proto_WKT;
