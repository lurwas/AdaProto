with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;

package body Proto_JSON is

   use type Interfaces.IEEE_Float_64;

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

end Proto_JSON;
