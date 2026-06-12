with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with Ada.Unchecked_Conversion;

package body Proto_JSON is

   use type Interfaces.IEEE_Float_64;
   use type JSON.Value_Kind;

   function Bits_To_Double is new Ada.Unchecked_Conversion
     (Interfaces.Unsigned_64, Interfaces.IEEE_Float_64);

   Pos_Inf : constant Interfaces.IEEE_Float_64 :=
     Bits_To_Double (16#7FF0_0000_0000_0000#);
   Neg_Inf : constant Interfaces.IEEE_Float_64 :=
     Bits_To_Double (16#FFF0_0000_0000_0000#);
   Nan_Val : constant Interfaces.IEEE_Float_64 :=
     Bits_To_Double (16#7FF8_0000_0000_0000#);

   function Strip (S : String) return String is
     (if S'Length > 0 and then S (S'First) = ' '
      then S (S'First + 1 .. S'Last) else S);

   function Image (V : Interfaces.Integer_64) return String is
     (Strip (Interfaces.Integer_64'Image (V)));

   function Image (V : Interfaces.Unsigned_64) return String is
     (Strip (Interfaces.Unsigned_64'Image (V)));

   function Double_To_JSON (V : Interfaces.IEEE_Float_64) return JSON.JSON_Value is
      D : constant Long_Float := Long_Float (V);
   begin
      if D /= D then                       --  NaN
         return JSON.To_Value ("NaN");
      elsif abs D > Long_Float'Last then    --  +/- infinity
         return JSON.To_Value (if D > 0.0 then "Infinity" else "-Infinity");
      else
         return JSON.Number (Strip (Long_Float'Image (D)));
      end if;
   end Double_To_JSON;

   function Float_To_JSON (V : Interfaces.IEEE_Float_32) return JSON.JSON_Value is
     (Double_To_JSON (Interfaces.IEEE_Float_64 (V)));

   ---------------------------------------------------------------------------
   --  Base64
   ---------------------------------------------------------------------------

   Alphabet : constant String :=
     "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

   function To_Base64 (S : String) return String is
      Buf : Unbounded_String;
      I   : Natural := S'First;

      procedure Emit_Group (B0, B1, B2 : Natural; Pad : Natural) is
         N : constant Natural := B0 * 65536 + B1 * 256 + B2;
      begin
         Append (Buf, Alphabet (Alphabet'First + (N / 262144) mod 64));
         Append (Buf, Alphabet (Alphabet'First + (N / 4096) mod 64));
         if Pad < 2 then
            Append (Buf, Alphabet (Alphabet'First + (N / 64) mod 64));
         else
            Append (Buf, '=');
         end if;
         if Pad < 1 then
            Append (Buf, Alphabet (Alphabet'First + N mod 64));
         else
            Append (Buf, '=');
         end if;
      end Emit_Group;
   begin
      while I <= S'Last loop
         declare
            B0 : constant Natural := Character'Pos (S (I));
            B1 : constant Natural :=
              (if I + 1 <= S'Last then Character'Pos (S (I + 1)) else 0);
            B2 : constant Natural :=
              (if I + 2 <= S'Last then Character'Pos (S (I + 2)) else 0);
            Remaining : constant Natural := S'Last - I + 1;
         begin
            Emit_Group (B0, B1, B2, (if Remaining >= 3 then 0
                                     elsif Remaining = 2 then 1 else 2));
         end;
         I := I + 3;
      end loop;
      return To_String (Buf);
   end To_Base64;

   function From_Base64 (S : String) return String is
      Buf  : Unbounded_String;
      Bits : Natural := 0;
      Acc  : Natural := 0;

      function Decode (C : Character) return Natural is
      begin
         case C is
            when 'A' .. 'Z' => return Character'Pos (C) - Character'Pos ('A');
            when 'a' .. 'z' => return Character'Pos (C) - Character'Pos ('a') + 26;
            when '0' .. '9' => return Character'Pos (C) - Character'Pos ('0') + 52;
            when '+' | '-'  => return 62;   --  '-' for URL-safe base64
            when '/' | '_'  => return 63;   --  '_' for URL-safe base64
            when others     => raise Decode_Error with "invalid base64 character";
         end case;
      end Decode;
   begin
      for C of S loop
         if C /= '=' and then C /= ' ' and then C /= ASCII.LF
           and then C /= ASCII.CR and then C /= ASCII.HT
         then
            Acc := Acc * 64 + Decode (C);
            Bits := Bits + 6;
            if Bits >= 8 then
               Bits := Bits - 8;
               Append (Buf, Character'Val ((Acc / (2 ** Bits)) mod 256));
            end if;
         end if;
      end loop;
      return To_String (Buf);
   end From_Base64;

   ---------------------------------------------------------------------------
   --  Parsing helpers
   ---------------------------------------------------------------------------

   function Scalar_Text (V : JSON.JSON_Value) return String is
   begin
      case JSON.Kind (V) is
         when JSON.JSON_Number => return JSON.As_Number (V);
         when JSON.JSON_String => return JSON.As_String (V);
         when others => raise Decode_Error with "expected a number or string";
      end case;
   end Scalar_Text;

   function To_Int64 (Text : String) return Interfaces.Integer_64 is
   begin
      return Interfaces.Integer_64'Value (Text);
   exception
      when Constraint_Error =>
         return Interfaces.Integer_64 (Long_Float'Value (Text));
   end To_Int64;

   function To_UInt64 (Text : String) return Interfaces.Unsigned_64 is
   begin
      return Interfaces.Unsigned_64'Value (Text);
   exception
      when Constraint_Error =>
         return Interfaces.Unsigned_64 (Long_Float'Value (Text));
   end To_UInt64;

   function To_Double (Text : String) return Interfaces.IEEE_Float_64 is
   begin
      if Text = "NaN" then
         return Nan_Val;
      elsif Text = "Infinity" or else Text = "+Infinity" then
         return Pos_Inf;
      elsif Text = "-Infinity" then
         return Neg_Inf;
      else
         return Interfaces.IEEE_Float_64 (Long_Float'Value (Text));
      end if;
   end To_Double;

   function To_Float (Text : String) return Interfaces.IEEE_Float_32 is
     (Interfaces.IEEE_Float_32 (To_Double (Text)));

   ---------------------------------------------------------------------------
   --  UTF-8 validation
   ---------------------------------------------------------------------------

   function Is_Valid_UTF8 (S : String) return Boolean is
      I : Natural := S'First;

      function B (K : Natural) return Natural is (Character'Pos (S (K)));

      function Cont (K : Natural) return Boolean is
        (K <= S'Last and then B (K) in 16#80# .. 16#BF#);
   begin
      while I <= S'Last loop
         declare
            C0 : constant Natural := B (I);
         begin
            if C0 < 16#80# then
               I := I + 1;
            elsif C0 in 16#C2# .. 16#DF# then            --  2-byte
               if not Cont (I + 1) then
                  return False;
               end if;
               I := I + 2;
            elsif C0 = 16#E0# then                        --  3-byte, no overlong
               if I + 2 > S'Last or else B (I + 1) not in 16#A0# .. 16#BF#
                 or else not Cont (I + 2)
               then
                  return False;
               end if;
               I := I + 3;
            elsif C0 = 16#ED# then                        --  3-byte, no surrogate
               if I + 2 > S'Last or else B (I + 1) not in 16#80# .. 16#9F#
                 or else not Cont (I + 2)
               then
                  return False;
               end if;
               I := I + 3;
            elsif C0 in 16#E1# .. 16#EF# then             --  3-byte
               if not Cont (I + 1) or else not Cont (I + 2) then
                  return False;
               end if;
               I := I + 3;
            elsif C0 = 16#F0# then                        --  4-byte, no overlong
               if I + 3 > S'Last or else B (I + 1) not in 16#90# .. 16#BF#
                 or else not Cont (I + 2) or else not Cont (I + 3)
               then
                  return False;
               end if;
               I := I + 4;
            elsif C0 = 16#F4# then                        --  4-byte, <= U+10FFFF
               if I + 3 > S'Last or else B (I + 1) not in 16#80# .. 16#8F#
                 or else not Cont (I + 2) or else not Cont (I + 3)
               then
                  return False;
               end if;
               I := I + 4;
            elsif C0 in 16#F1# .. 16#F3# then             --  4-byte
               if not Cont (I + 1) or else not Cont (I + 2)
                 or else not Cont (I + 3)
               then
                  return False;
               end if;
               I := I + 4;
            else
               return False;                              --  C0/C1/F5..FF
            end if;
         end;
      end loop;
      return True;
   end Is_Valid_UTF8;

   function Checked_UTF8 (S : String) return String is
   begin
      if Is_Valid_UTF8 (S) then
         return S;
      else
         raise Decode_Error with "string field is not valid UTF-8";
      end if;
   end Checked_UTF8;

end Proto_JSON;
