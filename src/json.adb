with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;       use Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;

package body JSON is

   use type JSON_Value;

   type Pair is record
      Key_Str : Unbounded_String;
      Val     : JSON_Value;
   end record;

   package Value_Vectors is new Ada.Containers.Vectors (Positive, JSON_Value);
   package Pair_Vectors is new Ada.Containers.Vectors (Positive, Pair);

   type Node (Kind : Value_Kind := JSON_Null) is record
      case Kind is
         when JSON_Null =>
            null;
         when JSON_Bool =>
            Bool_Val : Boolean := False;
         when JSON_Number | JSON_String =>
            Text : Unbounded_String;
         when JSON_Array =>
            Items : Value_Vectors.Vector;
         when JSON_Object =>
            Pairs : Pair_Vectors.Vector;
      end case;
   end record;

   procedure Free is new Ada.Unchecked_Deallocation (Node, Node_Access);

   ---------------------------------------------------------------------------
   --  Controlled lifetime: deep copy on assignment, free on finalize.
   ---------------------------------------------------------------------------

   overriding procedure Adjust (V : in out JSON_Value) is
   begin
      if V.N /= null then
         V.N := new Node'(V.N.all);
      end if;
   end Adjust;

   overriding procedure Finalize (V : in out JSON_Value) is
   begin
      Free (V.N);
   end Finalize;

   function Make (N : Node_Access) return JSON_Value is
   begin
      return V : JSON_Value do
         V.N := N;
      end return;
   end Make;

   ---------------------------------------------------------------------------
   --  Constructors
   ---------------------------------------------------------------------------

   function Null_Value return JSON_Value is
     (Make (new Node'(Kind => JSON_Null)));

   function To_Value (B : Boolean) return JSON_Value is
     (Make (new Node'(Kind => JSON_Bool, Bool_Val => B)));

   function Number (Text : String) return JSON_Value is
     (Make (new Node'(Kind => JSON_Number, Text => To_Unbounded_String (Text))));

   function To_Value (S : String) return JSON_Value is
     (Make (new Node'(Kind => JSON_String, Text => To_Unbounded_String (S))));

   function Empty_Array return JSON_Value is
     (Make (new Node'(Kind => JSON_Array, Items => Value_Vectors.Empty_Vector)));

   function Empty_Object return JSON_Value is
     (Make (new Node'(Kind => JSON_Object, Pairs => Pair_Vectors.Empty_Vector)));

   procedure Append (Arr : in out JSON_Value; Item : JSON_Value) is
   begin
      Arr.N.Items.Append (Item);
   end Append;

   procedure Insert (Obj : in out JSON_Value; Key : String; Item : JSON_Value) is
   begin
      Obj.N.Pairs.Append ((Key_Str => To_Unbounded_String (Key), Val => Item));
   end Insert;

   ---------------------------------------------------------------------------
   --  Queries
   ---------------------------------------------------------------------------

   function Kind (V : JSON_Value) return Value_Kind is
     (if V.N = null then JSON_Null else V.N.Kind);

   function As_Boolean (V : JSON_Value) return Boolean is (V.N.Bool_Val);
   function As_Number (V : JSON_Value) return String is (To_String (V.N.Text));
   function As_String (V : JSON_Value) return String is (To_String (V.N.Text));

   function Length (V : JSON_Value) return Natural is
   begin
      if V.N = null then
         return 0;
      end if;
      case V.N.Kind is
         when JSON_Array  => return Natural (V.N.Items.Length);
         when JSON_Object => return Natural (V.N.Pairs.Length);
         when others      => return 0;
      end case;
   end Length;

   function Element (V : JSON_Value; Index : Positive) return JSON_Value is
     (V.N.Items (Index));

   function Has (V : JSON_Value; Key : String) return Boolean is
   begin
      if V.N = null or else V.N.Kind /= JSON_Object then
         return False;
      end if;
      for P of V.N.Pairs loop
         if To_String (P.Key_Str) = Key then
            return True;
         end if;
      end loop;
      return False;
   end Has;

   function Get (V : JSON_Value; Key : String) return JSON_Value is
   begin
      if V.N /= null and then V.N.Kind = JSON_Object then
         for P of V.N.Pairs loop
            if To_String (P.Key_Str) = Key then
               return P.Val;
            end if;
         end loop;
      end if;
      return Null_Value;
   end Get;

   function Key (V : JSON_Value; Index : Positive) return String is
     (To_String (V.N.Pairs (Index).Key_Str));

   ---------------------------------------------------------------------------
   --  Writer
   ---------------------------------------------------------------------------

   function Hex4 (N : Natural) return String is
      Digits_Str : constant String := "0123456789abcdef";
      R : String (1 .. 4);
      X : Natural := N;
   begin
      for I in reverse R'Range loop
         R (I) := Digits_Str (Digits_Str'First + (X mod 16));
         X := X / 16;
      end loop;
      return R;
   end Hex4;

   function Serialize (V : JSON_Value) return String is
      Buf : Unbounded_String;

      procedure Emit_String (S : String) is
      begin
         Append (Buf, '"');
         for C of S loop
            case C is
               when '"' =>
                  Append (Buf, '\'); Append (Buf, '"');
               when '\' =>
                  Append (Buf, '\'); Append (Buf, '\');
               when ASCII.LF =>
                  Append (Buf, '\'); Append (Buf, 'n');
               when ASCII.CR =>
                  Append (Buf, '\'); Append (Buf, 'r');
               when ASCII.HT =>
                  Append (Buf, '\'); Append (Buf, 't');
               when Character'Val (8) =>
                  Append (Buf, '\'); Append (Buf, 'b');
               when Character'Val (12) =>
                  Append (Buf, '\'); Append (Buf, 'f');
               when others =>
                  if Character'Pos (C) < 16#20# then
                     Append (Buf, "\u" & Hex4 (Character'Pos (C)));
                  else
                     Append (Buf, C);
                  end if;
            end case;
         end loop;
         Append (Buf, '"');
      end Emit_String;

      procedure Emit (X : JSON_Value) is
      begin
         case Kind (X) is
            when JSON_Null =>
               Append (Buf, "null");
            when JSON_Bool =>
               Append (Buf, (if As_Boolean (X) then "true" else "false"));
            when JSON_Number =>
               Append (Buf, As_Number (X));
            when JSON_String =>
               Emit_String (As_String (X));
            when JSON_Array =>
               Append (Buf, '[');
               for I in X.N.Items.First_Index .. X.N.Items.Last_Index loop
                  if I > X.N.Items.First_Index then
                     Append (Buf, ',');
                  end if;
                  Emit (X.N.Items (I));
               end loop;
               Append (Buf, ']');
            when JSON_Object =>
               Append (Buf, '{');
               for I in X.N.Pairs.First_Index .. X.N.Pairs.Last_Index loop
                  if I > X.N.Pairs.First_Index then
                     Append (Buf, ',');
                  end if;
                  Emit_String (To_String (X.N.Pairs (I).Key_Str));
                  Append (Buf, ':');
                  Emit (X.N.Pairs (I).Val);
               end loop;
               Append (Buf, '}');
         end case;
      end Emit;
   begin
      Emit (V);
      return To_String (Buf);
   end Serialize;

   ---------------------------------------------------------------------------
   --  Parser (recursive descent)
   ---------------------------------------------------------------------------

   function Parse (Text : String) return JSON_Value is
      Pos : Natural := Text'First;

      procedure Err (Message : String) is
      begin
         raise Parse_Error with Message;
      end Err;

      procedure Skip_WS is
      begin
         while Pos <= Text'Last
           and then (Text (Pos) = ' ' or else Text (Pos) = ASCII.HT
                     or else Text (Pos) = ASCII.LF or else Text (Pos) = ASCII.CR)
         loop
            Pos := Pos + 1;
         end loop;
      end Skip_WS;

      function At_End return Boolean is (Pos > Text'Last);

      function Hex_Val (C : Character) return Natural is
      begin
         case C is
            when '0' .. '9' => return Character'Pos (C) - Character'Pos ('0');
            when 'a' .. 'f' => return Character'Pos (C) - Character'Pos ('a') + 10;
            when 'A' .. 'F' => return Character'Pos (C) - Character'Pos ('A') + 10;
            when others => Err ("invalid hex digit"); return 0;
         end case;
      end Hex_Val;

      procedure Append_UTF8 (Buf : in out Unbounded_String; CP : Natural) is
      begin
         if CP < 16#80# then
            Append (Buf, Character'Val (CP));
         elsif CP < 16#800# then
            Append (Buf, Character'Val (16#C0# + (CP / 16#40#)));
            Append (Buf, Character'Val (16#80# + (CP mod 16#40#)));
         elsif CP < 16#1_0000# then
            Append (Buf, Character'Val (16#E0# + (CP / 16#1000#)));
            Append (Buf, Character'Val (16#80# + ((CP / 16#40#) mod 16#40#)));
            Append (Buf, Character'Val (16#80# + (CP mod 16#40#)));
         else
            Append (Buf, Character'Val (16#F0# + (CP / 16#4_0000#)));
            Append (Buf, Character'Val (16#80# + ((CP / 16#1000#) mod 16#40#)));
            Append (Buf, Character'Val (16#80# + ((CP / 16#40#) mod 16#40#)));
            Append (Buf, Character'Val (16#80# + (CP mod 16#40#)));
         end if;
      end Append_UTF8;

      function Parse_Hex4 return Natural is
         R : Natural := 0;
      begin
         for I in 1 .. 4 loop
            if At_End then
               Err ("truncated \u escape");
            end if;
            R := R * 16 + Hex_Val (Text (Pos));
            Pos := Pos + 1;
         end loop;
         return R;
      end Parse_Hex4;

      function Parse_String_Raw return String is
         Buf : Unbounded_String;
      begin
         Pos := Pos + 1;  --  opening quote
         loop
            if At_End then
               Err ("unterminated string");
            end if;
            declare
               C : constant Character := Text (Pos);
            begin
               if C = '"' then
                  Pos := Pos + 1;
                  exit;
               elsif C = '\' then
                  Pos := Pos + 1;
                  if At_End then
                     Err ("truncated escape");
                  end if;
                  case Text (Pos) is
                     when '"'  => Append (Buf, '"');  Pos := Pos + 1;
                     when '\'  => Append (Buf, '\');  Pos := Pos + 1;
                     when '/'  => Append (Buf, '/');  Pos := Pos + 1;
                     when 'b'  => Append (Buf, Character'Val (8));  Pos := Pos + 1;
                     when 'f'  => Append (Buf, Character'Val (12)); Pos := Pos + 1;
                     when 'n'  => Append (Buf, ASCII.LF); Pos := Pos + 1;
                     when 'r'  => Append (Buf, ASCII.CR); Pos := Pos + 1;
                     when 't'  => Append (Buf, ASCII.HT); Pos := Pos + 1;
                     when 'u'  =>
                        Pos := Pos + 1;
                        declare
                           CP : Natural := Parse_Hex4;
                        begin
                           if CP in 16#D800# .. 16#DBFF# then
                              --  high surrogate; expect a low surrogate next
                              if Pos + 1 <= Text'Last
                                and then Text (Pos) = '\'
                                and then Text (Pos + 1) = 'u'
                              then
                                 Pos := Pos + 2;
                                 declare
                                    Low : constant Natural := Parse_Hex4;
                                 begin
                                    CP := 16#1_0000#
                                          + (CP - 16#D800#) * 16#400#
                                          + (Low - 16#DC00#);
                                 end;
                              end if;
                           end if;
                           Append_UTF8 (Buf, CP);
                        end;
                     when others => Err ("invalid escape");
                  end case;
               else
                  Append (Buf, C);
                  Pos := Pos + 1;
               end if;
            end;
         end loop;
         return To_String (Buf);
      end Parse_String_Raw;

      function Parse_Value return JSON_Value;

      function Parse_Number return JSON_Value is
         Start : constant Natural := Pos;
      begin
         if not At_End and then Text (Pos) = '-' then
            Pos := Pos + 1;
         end if;
         while not At_End
           and then (Text (Pos) in '0' .. '9' or else Text (Pos) = '.'
                     or else Text (Pos) = 'e' or else Text (Pos) = 'E'
                     or else Text (Pos) = '+' or else Text (Pos) = '-')
         loop
            Pos := Pos + 1;
         end loop;
         if Pos = Start then
            Err ("invalid number");
         end if;
         return Number (Text (Start .. Pos - 1));
      end Parse_Number;

      function Parse_Literal (Word : String; Result : JSON_Value) return JSON_Value is
      begin
         if Pos + Word'Length - 1 <= Text'Last
           and then Text (Pos .. Pos + Word'Length - 1) = Word
         then
            Pos := Pos + Word'Length;
            return Result;
         end if;
         Err ("invalid literal");
         return Null_Value;
      end Parse_Literal;

      function Parse_Array return JSON_Value is
         Arr : JSON_Value := Empty_Array;
      begin
         Pos := Pos + 1;  --  '['
         Skip_WS;
         if not At_End and then Text (Pos) = ']' then
            Pos := Pos + 1;
            return Arr;
         end if;
         loop
            Skip_WS;
            Append (Arr, Parse_Value);
            Skip_WS;
            if At_End then
               Err ("unterminated array");
            elsif Text (Pos) = ',' then
               Pos := Pos + 1;
            elsif Text (Pos) = ']' then
               Pos := Pos + 1;
               exit;
            else
               Err ("expected ',' or ']'");
            end if;
         end loop;
         return Arr;
      end Parse_Array;

      function Parse_Object return JSON_Value is
         Obj : JSON_Value := Empty_Object;
      begin
         Pos := Pos + 1;  --  '{'
         Skip_WS;
         if not At_End and then Text (Pos) = '}' then
            Pos := Pos + 1;
            return Obj;
         end if;
         loop
            Skip_WS;
            if At_End or else Text (Pos) /= '"' then
               Err ("expected object key string");
            end if;
            declare
               K : constant String := Parse_String_Raw;
            begin
               Skip_WS;
               if At_End or else Text (Pos) /= ':' then
                  Err ("expected ':'");
               end if;
               Pos := Pos + 1;
               Skip_WS;
               Insert (Obj, K, Parse_Value);
            end;
            Skip_WS;
            if At_End then
               Err ("unterminated object");
            elsif Text (Pos) = ',' then
               Pos := Pos + 1;
            elsif Text (Pos) = '}' then
               Pos := Pos + 1;
               exit;
            else
               Err ("expected ',' or '}'");
            end if;
         end loop;
         return Obj;
      end Parse_Object;

      function Parse_Value return JSON_Value is
      begin
         Skip_WS;
         if At_End then
            Err ("unexpected end of input");
         end if;
         case Text (Pos) is
            when '{' => return Parse_Object;
            when '[' => return Parse_Array;
            when '"' => return To_Value (Parse_String_Raw);
            when 't' => return Parse_Literal ("true", To_Value (True));
            when 'f' => return Parse_Literal ("false", To_Value (False));
            when 'n' => return Parse_Literal ("null", Null_Value);
            when '-' | '0' .. '9' => return Parse_Number;
            when others => Err ("unexpected character"); return Null_Value;
         end case;
      end Parse_Value;

   begin
      return Result : constant JSON_Value := Parse_Value do
         Skip_WS;
         if not At_End then
            Err ("trailing characters after JSON value");
         end if;
      end return;
   end Parse;

end JSON;
