with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Unchecked_Conversion;

package body Proto_JSON is

   package LF_IO is new Ada.Text_IO.Float_IO (Long_Float);

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

   --  Drop surrounding spaces (Float_IO.Put right-justifies into a buffer).
   function Trim_Both (S : String) return String is
      F : Natural := S'First;
      L : Natural := S'Last;
   begin
      while F <= L and then S (F) = ' ' loop F := F + 1; end loop;
      while L >= F and then S (L) = ' ' loop L := L - 1; end loop;
      return S (F .. L);
   end Trim_Both;

   function Image (V : Interfaces.Integer_64) return String is
     (Strip (Interfaces.Integer_64'Image (V)));

   function Image (V : Interfaces.Unsigned_64) return String is
     (Strip (Interfaces.Unsigned_64'Image (V)));

   --  Shortest decimal text that round-trips to D exactly. proto3 JSON requires
   --  emitting enough significant digits that re-parsing yields the same double
   --  (Long_Float'Image gives only 15, losing values like DBL_MIN/DBL_MAX); we
   --  try increasing precision and take the first that round-trips.
   function Shortest_Real (D : Long_Float) return String is
   begin
      if D = 0.0 then
         return "0";
      end if;
      for Sig in 1 .. 17 loop
         declare
            Buf : String (1 .. 64);
         begin
            --  "[-]d.ddddE+xx" with Sig-1 fractional digits = Sig significant.
            LF_IO.Put (Buf, D, Aft => Sig - 1, Exp => 2);
            declare
               S : constant String := Trim_Both (Buf);
            begin
               if Long_Float'Value (S) = D then
                  return S;
               end if;
            end;
         end;
      end loop;
      return Trim_Both (Long_Float'Image (D));
   end Shortest_Real;

   function Double_To_JSON (V : Interfaces.IEEE_Float_64) return JSON.JSON_Value is
      D : constant Long_Float := Long_Float (V);
   begin
      if D /= D then                       --  NaN
         return JSON.To_Value ("NaN");
      elsif abs D > Long_Float'Last then    --  +/- infinity
         return JSON.To_Value (if D > 0.0 then "Infinity" else "-Infinity");
      else
         return JSON.Number (Shortest_Real (D));
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

   function Checked_String (V : JSON.JSON_Value) return String is
      use type JSON.Value_Kind;
   begin
      if JSON.Kind (V) /= JSON.JSON_String then
         raise Decode_Error with "expected a JSON string";
      end if;
      return JSON.As_String (V);
   end Checked_String;

   --  Parse a strict proto3 JSON integer into a sign and magnitude. Accepts a
   --  bare decimal integer or an integer-valued decimal/exponent form; raises
   --  Decode_Error on whitespace, a leading '+', leading zeros, a non-integral
   --  value, a magnitude past 2**64-1, or any other malformed input.
   procedure Parse_Integer
     (Text      : String;
      Negative  : out Boolean;
      Magnitude : out Interfaces.Unsigned_64)
   is
      use Interfaces;
      First : Natural := Text'First;
      Float_Form : Boolean := False;
   begin
      Negative  := False;
      Magnitude := 0;
      if Text'Length = 0 then
         raise Decode_Error with "empty integer";
      end if;
      --  No surrounding whitespace (a JSON number token never has it; the
      --  string form "  1 " must be rejected too).
      if Text (Text'First) = ' ' or else Text (Text'Last) = ' ' then
         raise Decode_Error with "whitespace in integer";
      end if;
      if Text (First) = '-' then
         Negative := True;
         First := First + 1;
      end if;
      if First > Text'Last then
         raise Decode_Error with "no digits";
      end if;
      for K in First .. Text'Last loop
         if Text (K) = '.' or else Text (K) = 'e' or else Text (K) = 'E' then
            Float_Form := True;
         end if;
      end loop;

      if Float_Form then
         --  Integer-valued float/exponent form (e.g. "10.0", "1e2"). Parse as
         --  a double and require an exact integral value in [-2**63, 2**64-1].
         declare
            F : Long_Float;
         begin
            F := Long_Float'Value (Text);
            if F /= Long_Float'Truncation (F) then
               raise Decode_Error with "non-integral value";
            end if;
            if F < -(2.0 ** 63) or else F >= 2.0 ** 64 then
               raise Decode_Error with "integer out of range";
            end if;
            Negative  := F < 0.0;
            Magnitude := Unsigned_64 (abs F);
         exception
            when Constraint_Error =>
               raise Decode_Error with "malformed number";
         end;
         return;
      end if;

      --  Pure integer form: all digits, no leading zero unless a lone "0".
      if Text (First) = '0' and then First < Text'Last then
         raise Decode_Error with "leading zero";
      end if;
      for K in First .. Text'Last loop
         declare
            D : constant Integer := Character'Pos (Text (K)) - Character'Pos ('0');
         begin
            if D not in 0 .. 9 then
               raise Decode_Error with "not a base-10 integer";
            end if;
            if Magnitude > (Unsigned_64'Last - Unsigned_64 (D)) / 10 then
               raise Decode_Error with "integer magnitude overflow";
            end if;
            Magnitude := Magnitude * 10 + Unsigned_64 (D);
         end;
      end loop;
   end Parse_Integer;

   function To_Int64 (Text : String) return Interfaces.Integer_64 is
      use Interfaces;
      Neg : Boolean;
      Mag : Unsigned_64;
   begin
      Parse_Integer (Text, Neg, Mag);
      if Neg then
         if Mag > Unsigned_64 (2) ** 63 then
            raise Decode_Error with "int64 underflow";
         elsif Mag = Unsigned_64 (2) ** 63 then
            return Integer_64'First;
         else
            return -Integer_64 (Mag);
         end if;
      else
         if Mag > Unsigned_64 (Integer_64'Last) then
            raise Decode_Error with "int64 overflow";
         end if;
         return Integer_64 (Mag);
      end if;
   end To_Int64;

   function To_UInt64 (Text : String) return Interfaces.Unsigned_64 is
      use Interfaces;
      Neg : Boolean;
      Mag : Unsigned_64;
   begin
      Parse_Integer (Text, Neg, Mag);
      if Neg and then Mag /= 0 then
         raise Decode_Error with "negative value for unsigned field";
      end if;
      return Mag;
   end To_UInt64;

   function To_Int32 (Text : String) return Interfaces.Integer_32 is
      V : constant Interfaces.Integer_64 := To_Int64 (Text);
      use type Interfaces.Integer_64;
   begin
      if V < Interfaces.Integer_64 (Interfaces.Integer_32'First)
        or else V > Interfaces.Integer_64 (Interfaces.Integer_32'Last)
      then
         raise Decode_Error with "int32 out of range";
      end if;
      return Interfaces.Integer_32 (V);
   end To_Int32;

   function To_UInt32 (Text : String) return Interfaces.Unsigned_32 is
      V : constant Interfaces.Unsigned_64 := To_UInt64 (Text);
      use type Interfaces.Unsigned_64;
   begin
      if V > Interfaces.Unsigned_64 (Interfaces.Unsigned_32'Last) then
         raise Decode_Error with "uint32 out of range";
      end if;
      return Interfaces.Unsigned_32 (V);
   end To_UInt32;

   function To_Double (Text : String) return Interfaces.IEEE_Float_64 is
   begin
      if Text = "NaN" then
         return Nan_Val;
      elsif Text = "Infinity" or else Text = "+Infinity" then
         return Pos_Inf;
      elsif Text = "-Infinity" then
         return Neg_Inf;
      end if;
      --  A finite JSON number: no surrounding whitespace, no special tokens.
      if Text'Length = 0
        or else Text (Text'First) = ' ' or else Text (Text'Last) = ' '
      then
         raise Decode_Error with "malformed number";
      end if;
      declare
         F : constant Long_Float := Long_Float'Value (Text);
      begin
         --  A finite literal that overflows binary64 parses to +/-Inf in GNAT
         --  rather than raising; proto3 requires rejecting out-of-range values.
         if abs F > Long_Float'Last then
            raise Decode_Error with "double out of range";
         end if;
         return Interfaces.IEEE_Float_64 (F);
      end;
   exception
      when Constraint_Error =>
         raise Decode_Error with "double out of range or malformed";
   end To_Double;

   function To_Float (Text : String) return Interfaces.IEEE_Float_32 is
      D : constant Interfaces.IEEE_Float_64 := To_Double (Text);
      use type Interfaces.IEEE_Float_64;
      --  Largest finite binary32, as a binary64 (NaN/Inf and in-range values
      --  pass through; a finite double past this overflows the float field).
      Float_Max : constant Interfaces.IEEE_Float_64 :=
        Interfaces.IEEE_Float_64 (Interfaces.IEEE_Float_32'Last);
   begin
      if D = D and then abs D <= Interfaces.IEEE_Float_64'Last
        and then abs D > Float_Max
      then
         raise Decode_Error with "float out of range";
      end if;
      return Interfaces.IEEE_Float_32 (D);
   end To_Float;

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
