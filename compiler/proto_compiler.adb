with Ada.Characters.Handling;  use Ada.Characters.Handling;
with Ada.Containers.Vectors;
with Ada.Directories;
with Ada.Streams.Stream_IO;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO;

package body Proto_Compiler is

   NL : constant Character := ASCII.LF;
   Q  : constant Character := '"';   --  a double quote, for emitting Ada string literals

   ---------------------------------------------------------------------------
   --  AST
   ---------------------------------------------------------------------------

   type Field_Def is record
      Proto_Type : Unbounded_String;
      Name       : Unbounded_String;
      Number     : Positive := 1;
      Repeated   : Boolean := False;
      Optional   : Boolean := False;  --  proto3 explicit-presence scalar field
      Oneof      : Unbounded_String;  --  empty unless this field is in a oneof
      Is_Map     : Boolean := False;
      Map_Key    : Unbounded_String;  --  proto key type when Is_Map
      Map_Value  : Unbounded_String;  --  proto value type when Is_Map
      Packed_Set : Boolean := False;  --  True if an explicit [packed=...] was given
      Packed     : Boolean := True;   --  the [packed=...] value (meaningful when set)
   end record;

   package Field_Vectors is new Ada.Containers.Vectors (Positive, Field_Def);

   type Message_Def is record
      Name   : Unbounded_String;
      Fields : Field_Vectors.Vector;
   end record;

   package Message_Vectors is new Ada.Containers.Vectors (Positive, Message_Def);

   type Enum_Value is record
      Name   : Unbounded_String;
      Number : Integer := 0;
   end record;

   package Enum_Value_Vectors is new Ada.Containers.Vectors (Positive, Enum_Value);

   type Enum_Def is record
      Name   : Unbounded_String;
      Values : Enum_Value_Vectors.Vector;
   end record;

   package Enum_Vectors is new Ada.Containers.Vectors (Positive, Enum_Def);

   package String_Vectors is new Ada.Containers.Vectors (Positive, Unbounded_String);

   package Nat_Vectors is new Ada.Containers.Vectors (Positive, Positive);

   ---------------------------------------------------------------------------
   --  Lexer
   ---------------------------------------------------------------------------

   type Token_Kind is (T_Ident, T_Number, T_String, T_Symbol, T_EOF);

   type Token is record
      Kind : Token_Kind := T_EOF;
      Text : Unbounded_String;
      Line : Positive := 1;
   end record;

   package Token_Vectors is new Ada.Containers.Vectors (Positive, Token);

   function Is_Ident_Start (C : Character) return Boolean is
     (Is_Letter (C) or else C = '_');

   function Is_Ident_Char (C : Character) return Boolean is
     (Is_Alphanumeric (C) or else C = '_');

   function Lex (Source : String) return Token_Vectors.Vector is
      Toks : Token_Vectors.Vector;
      I    : Natural := Source'First;
      Line : Positive := 1;
   begin
      while I <= Source'Last loop
         declare
            C : constant Character := Source (I);
         begin
            if C = NL then
               Line := Line + 1;
               I := I + 1;
            elsif C = ' ' or else C = ASCII.HT or else C = ASCII.CR then
               I := I + 1;
            elsif C = '/' and then I < Source'Last and then Source (I + 1) = '/' then
               while I <= Source'Last and then Source (I) /= NL loop
                  I := I + 1;
               end loop;
            elsif C = '/' and then I < Source'Last and then Source (I + 1) = '*' then
               I := I + 2;
               while I < Source'Last
                 and then not (Source (I) = '*' and then Source (I + 1) = '/')
               loop
                  if Source (I) = NL then
                     Line := Line + 1;
                  end if;
                  I := I + 1;
               end loop;
               I := I + 2;
            elsif Is_Ident_Start (C) then
               declare
                  Start : constant Natural := I;
               begin
                  while I <= Source'Last and then Is_Ident_Char (Source (I)) loop
                     I := I + 1;
                  end loop;
                  Toks.Append
                    ((T_Ident, To_Unbounded_String (Source (Start .. I - 1)), Line));
               end;
            elsif Is_Digit (C) or else (C = '-' and then I < Source'Last
                                        and then Is_Digit (Source (I + 1)))
            then
               declare
                  Start : constant Natural := I;
               begin
                  I := I + 1;  -- consume first digit or sign
                  while I <= Source'Last
                    and then (Is_Alphanumeric (Source (I)) or else Source (I) = '.')
                  loop
                     I := I + 1;
                  end loop;
                  Toks.Append
                    ((T_Number, To_Unbounded_String (Source (Start .. I - 1)), Line));
               end;
            elsif C = '"' or else C = ''' then
               declare
                  Quote : constant Character := C;
                  Start : constant Natural := I + 1;
               begin
                  I := I + 1;
                  while I <= Source'Last and then Source (I) /= Quote loop
                     I := I + 1;
                  end loop;
                  Toks.Append
                    ((T_String, To_Unbounded_String (Source (Start .. I - 1)), Line));
                  I := I + 1;
               end;
            else
               Toks.Append ((T_Symbol, To_Unbounded_String (String'(1 => C)), Line));
               I := I + 1;
            end if;
         end;
      end loop;
      Toks.Append ((T_EOF, Null_Unbounded_String, Line));
      return Toks;
   end Lex;

   ---------------------------------------------------------------------------
   --  Parser
   ---------------------------------------------------------------------------

   procedure Parse
     (Toks  : Token_Vectors.Vector;
      Pkg   : out Unbounded_String;
      Msgs  : out Message_Vectors.Vector;
      Enums : out Enum_Vectors.Vector)
   is
      P : Positive := Toks.First_Index;

      function Cur return Token is (Toks (P));

      procedure Err (Message : String) is
      begin
         raise Compile_Error with "line" & Cur.Line'Image & ": " & Message;
      end Err;

      procedure Adv is
      begin
         if Cur.Kind /= T_EOF then
            P := P + 1;
         end if;
      end Adv;

      function At_Symbol (S : String) return Boolean is
        (Cur.Kind = T_Symbol and then To_String (Cur.Text) = S);

      function At_Ident (S : String) return Boolean is
        (Cur.Kind = T_Ident and then To_String (Cur.Text) = S);

      procedure Expect_Symbol (S : String) is
      begin
         if not At_Symbol (S) then
            Err ("expected '" & S & "'");
         end if;
         Adv;
      end Expect_Symbol;

      function Expect_Ident return String is
      begin
         if Cur.Kind /= T_Ident then
            Err ("expected identifier");
         end if;
         return Result : constant String := To_String (Cur.Text) do
            Adv;
         end return;
      end Expect_Ident;

      procedure Skip_To_Semicolon is
      begin
         while not At_Symbol (";") and then Cur.Kind /= T_EOF loop
            Adv;
         end loop;
         Expect_Symbol (";");
      end Skip_To_Semicolon;

      function Parse_Dotted return Unbounded_String is
         R : Unbounded_String := To_Unbounded_String (Expect_Ident);
      begin
         while At_Symbol (".") loop
            Adv;
            Append (R, ".");
            Append (R, Expect_Ident);
         end loop;
         return R;
      end Parse_Dotted;

      function Parse_Int return Integer is
      begin
         if Cur.Kind /= T_Number then
            Err ("expected integer");
         end if;
         return V : Integer do
            begin
               V := Integer'Value (To_String (Cur.Text));
            exception
               when Constraint_Error =>
                  Err ("invalid integer literal");
            end;
            Adv;
         end return;
      end Parse_Int;

      procedure Skip_Field_Options is
      begin
         if At_Symbol ("[") then
            while not At_Symbol ("]") and then Cur.Kind /= T_EOF loop
               Adv;
            end loop;
            Expect_Symbol ("]");
         end if;
      end Skip_Field_Options;

      --  Like Skip_Field_Options, but records an explicit [packed=true|false]
      --  into F (other options are skipped). Used for ordinary field decls,
      --  where the packed wire layout of a repeated scalar can be overridden.
      procedure Parse_Field_Options (F : in out Field_Def) is
      begin
         if At_Symbol ("[") then
            while not At_Symbol ("]") and then Cur.Kind /= T_EOF loop
               if At_Ident ("packed") then
                  Adv;
                  if At_Symbol ("=") then
                     Adv;
                     F.Packed_Set := True;
                     F.Packed := At_Ident ("true");
                  end if;
               else
                  Adv;
               end if;
            end loop;
            Expect_Symbol ("]");
         end if;
      end Parse_Field_Options;

      --  Qualify a type name with its enclosing scope (empty Prefix = top level).
      function Qualify (Prefix, Name : String) return String is
        (if Prefix = "" then Name else Prefix & "." & Name);

      procedure Parse_Enum (Prefix : String) is
         E : Enum_Def;
      begin
         Adv;  -- 'enum'
         E.Name := To_Unbounded_String (Qualify (Prefix, Expect_Ident));
         Expect_Symbol ("{");
         while not At_Symbol ("}") and then Cur.Kind /= T_EOF loop
            if At_Symbol (";") then
               Adv;
            elsif At_Ident ("option") or else At_Ident ("reserved") then
               Skip_To_Semicolon;
            else
               declare
                  V : Enum_Value;
               begin
                  V.Name := To_Unbounded_String (Expect_Ident);
                  Expect_Symbol ("=");
                  V.Number := Parse_Int;
                  Skip_Field_Options;
                  Expect_Symbol (";");
                  E.Values.Append (V);
               end;
            end if;
         end loop;
         Expect_Symbol ("}");
         Enums.Append (E);
      end Parse_Enum;

      procedure Parse_Message (Prefix : String) is
         M     : Message_Def;
         FQ    : Unbounded_String;
      begin
         Adv;  -- 'message'
         M.Name := To_Unbounded_String (Qualify (Prefix, Expect_Ident));
         FQ := M.Name;
         Expect_Symbol ("{");
         while not At_Symbol ("}") and then Cur.Kind /= T_EOF loop
            if At_Symbol (";") then
               Adv;
            elsif At_Ident ("reserved") or else At_Ident ("option") then
               Skip_To_Semicolon;
            elsif At_Ident ("message") then
               Parse_Message (To_String (FQ));
            elsif At_Ident ("enum") then
               Parse_Enum (To_String (FQ));
            elsif At_Ident ("map") then
               Adv;  -- 'map'
               Expect_Symbol ("<");
               declare
                  F : Field_Def;
               begin
                  F.Is_Map := True;
                  F.Map_Key := To_Unbounded_String (Expect_Ident);
                  Expect_Symbol (",");
                  F.Map_Value := Parse_Dotted;
                  Expect_Symbol (">");
                  F.Proto_Type := To_Unbounded_String ("map");
                  F.Name := To_Unbounded_String (Expect_Ident);
                  Expect_Symbol ("=");
                  F.Number := Positive (Parse_Int);
                  Skip_Field_Options;
                  Expect_Symbol (";");
                  M.Fields.Append (F);
               end;
            elsif At_Ident ("oneof") then
               Adv;
               declare
                  OName : constant String := Expect_Ident;
               begin
                  Expect_Symbol ("{");
                  while not At_Symbol ("}") and then Cur.Kind /= T_EOF loop
                     if At_Symbol (";") then
                        Adv;
                     elsif At_Ident ("option") then
                        Skip_To_Semicolon;
                     else
                        declare
                           F : Field_Def;
                        begin
                           F.Proto_Type := Parse_Dotted;
                           F.Name := To_Unbounded_String (Expect_Ident);
                           Expect_Symbol ("=");
                           F.Number := Positive (Parse_Int);
                           Skip_Field_Options;
                           Expect_Symbol (";");
                           F.Oneof := To_Unbounded_String (OName);
                           M.Fields.Append (F);
                        end;
                     end if;
                  end loop;
                  Expect_Symbol ("}");
               end;
            else
               declare
                  F : Field_Def;
               begin
                  if At_Ident ("repeated") then
                     F.Repeated := True;
                     Adv;
                  elsif At_Ident ("optional") then
                     F.Optional := True;
                     Adv;
                  end if;
                  F.Proto_Type := Parse_Dotted;
                  F.Name := To_Unbounded_String (Expect_Ident);
                  Expect_Symbol ("=");
                  F.Number := Positive (Parse_Int);
                  Parse_Field_Options (F);
                  Expect_Symbol (";");
                  M.Fields.Append (F);
               end;
            end if;
         end loop;
         Expect_Symbol ("}");
         Msgs.Append (M);
      end Parse_Message;

   begin
      Pkg := Null_Unbounded_String;
      while Cur.Kind /= T_EOF loop
         if At_Ident ("syntax") then
            Adv;
            Expect_Symbol ("=");
            if Cur.Kind /= T_String then
               Err ("expected syntax string");
            end if;
            if To_String (Cur.Text) /= "proto3" then
               Err ("only proto3 is supported");
            end if;
            Adv;
            Expect_Symbol (";");
         elsif At_Ident ("package") then
            Adv;
            Pkg := Parse_Dotted;
            Expect_Symbol (";");
         elsif At_Ident ("import") or else At_Ident ("option") then
            Adv;
            Skip_To_Semicolon;
         elsif At_Ident ("message") then
            Parse_Message ("");
         elsif At_Ident ("enum") then
            Parse_Enum ("");
         elsif At_Symbol (";") then
            Adv;
         else
            Err ("unexpected token '" & To_String (Cur.Text) & "'");
         end if;
      end loop;
   end Parse;

   ---------------------------------------------------------------------------
   --  Type mapping
   ---------------------------------------------------------------------------

   type Type_Category is (Cat_Int, Cat_Float, Cat_Bool, Cat_Str, Cat_Message);

   type Type_Info is record
      Ada_Type   : Unbounded_String;
      Default    : Unbounded_String;
      Suffix     : Unbounded_String;  --  Add_<Suffix> / As_<Suffix>
      Array_Type : Unbounded_String;  --  Protobuf.<Array_Type> for packed
      Category   : Type_Category := Cat_Int;
      Is_WKT     : Boolean := False;  --  a google.protobuf.* well-known type
      Is_Null    : Boolean := False;  --  google.protobuf.NullValue (JSON null)
   end record;

   function Info
     (Ada_Type, Default, Suffix, Array_Type : String; Category : Type_Category)
      return Type_Info
   is
   begin
      return
        (To_Unbounded_String (Ada_Type),
         To_Unbounded_String (Default),
         To_Unbounded_String (Suffix),
         To_Unbounded_String (Array_Type),
         Category,
         Is_WKT  => False,
         Is_Null => False);
   end Info;

   --  Map a google.protobuf.* type name to its Proto_WKT Ada type name, or ""
   --  if it is not a (supported) well-known type.
   function WKT_Ada (Proto : String) return String is
   begin
      if Proto = "google.protobuf.Empty" then return "Empty";
      elsif Proto = "google.protobuf.Int32Value" then return "Int32_Value";
      elsif Proto = "google.protobuf.Int64Value" then return "Int64_Value";
      elsif Proto = "google.protobuf.UInt32Value" then return "UInt32_Value";
      elsif Proto = "google.protobuf.UInt64Value" then return "UInt64_Value";
      elsif Proto = "google.protobuf.FloatValue" then return "Float_Value";
      elsif Proto = "google.protobuf.DoubleValue" then return "Double_Value";
      elsif Proto = "google.protobuf.BoolValue" then return "Bool_Value";
      elsif Proto = "google.protobuf.StringValue" then return "String_Value";
      elsif Proto = "google.protobuf.BytesValue" then return "Bytes_Value";
      elsif Proto = "google.protobuf.Duration" then return "Duration";
      elsif Proto = "google.protobuf.Timestamp" then return "Timestamp";
      elsif Proto = "google.protobuf.FieldMask" then return "Field_Mask";
      elsif Proto = "google.protobuf.Struct" then return "Struct";
      elsif Proto = "google.protobuf.Value" then return "Value";
      elsif Proto = "google.protobuf.ListValue" then return "List_Value";
      elsif Proto = "google.protobuf.Any" then return "Any";
      else return "";
      end if;
   end WKT_Ada;

   --  The Ada type mark for a message/WKT type. WKT type marks are qualified
   --  (Proto_WKT.<X>) so they are never shadowed by, e.g., Standard.Duration.
   function Msg_Type_Mark (T : Type_Info) return String is
     (if T.Is_WKT then "Proto_WKT." & To_String (T.Ada_Type)
      else To_String (T.Ada_Type));

   --  The binary parse function name for a message/WKT type.
   function Msg_Parse_Fn (T : Type_Info) return String is
     (if T.Is_WKT then "Proto_WKT.Parse_" & To_String (T.Ada_Type)
      else "Parse_" & To_String (T.Ada_Type));

   function Map_Scalar (Proto : String; Found : out Boolean) return Type_Info is
   begin
      Found := True;
      if Proto = "int32" then
         return Info ("Interfaces.Integer_32", "0", "Int32", "Int32_Array", Cat_Int);
      elsif Proto = "int64" then
         return Info ("Interfaces.Integer_64", "0", "Int64", "Int64_Array", Cat_Int);
      elsif Proto = "uint32" then
         return Info ("Interfaces.Unsigned_32", "0", "UInt32", "UInt32_Array", Cat_Int);
      elsif Proto = "uint64" then
         return Info ("Interfaces.Unsigned_64", "0", "UInt64", "UInt64_Array", Cat_Int);
      elsif Proto = "sint32" then
         return Info ("Interfaces.Integer_32", "0", "SInt32", "Int32_Array", Cat_Int);
      elsif Proto = "sint64" then
         return Info ("Interfaces.Integer_64", "0", "SInt64", "Int64_Array", Cat_Int);
      elsif Proto = "fixed32" then
         return Info ("Interfaces.Unsigned_32", "0", "Fixed32", "Fixed32_Array", Cat_Int);
      elsif Proto = "fixed64" then
         return Info ("Interfaces.Unsigned_64", "0", "Fixed64", "Fixed64_Array", Cat_Int);
      elsif Proto = "sfixed32" then
         return Info ("Interfaces.Integer_32", "0", "SFixed32", "SFixed32_Array", Cat_Int);
      elsif Proto = "sfixed64" then
         return Info ("Interfaces.Integer_64", "0", "SFixed64", "SFixed64_Array", Cat_Int);
      elsif Proto = "float" then
         return Info ("Interfaces.IEEE_Float_32", "0.0", "Float", "Float_Array", Cat_Float);
      elsif Proto = "double" then
         return Info ("Interfaces.IEEE_Float_64", "0.0", "Double", "Double_Array", Cat_Float);
      elsif Proto = "bool" then
         return Info ("Boolean", "False", "Bool", "Bool_Array", Cat_Bool);
      elsif Proto = "string" then
         return Info
           ("Ada.Strings.Unbounded.Unbounded_String",
            "Ada.Strings.Unbounded.Null_Unbounded_String", "String", "", Cat_Str);
      elsif Proto = "bytes" then
         return Info
           ("Ada.Strings.Unbounded.Unbounded_String",
            "Ada.Strings.Unbounded.Null_Unbounded_String", "Bytes", "", Cat_Str);
      else
         Found := False;
         return Info ("", "", "", "", Cat_Int);
      end if;
   end Map_Scalar;

   ---------------------------------------------------------------------------
   --  Identifier helpers
   ---------------------------------------------------------------------------

   function Cap (S : String) return String is
      R : String := S;
   begin
      if R'Length > 0 then
         R (R'First) := To_Upper (R (R'First));
      end if;
      return R;
   end Cap;

   Reserved_Words : constant String :=
     " abort abs abstract accept access aliased all and array at begin body "
     & "case constant declare delay delta digits do else elsif end entry "
     & "exception exit for function generic goto if in interface is limited "
     & "loop mod new not null of or others out overriding package pragma "
     & "private procedure protected raise range record rem renames requeue "
     & "return reverse select separate some subtype synchronized tagged task "
     & "terminate then type until use when while with xor ";

   function Is_Reserved (Lower_Name : String) return Boolean is
   begin
      return Ada.Strings.Fixed.Index (Reserved_Words, " " & Lower_Name & " ") > 0;
   end Is_Reserved;

   --  Map one proto identifier segment to a legal Ada identifier. proto field
   --  names may carry leading, trailing, or doubled underscores (the proto3
   --  JSON field-name edge cases, e.g. "_field_name3", "field__name4_") which
   --  are illegal in Ada, so those are stripped/collapsed here. The capitalised
   --  result has reserved words suffixed "_F". NOTE: this affects only the
   --  internal Ada identifier; the wire field number and the emitted JSON name
   --  (Json_Name) are independent, so JSON round-tripping is unaffected.
   function Ada_Seg (Proto_Name : String) return String is
      R               : Unbounded_String;
      Prev_Underscore : Boolean := True;  --  start True to drop leading "_"
   begin
      for C of Proto_Name loop
         if C = '_' then
            --  Emit at most one underscore per run, never a leading one.
            if not Prev_Underscore then
               Append (R, '_');
               Prev_Underscore := True;
            end if;
         else
            Append (R, C);
            Prev_Underscore := False;
         end if;
      end loop;
      --  Drop a trailing underscore left by the loop.
      if Length (R) > 0 and then Element (R, Length (R)) = '_' then
         Delete (R, Length (R), Length (R));
      end if;
      declare
         Core : constant String :=
           (if Length (R) = 0 then "Field"
            elsif Is_Digit (Element (R, 1)) then "F_" & To_String (R)
            else Cap (To_String (R)));
      begin
         if Is_Reserved (To_Lower (Core)) then
            return Core & "_F";
         else
            return Core;
         end if;
      end;
   end Ada_Seg;

   --  Map a (possibly dotted) proto type name to an Ada identifier. A nested
   --  type's fully-qualified name "Outer.Inner" flattens to "Outer_Inner",
   --  each segment escaped independently. Simple names pass through unchanged.
   function Ada_Id (Proto_Name : String) return String is
      R     : Unbounded_String;
      Start : Natural := Proto_Name'First;
   begin
      for I in Proto_Name'Range loop
         if Proto_Name (I) = '.' then
            Append (R, Ada_Seg (Proto_Name (Start .. I - 1)));
            Append (R, '_');
            Start := I + 1;
         end if;
      end loop;
      Append (R, Ada_Seg (Proto_Name (Start .. Proto_Name'Last)));
      return To_String (R);
   end Ada_Id;

   --  proto3 JSON field name: snake_case -> lowerCamelCase.
   function Json_Name (Proto_Name : String) return String is
      R : Unbounded_String;
      Upper_Next : Boolean := False;
   begin
      for C of Proto_Name loop
         if C = '_' then
            Upper_Next := True;
         elsif Upper_Next then
            Append (R, To_Upper (C));
            Upper_Next := False;
         else
            Append (R, C);
         end if;
      end loop;
      return To_String (R);
   end Json_Name;

   function Ada_Unit_Name (Dotted : String) return String is
      R : Unbounded_String;
      At_Start : Boolean := True;
   begin
      for C of Dotted loop
         if C = '.' then
            Append (R, '_');
            At_Start := True;
         else
            Append (R, (if At_Start then To_Upper (C) else C));
            At_Start := False;
         end if;
      end loop;
      return To_String (R);
   end Ada_Unit_Name;

   --  Vector instance package name for a repeated field's element Ada type:
   --  strip library prefixes and append "_Vectors".
   function Vector_Pkg (Ada_Type : String) return String is
      Last_Dot : Natural := 0;
   begin
      for I in Ada_Type'Range loop
         if Ada_Type (I) = '.' then
            Last_Dot := I;
         end if;
      end loop;
      return Ada_Type (Last_Dot + 1 .. Ada_Type'Last) & "_Vectors";
   end Vector_Pkg;

   ---------------------------------------------------------------------------
   --  Code generation
   ---------------------------------------------------------------------------

   procedure Write_File (Path : String; Content : String) is
      use Ada.Text_IO;
      F : File_Type;
   begin
      Create (F, Out_File, Path);
      Put (F, Content);
      Close (F);
   end Write_File;

   procedure Generate (Proto_Path : String; Out_Dir : String) is

      function Read_File (Path : String) return String is
         use Ada.Streams;
         use Ada.Streams.Stream_IO;
         F : File_Type;
      begin
         Open (F, In_File, Path);
         declare
            Length : constant Natural := Natural (Size (F));
            Data   : Stream_Element_Array
              (1 .. Stream_Element_Offset (Integer'Max (1, Length)));
            Last   : Stream_Element_Offset := 0;
         begin
            if Length > 0 then
               Read (F, Data, Last);
            end if;
            Close (F);
            return Result : String (1 .. Natural (Last)) do
               for I in Result'Range loop
                  Result (I) := Character'Val (Data (Stream_Element_Offset (I)));
               end loop;
            end return;
         end;
      end Read_File;

      Source : constant String := Read_File (Proto_Path);
      Toks   : constant Token_Vectors.Vector := Lex (Source);
      Pkg    : Unbounded_String;
      Msgs   : Message_Vectors.Vector;
      Enums  : Enum_Vectors.Vector;

      Enum_Names : String_Vectors.Vector;

      function Is_Enum (Proto : String) return Boolean is
      begin
         for N of Enum_Names loop
            if To_String (N) = Proto then
               return True;
            end if;
         end loop;
         return False;
      end Is_Enum;

      function Is_Message (Proto : String) return Boolean is
      begin
         for M of Msgs loop
            if To_String (M.Name) = Proto then
               return True;
            end if;
         end loop;
         return False;
      end Is_Message;

      --  Resolve a field's proto type to Ada/runtime info. Enums are encoded
      --  exactly as int32 on the wire; message fields carry the Ada record type
      --  name in Ada_Type (the holder/vector wrappers are derived from it).
      function Resolve (Proto : String) return Type_Info is
         Found : Boolean;
         T     : constant Type_Info := Map_Scalar (Proto, Found);
      begin
         if Found then
            return T;
         elsif Proto = "google.protobuf.NullValue" then
            --  A well-known *enum*: int32 on the wire (its only value,
            --  NULL_VALUE, is 0), but JSON null. Modelled as a plain int32 so
            --  the wire path is automatic; Is_Null drives the JSON mapping.
            return (Ada_Type   => To_Unbounded_String ("Interfaces.Integer_32"),
                    Default    => To_Unbounded_String ("0"),
                    Suffix     => To_Unbounded_String ("Int32"),
                    Array_Type => To_Unbounded_String ("Int32_Array"),
                    Category   => Cat_Int,
                    Is_WKT     => False,
                    Is_Null    => True);
         elsif Is_Enum (Proto) then
            return Info (Ada_Id (Proto), "0", "Int32", "Int32_Array", Cat_Int);
         elsif Is_Message (Proto) then
            return Info (Ada_Id (Proto), "", "Message", "", Cat_Message);
         elsif WKT_Ada (Proto) /= "" then
            --  A well-known type: a message-category type whose Ada type is the
            --  Proto_WKT.<X> external type (Is_WKT drives holder generation).
            return (Ada_Type   => To_Unbounded_String (WKT_Ada (Proto)),
                    Default    => Null_Unbounded_String,
                    Suffix     => To_Unbounded_String ("Message"),
                    Array_Type => Null_Unbounded_String,
                    Category   => Cat_Message,
                    Is_WKT     => True,
                    Is_Null    => False);
         else
            raise Compile_Error
              with "field type '" & Proto
                   & "' is not a scalar, enum, message, or known google.protobuf type";
         end if;
      end Resolve;

      function Simple (Ada_Type : String) return String is
         Dot : Natural := Ada_Type'First - 1;
      begin
         for I in Ada_Type'Range loop
            if Ada_Type (I) = '.' then
               Dot := I;
            end if;
         end loop;
         return Ada_Type (Dot + 1 .. Ada_Type'Last);
      end Simple;

      function Map_Pkg (Key_Ada, Val_Ada : String) return String is
        (Simple (Key_Ada) & "_" & Simple (Val_Ada) & "_Maps");

      --  Build an Unbounded_String from a raw String expression, validating
      --  UTF-8 for `string` (Suffix = "String") but not for `bytes`.
      function Str_Decode (Suffix, Raw : String) return String is
        (if Suffix = "Bytes" then "To_Unbounded_String (" & Raw & ")"
         else "To_Unbounded_String (Proto_JSON.Checked_UTF8 (" & Raw & "))");

      --  Decode expression for a value of type T from a parsed field named Item.
      function Decode_Expr (T : Type_Info; Item : String) return String is
        (if T.Category = Cat_Str then
            Str_Decode (To_String (T.Suffix),
                        "Protobuf.As_" & To_String (T.Suffix) & " (" & Item & ")")
         elsif T.Category = Cat_Message then
            "Parse_" & To_String (T.Ada_Type)
            & " (Protobuf.As_Message_Bytes (" & Item & "))"
         else
            "Protobuf.As_" & To_String (T.Suffix) & " (" & Item & ")");

      --  A field's Ada component identifier. For a singular field whose name
      --  equals its own (simple) type name, suffix "_F" so the component does
      --  not shadow the type mark (e.g. "color : Color" -> "Color_F : Color").
      function Field_Ident (F : Field_Def) return String is
         C : constant String := Ada_Id (To_String (F.Name));
      begin
         if F.Is_Map
           or else F.Repeated
           or else Resolve (To_String (F.Proto_Type)).Category = Cat_Message
         then
            return C;
         end if;
         declare
            Full : constant String :=
              To_String (Resolve (To_String (F.Proto_Type)).Ada_Type);
            Dot  : Natural := 0;
         begin
            for I in Full'Range loop
               if Full (I) = '.' then
                  Dot := I;
               end if;
            end loop;
            if To_Lower (C) = To_Lower (Full (Dot + 1 .. Full'Last)) then
               return C & "_F";
            else
               return C;
            end if;
         end;
      end Field_Ident;

      --  Identifier for a oneof variant member. Unlike a regular message field
      --  (which is wrapped in a holder), a oneof member's component type is the
      --  bare type, so a name equal to that type must be escaped.
      function Oneof_Member_Ident (F : Field_Def) return String is
         C    : constant String := Ada_Id (To_String (F.Name));
         Full : constant String :=
           To_String (Resolve (To_String (F.Proto_Type)).Ada_Type);
         Dot  : Natural := 0;
      begin
         for I in Full'Range loop
            if Full (I) = '.' then
               Dot := I;
            end if;
         end loop;
         if To_Lower (C) = To_Lower (Full (Dot + 1 .. Full'Last)) then
            return C & "_F";
         else
            return C;
         end if;
      end Oneof_Member_Ident;

   begin
      Parse (Toks, Pkg, Msgs, Enums);

      --  Resolve every field's type reference to the fully-qualified name of the
      --  type it denotes, using proto's innermost-out scope search. Nested types
      --  are flattened into Msgs/Enums under dotted FQ names ("Outer.Inner"); a
      --  reference like "Inner" from within "Outer" must bind to "Outer.Inner"
      --  here, so that code generation thereafter matches purely by FQ name.
      declare
         function Is_Declared (Name : String) return Boolean is
         begin
            for M of Msgs loop
               if To_String (M.Name) = Name then
                  return True;
               end if;
            end loop;
            for E of Enums loop
               if To_String (E.Name) = Name then
                  return True;
               end if;
            end loop;
            return False;
         end Is_Declared;

         --  The FQ declared type a reference binds to within Scope, or "" if it
         --  is not a user-declared type (scalar / google.protobuf.* / unknown).
         function Resolve_Ref (Ref, Scope : String) return String is
            S : Unbounded_String := To_Unbounded_String (Scope);
         begin
            loop
               declare
                  Cand : constant String :=
                    (if Length (S) = 0 then Ref
                     else To_String (S) & "." & Ref);
               begin
                  if Is_Declared (Cand) then
                     return Cand;
                  end if;
               end;
               exit when Length (S) = 0;
               --  Ascend to the enclosing scope (strip the last dotted segment).
               declare
                  Cur_S : constant String := To_String (S);
                  Dot   : Natural := 0;
               begin
                  for I in Cur_S'Range loop
                     if Cur_S (I) = '.' then
                        Dot := I;
                     end if;
                  end loop;
                  S := To_Unbounded_String
                         (if Dot = 0 then "" else Cur_S (Cur_S'First .. Dot - 1));
               end;
            end loop;
            return "";
         end Resolve_Ref;
      begin
         for MI in Msgs.First_Index .. Msgs.Last_Index loop
            declare
               M     : Message_Def := Msgs (MI);
               Scope : constant String := To_String (M.Name);
            begin
               for FI in M.Fields.First_Index .. M.Fields.Last_Index loop
                  declare
                     F : Field_Def := M.Fields (FI);
                  begin
                     if F.Is_Map then
                        declare
                           R : constant String :=
                             Resolve_Ref (To_String (F.Map_Value), Scope);
                        begin
                           if R /= "" then
                              F.Map_Value := To_Unbounded_String (R);
                              M.Fields.Replace_Element (FI, F);
                           end if;
                        end;
                     else
                        declare
                           R : constant String :=
                             Resolve_Ref (To_String (F.Proto_Type), Scope);
                        begin
                           if R /= "" then
                              F.Proto_Type := To_Unbounded_String (R);
                              M.Fields.Replace_Element (FI, F);
                           end if;
                        end;
                     end if;
                  end;
               end loop;
               Msgs.Replace_Element (MI, M);
            end;
         end loop;
      end;

      for E of Enums loop
         Enum_Names.Append (E.Name);
      end loop;

      declare
         Unit      : constant String :=
           Ada_Unit_Name (if Length (Pkg) > 0 then To_String (Pkg) else "Proto");
         File_Base : constant String := To_Lower (Unit);
         Spec      : Unbounded_String;
         Body_Text : Unbounded_String;

         Vec_Types : String_Vectors.Vector;  --  scalar/enum repeated elem types
         Msg_Hold  : String_Vectors.Vector;  --  message types used singular
         Msg_Vec   : String_Vectors.Vector;  --  message types used repeated
         Wkt_Hold  : String_Vectors.Vector;  --  WKT types used singular
         Wkt_Vec   : String_Vectors.Vector;  --  WKT types used repeated
         Map_Top   : String_Vectors.Vector;  --  "Key|Val" maps, scalar/enum value
         Map_Msg   : String_Vectors.Vector;  --  "Key|Val" maps, message value
         Has_Repeated        : Boolean := False;  --  any repeated -> with Vectors
         Has_Packed_Repeated : Boolean := False;  --  repeated scalar -> Wire_Type
         Has_Map             : Boolean := False;
         Has_WKT             : Boolean := False;  --  any well-known type used

         function Bar_Before (S : String) return String is
           (S (S'First .. Ada.Strings.Fixed.Index (S, "|") - 1));
         function Bar_After (S : String) return String is
           (S (Ada.Strings.Fixed.Index (S, "|") + 1 .. S'Last));

         N_Msgs : constant Natural := Natural (Msgs.Length);
         Order  : Nat_Vectors.Vector;

         procedure SL (To : in out Unbounded_String; Line : String) is
         begin
            Append (To, Line);
            Append (To, NL);
         end SL;

         function In_Set (S : String_Vectors.Vector; V : String) return Boolean is
         begin
            for E of S loop
               if To_String (E) = V then
                  return True;
               end if;
            end loop;
            return False;
         end In_Set;

         procedure Add_Once (S : in out String_Vectors.Vector; V : String) is
         begin
            if not In_Set (S, V) then
               S.Append (To_Unbounded_String (V));
            end if;
         end Add_Once;

         --  oneof generated-identifier helpers (TName = the message Ada type).
         function Sel_Type (TName, O : String) return String is
           (TName & "_" & Cap (O) & "_Selector");
         function One_Type (TName, O : String) return String is
           (TName & "_" & Cap (O) & "_Oneof");
         function Lit_NotSet (TName, O : String) return String is
           (TName & "_" & Cap (O) & "_Not_Set");
         function Lit_Mem (TName, O, Member : String) return String is
           (TName & "_" & Cap (O) & "_" & Cap (Member));

         function Oneof_Names (M : Message_Def) return String_Vectors.Vector is
            R : String_Vectors.Vector;
         begin
            for F of M.Fields loop
               if Length (F.Oneof) > 0
                 and then not In_Set (R, To_String (F.Oneof))
               then
                  R.Append (F.Oneof);
               end if;
            end loop;
            return R;
         end Oneof_Names;
      begin
         --  Discover required container instances per field shape.
         for M of Msgs loop
            for F of M.Fields loop
               if F.Is_Map then
                  Has_Map := True;
                  declare
                     KT  : constant Type_Info := Resolve (To_String (F.Map_Key));
                     VT  : constant Type_Info := Resolve (To_String (F.Map_Value));
                     Key : constant String := To_String (KT.Ada_Type)
                                              & "|" & To_String (VT.Ada_Type);
                  begin
                     if VT.Category = Cat_Message then
                        --  Message- or WKT-valued map: the value is stored as a
                        --  controlled holder (same shape for both). A WKT used
                        --  only here still needs its holder + Proto_WKT import.
                        Add_Once (Map_Msg, Key);
                        if VT.Is_WKT then
                           Has_WKT := True;
                           Add_Once (Wkt_Hold, To_String (VT.Ada_Type));
                        end if;
                     else
                        Add_Once (Map_Top, Key);
                     end if;
                  end;
               else
                  declare
                     T : constant Type_Info := Resolve (To_String (F.Proto_Type));
                  begin
                     if T.Is_WKT then
                        Has_WKT := True;
                     end if;
                     if F.Repeated then
                        Has_Repeated := True;
                        if T.Is_WKT then
                           Add_Once (Wkt_Vec, To_String (T.Ada_Type));
                        elsif T.Category = Cat_Message then
                           Add_Once (Msg_Vec, To_String (T.Ada_Type));
                        else
                           Has_Packed_Repeated :=
                             Has_Packed_Repeated or else T.Category /= Cat_Str;
                           Add_Once (Vec_Types, To_String (T.Ada_Type));
                        end if;
                     elsif T.Is_WKT then
                        Add_Once (Wkt_Hold, To_String (T.Ada_Type));
                     elsif T.Category = Cat_Message then
                        Add_Once (Msg_Hold, To_String (T.Ada_Type));
                     end if;
                  end;
               end if;
            end loop;
         end loop;

         --  Forward declarations of all message types let records reference one
         --  another (including recursively) in any order, so file order is fine.
         for K in 1 .. N_Msgs loop
            Order.Append (K);
         end loop;

         --  Specification ---------------------------------------------------
         SL (Spec, "--  Generated by protoc-ada from "
                   & Ada.Directories.Simple_Name (Proto_Path));
         SL (Spec, "--  Do not edit by hand.");
         SL (Spec, "with Interfaces;");
         SL (Spec, "with Ada.Strings.Unbounded;");
         SL (Spec, "with JSON;");
         if Has_Repeated then
            SL (Spec, "with Ada.Containers.Vectors;");
         end if;
         if N_Msgs > 0 then
            SL (Spec, "with Ada.Finalization;");
         end if;
         if Has_Map then
            SL (Spec, "with Ada.Containers.Ordered_Maps;");
         end if;
         if Has_WKT then
            SL (Spec, "with Proto_WKT;");
         end if;
         SL (Spec, "package " & Unit & " is");
         SL (Spec, "");
         --  Make Interfaces.Integer_32 operators directly visible so negative
         --  enum constants (e.g. NEG = -1) elaborate without a qualified "-".
         SL (Spec, "   use type Interfaces.Integer_32;");
         SL (Spec, "");

         --  Enums (open enums: int32-valued subtype + named constants).
         for E of Enums loop
            declare
               EName : constant String := Ada_Id (To_String (E.Name));
            begin
               SL (Spec, "   subtype " & EName & " is Interfaces.Integer_32;");
               for V of E.Values loop
                  SL (Spec, "   " & EName & "_" & Cap (To_String (V.Name))
                            & " : constant " & EName & " :="
                            & V.Number'Image & ";");
               end loop;
               SL (Spec, "   function " & EName & "_To_JSON (V : " & EName
                         & ") return JSON.JSON_Value;");
               SL (Spec, "   function " & EName & "_From_JSON (V : JSON.JSON_Value)"
                         & " return " & EName & ";");
               SL (Spec, "");
            end;
         end loop;

         --  Forward declaration + memory-safe controlled holder per message.
         --  The holder owns an access to the (still incomplete) record, which is
         --  what lets recursive and mutually-recursive messages compile; Adjust
         --  deep-copies and Finalize frees, giving value semantics.
         for M of Msgs loop
            declare
               TName : constant String := Ada_Id (To_String (M.Name));
            begin
               SL (Spec, "   type " & TName & ";");
               SL (Spec, "   type " & TName & "_Access is access " & TName & ";");
               SL (Spec, "   type " & TName
                         & "_Holder is new Ada.Finalization.Controlled with record");
               SL (Spec, "      Ptr : " & TName & "_Access := null;");
               SL (Spec, "   end record;");
               SL (Spec, "   overriding procedure Adjust (H : in out "
                         & TName & "_Holder);");
               SL (Spec, "   overriding procedure Finalize (H : in out "
                         & TName & "_Holder);");
               --  Accessors declared here (before the holder type freezes), using
               --  the still-incomplete record type (allowed in Ada 2012).
               SL (Spec, "   function To_Holder (Value : " & TName & ") return "
                         & TName & "_Holder;");
               SL (Spec, "   function Element (H : " & TName & "_Holder) return "
                         & TName & ";");
               SL (Spec, "   function Is_Empty (H : " & TName
                         & "_Holder) return Boolean;");
               SL (Spec, "");
            end;
         end loop;

         --  Holders over external well-known types (Proto_WKT.<X>): same
         --  controlled-holder shape, but wrapping the complete external type
         --  (no forward declaration needed).
         declare
            Wkt_Used : String_Vectors.Vector;
         begin
            for W of Wkt_Hold loop
               Add_Once (Wkt_Used, To_String (W));
            end loop;
            for W of Wkt_Vec loop
               Add_Once (Wkt_Used, To_String (W));
            end loop;
            for Wn of Wkt_Used loop
               declare
                  W : constant String := To_String (Wn);
               begin
                  SL (Spec, "   type " & W & "_Access is access Proto_WKT." & W & ";");
                  SL (Spec, "   type " & W
                            & "_Holder is new Ada.Finalization.Controlled with record");
                  SL (Spec, "      Ptr : " & W & "_Access := null;");
                  SL (Spec, "   end record;");
                  SL (Spec, "   overriding procedure Adjust (H : in out "
                            & W & "_Holder);");
                  SL (Spec, "   overriding procedure Finalize (H : in out "
                            & W & "_Holder);");
                  SL (Spec, "   function To_Holder (Value : Proto_WKT." & W
                            & ") return " & W & "_Holder;");
                  SL (Spec, "   function Element (H : " & W & "_Holder) return "
                            & "Proto_WKT." & W & ";");
                  SL (Spec, "   function Is_Empty (H : " & W
                            & "_Holder) return Boolean;");
                  SL (Spec, "");
               end;
            end loop;
         end;

         --  Scalar/enum repeated element vectors.
         for T of Vec_Types loop
            SL (Spec, "   use type " & To_String (T) & ";");
         end loop;
         for T of Vec_Types loop
            SL (Spec, "   package " & Vector_Pkg (To_String (T))
                      & " is new Ada.Containers.Vectors (Positive, "
                      & To_String (T) & ");");
         end loop;

         --  Repeated message fields: vectors of holders.
         for T of Msg_Vec loop
            SL (Spec, "   use type " & To_String (T) & "_Holder;");
            SL (Spec, "   package " & Vector_Pkg (To_String (T))
                      & " is new Ada.Containers.Vectors (Positive, "
                      & To_String (T) & "_Holder);");
         end loop;

         --  Repeated well-known-type fields: vectors of WKT holders.
         for T of Wkt_Vec loop
            SL (Spec, "   use type " & To_String (T) & "_Holder;");
            SL (Spec, "   package " & Vector_Pkg (To_String (T))
                      & " is new Ada.Containers.Vectors (Positive, "
                      & To_String (T) & "_Holder);");
         end loop;

         --  Maps with scalar/enum/string values.
         for E of Map_Top loop
            declare
               K : constant String := Bar_Before (To_String (E));
               V : constant String := Bar_After (To_String (E));
            begin
               SL (Spec, "   use type " & K & ";");
               SL (Spec, "   use type " & V & ";");
               SL (Spec, "   package " & Map_Pkg (K, V)
                         & " is new Ada.Containers.Ordered_Maps (" & K & ", "
                         & V & ");");
            end;
         end loop;

         --  Maps with message values: value is a holder.
         for E of Map_Msg loop
            declare
               K : constant String := Bar_Before (To_String (E));
               V : constant String := Bar_After (To_String (E));
            begin
               SL (Spec, "   use type " & K & ";");
               SL (Spec, "   use type " & V & "_Holder;");
               SL (Spec, "   package " & Map_Pkg (K, V)
                         & " is new Ada.Containers.Ordered_Maps (" & K & ", "
                         & V & "_Holder);");
            end;
         end loop;
         SL (Spec, "");

         --  Message record completions (any order; types are forward-declared).
         for M of Msgs loop
            declare
               TName : constant String := Ada_Id (To_String (M.Name));
               Done_Oneofs : String_Vectors.Vector;

               --  Ada type mark for a oneof member (holders wrap message members).
               function Member_Type (F : Field_Def) return String is
                  T : constant Type_Info := Resolve (To_String (F.Proto_Type));
               begin
                  if T.Category = Cat_Message then
                     return To_String (T.Ada_Type) & "_Holder";
                  else
                     return To_String (T.Ada_Type);
                  end if;
               end Member_Type;
            begin
               --  A discriminated (variant) record per oneof, before the record.
               for O of Oneof_Names (M) loop
                  declare
                     ON   : constant String := To_String (O);
                     Lits : Unbounded_String := To_Unbounded_String
                       ("     (" & Lit_NotSet (TName, ON));
                  begin
                     for F of M.Fields loop
                        if To_String (F.Oneof) = ON then
                           Append (Lits, ", "
                                   & Lit_Mem (TName, ON, To_String (F.Name)));
                        end if;
                     end loop;
                     Append (Lits, ")");
                     SL (Spec, "   type " & Sel_Type (TName, ON) & " is");
                     SL (Spec, To_String (Lits) & ";");
                     SL (Spec, "   type " & One_Type (TName, ON) & " (Which : "
                               & Sel_Type (TName, ON) & " := "
                               & Lit_NotSet (TName, ON) & ") is record");
                     SL (Spec, "      case Which is");
                     SL (Spec, "         when " & Lit_NotSet (TName, ON)
                               & " => null;");
                     for F of M.Fields loop
                        if To_String (F.Oneof) = ON then
                           SL (Spec, "         when "
                                     & Lit_Mem (TName, ON, To_String (F.Name))
                                     & " => " & Oneof_Member_Ident (F)
                                     & " : " & Member_Type (F) & ";");
                        end if;
                     end loop;
                     SL (Spec, "      end case;");
                     SL (Spec, "   end record;");
                  end;
               end loop;

               SL (Spec, "   type " & TName & " is record");
               if M.Fields.Is_Empty then
                  SL (Spec, "      null;");
               end if;
               for F of M.Fields loop
                  if F.Is_Map then
                     declare
                        KT : constant Type_Info := Resolve (To_String (F.Map_Key));
                        VT : constant Type_Info := Resolve (To_String (F.Map_Value));
                     begin
                        SL (Spec, "      " & Ada_Id (To_String (F.Name)) & " : "
                                  & Map_Pkg (To_String (KT.Ada_Type),
                                             To_String (VT.Ada_Type)) & ".Map;");
                     end;
                  else
                     declare
                        T : constant Type_Info := Resolve (To_String (F.Proto_Type));
                        C : constant String := Field_Ident (F);
                     begin
                        if Length (F.Oneof) > 0 then
                           if not In_Set (Done_Oneofs, To_String (F.Oneof)) then
                              Add_Once (Done_Oneofs, To_String (F.Oneof));
                              SL (Spec, "      " & Ada_Id (To_String (F.Oneof))
                                        & " : " & One_Type
                                          (TName, To_String (F.Oneof)) & ";");
                           end if;
                        elsif F.Repeated then
                           SL (Spec, "      " & C & " : "
                                     & Vector_Pkg (To_String (T.Ada_Type))
                                     & ".Vector;");
                        elsif T.Category = Cat_Message then
                           SL (Spec, "      " & C & " : "
                                     & To_String (T.Ada_Type) & "_Holder;");
                        else
                           SL (Spec, "      " & C & " : " & To_String (T.Ada_Type)
                                     & " := " & To_String (T.Default) & ";");
                           if F.Optional then
                              SL (Spec, "      " & C
                                        & "_Has : Boolean := False;");
                           end if;
                        end if;
                     end;
                  end if;
               end loop;
               SL (Spec, "   end record;");
               SL (Spec, "");
            end;
         end loop;

         --  (De)serialization, after all records.
         for M of Msgs loop
            declare
               TName : constant String := Ada_Id (To_String (M.Name));
            begin
               SL (Spec, "   function Serialize (Message : " & TName
                         & ") return String;");
               SL (Spec, "   function Parse_" & TName
                         & " (Data : String) return " & TName & ";");
               SL (Spec, "   function To_JSON (Message : " & TName
                         & ") return JSON.JSON_Value;");
               SL (Spec, "   function From_JSON (V : JSON.JSON_Value) return "
                         & TName & ";");
               SL (Spec, "");
            end;
         end loop;

         SL (Spec, "end " & Unit & ";");

         --  Body ------------------------------------------------------------
         SL (Body_Text, "--  Generated by protoc-ada. Do not edit by hand.");
         SL (Body_Text, "with Interfaces; use Interfaces;");
         SL (Body_Text, "with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;");
         SL (Body_Text, "with Protobuf;");
         SL (Body_Text, "with JSON;");
         SL (Body_Text, "use type JSON.Value_Kind;");
         SL (Body_Text, "with Proto_JSON;");
         if Has_WKT then
            SL (Body_Text, "with Proto_WKT; use Proto_WKT;");
         end if;
         if N_Msgs > 0 then
            SL (Body_Text, "with Ada.Unchecked_Deallocation;");
         end if;
         if Has_Packed_Repeated then
            SL (Body_Text, "use type Protobuf.Wire_Type;");
         end if;
         SL (Body_Text, "package body " & Unit & " is");
         SL (Body_Text, "");

         --  Controlled-holder operations per message type: Adjust deep-copies,
         --  Finalize frees, giving the holder by-value semantics.
         for M of Msgs loop
            declare
               TName : constant String := Ada_Id (To_String (M.Name));
            begin
               SL (Body_Text, "   procedure Free_" & TName
                              & " is new Ada.Unchecked_Deallocation ("
                              & TName & ", " & TName & "_Access);");
               SL (Body_Text, "   overriding procedure Adjust (H : in out "
                              & TName & "_Holder) is");
               SL (Body_Text, "   begin");
               SL (Body_Text, "      if H.Ptr /= null then H.Ptr := new "
                              & TName & "'(H.Ptr.all); end if;");
               SL (Body_Text, "   end Adjust;");
               SL (Body_Text, "   overriding procedure Finalize (H : in out "
                              & TName & "_Holder) is");
               SL (Body_Text, "   begin");
               SL (Body_Text, "      Free_" & TName & " (H.Ptr);");
               SL (Body_Text, "   end Finalize;");
               SL (Body_Text, "   function To_Holder (Value : " & TName
                              & ") return " & TName & "_Holder is");
               SL (Body_Text, "   begin");
               SL (Body_Text, "      return H : " & TName
                              & "_Holder do H.Ptr := new " & TName
                              & "'(Value); end return;");
               SL (Body_Text, "   end To_Holder;");
               SL (Body_Text, "   function Element (H : " & TName
                              & "_Holder) return " & TName & " is (H.Ptr.all);");
               SL (Body_Text, "   function Is_Empty (H : " & TName
                              & "_Holder) return Boolean is (H.Ptr = null);");
               SL (Body_Text, "");
            end;
         end loop;

         --  Holder operations over external well-known types.
         declare
            Wkt_Used : String_Vectors.Vector;
         begin
            for W of Wkt_Hold loop
               Add_Once (Wkt_Used, To_String (W));
            end loop;
            for W of Wkt_Vec loop
               Add_Once (Wkt_Used, To_String (W));
            end loop;
            for Wn of Wkt_Used loop
               declare
                  W : constant String := To_String (Wn);
                  P : constant String := "Proto_WKT." & W;
               begin
                  SL (Body_Text, "   procedure Free_" & W
                                 & " is new Ada.Unchecked_Deallocation ("
                                 & P & ", " & W & "_Access);");
                  SL (Body_Text, "   overriding procedure Adjust (H : in out "
                                 & W & "_Holder) is");
                  SL (Body_Text, "   begin");
                  SL (Body_Text, "      if H.Ptr /= null then H.Ptr := new "
                                 & P & "'(H.Ptr.all); end if;");
                  SL (Body_Text, "   end Adjust;");
                  SL (Body_Text, "   overriding procedure Finalize (H : in out "
                                 & W & "_Holder) is");
                  SL (Body_Text, "   begin");
                  SL (Body_Text, "      Free_" & W & " (H.Ptr);");
                  SL (Body_Text, "   end Finalize;");
                  SL (Body_Text, "   function To_Holder (Value : " & P
                                 & ") return " & W & "_Holder is");
                  SL (Body_Text, "   begin");
                  SL (Body_Text, "      return H : " & W
                                 & "_Holder do H.Ptr := new " & P
                                 & "'(Value); end return;");
                  SL (Body_Text, "   end To_Holder;");
                  SL (Body_Text, "   function Element (H : " & W
                                 & "_Holder) return " & P & " is (H.Ptr.all);");
                  SL (Body_Text, "   function Is_Empty (H : " & W
                                 & "_Holder) return Boolean is (H.Ptr = null);");
                  SL (Body_Text, "");
               end;
            end loop;
         end;

         --  Enum -> JSON: known values render as their name, unknown as number.
         for E of Enums loop
            declare
               EName : constant String := Ada_Id (To_String (E.Name));
            begin
               SL (Body_Text, "   function " & EName & "_To_JSON (V : " & EName
                              & ") return JSON.JSON_Value is");
               SL (Body_Text, "   begin");
               SL (Body_Text, "      case V is");
               for Val of E.Values loop
                  SL (Body_Text, "         when" & Val.Number'Image & " => return "
                                 & "JSON.To_Value (" & Q & To_String (Val.Name) & Q
                                 & ");");
               end loop;
               SL (Body_Text, "         when others => return JSON.Number "
                              & "(Proto_JSON.Image (Interfaces.Integer_64 (V)));");
               SL (Body_Text, "      end case;");
               SL (Body_Text, "   end " & EName & "_To_JSON;");
               SL (Body_Text, "   function " & EName & "_From_JSON (V : JSON.JSON_Value)"
                              & " return " & EName & " is");
               SL (Body_Text, "   begin");
               SL (Body_Text, "      if JSON.Kind (V) = JSON.JSON_String then");
               SL (Body_Text, "         declare");
               SL (Body_Text, "            S : constant String := JSON.As_String (V);");
               SL (Body_Text, "         begin");
               for Val of E.Values loop
                  SL (Body_Text, "            if S = " & Q & To_String (Val.Name) & Q
                                 & " then return" & Val.Number'Image & "; end if;");
               end loop;
               SL (Body_Text, "            raise Proto_JSON.Decode_Error with " & Q
                              & "unknown enum value name" & Q & ";");
               SL (Body_Text, "         end;");
               SL (Body_Text, "      else");
               SL (Body_Text, "         return " & EName
                              & " (Proto_JSON.To_Int64 (Proto_JSON.Scalar_Text (V)));");
               SL (Body_Text, "      end if;");
               SL (Body_Text, "   end " & EName & "_From_JSON;");
               SL (Body_Text, "");
            end;
         end loop;

         for OI in Order.First_Index .. Order.Last_Index loop
            declare
               M     : constant Message_Def := Msgs (Order (OI));
               TName : constant String := Ada_Id (To_String (M.Name));

               --  Encode one field into Buffer.
               procedure Emit_Encode (F : Field_Def) is
                  T : constant Type_Info := Resolve (To_String (F.Proto_Type));
                  C : constant String := Field_Ident (F);
                  N : constant String := F.Number'Image;
               begin
                  if F.Repeated then
                     if T.Category = Cat_Message then
                        SL (Body_Text, "      for I in Message." & C
                                       & ".First_Index .. Message." & C
                                       & ".Last_Index loop");
                        SL (Body_Text, "         Protobuf.Add_Message (Buffer," & N
                                       & ", Serialize (Element (Message." & C
                                       & " (I))));");
                        SL (Body_Text, "      end loop;");
                     elsif T.Category = Cat_Str then
                        --  repeated string/bytes: one length-delimited field each.
                        SL (Body_Text, "      for I in Message." & C
                                       & ".First_Index .. Message." & C
                                       & ".Last_Index loop");
                        SL (Body_Text, "         Protobuf.Add_" & To_String (T.Suffix)
                                       & " (Buffer," & N & ", To_String (Message."
                                       & C & " (I)));");
                        SL (Body_Text, "      end loop;");
                     elsif F.Packed_Set and then not F.Packed then
                        --  explicit [packed=false]: one tag+value per element.
                        SL (Body_Text, "      for I in Message." & C
                                       & ".First_Index .. Message." & C
                                       & ".Last_Index loop");
                        SL (Body_Text, "         Protobuf.Add_" & To_String (T.Suffix)
                                       & " (Buffer," & N & ", Message." & C & " (I));");
                        SL (Body_Text, "      end loop;");
                     else
                        --  packed repeated scalar.
                        SL (Body_Text, "      if not Message." & C & ".Is_Empty then");
                        SL (Body_Text, "         declare");
                        SL (Body_Text, "            Tmp : Protobuf." & To_String (T.Array_Type)
                                       & " (1 .. Natural (Message." & C & ".Length));");
                        SL (Body_Text, "         begin");
                        SL (Body_Text, "            for I in Tmp'Range loop");
                        SL (Body_Text, "               Tmp (I) := Message." & C
                                       & " (Positive (I));");
                        SL (Body_Text, "            end loop;");
                        SL (Body_Text, "            Protobuf.Add_Packed_" & To_String (T.Suffix)
                                       & " (Buffer," & N & ", Tmp);");
                        SL (Body_Text, "         end;");
                        SL (Body_Text, "      end if;");
                     end if;
                  else
                     declare
                        Acc : constant String := "Message." & C;
                        --  proto3 `optional` scalars are emitted by presence
                        --  (even at the default value); others by non-default.
                        Guard : constant String :=
                          (if F.Optional and then T.Category /= Cat_Message then
                              Acc & "_Has"
                           else (case T.Category is
                                    when Cat_Int     => Acc & " /= 0",
                                    when Cat_Float   => Acc & " /= 0.0",
                                    when Cat_Bool    => Acc,
                                    when Cat_Str     => "Length (" & Acc & ") > 0",
                                    when Cat_Message => "not " & Acc & ".Is_Empty"));
                        Add_Stmt : constant String :=
                          (case T.Category is
                              when Cat_Str =>
                                "Protobuf.Add_" & To_String (T.Suffix) & " (Buffer,"
                                & N & ", To_String (" & Acc & "))",
                              when Cat_Message =>
                                "Protobuf.Add_Message (Buffer," & N
                                & ", Serialize (" & Acc & ".Element))",
                              when others =>
                                "Protobuf.Add_" & To_String (T.Suffix) & " (Buffer,"
                                & N & ", " & Acc & ")");
                     begin
                        SL (Body_Text, "      if " & Guard & " then");
                        SL (Body_Text, "         " & Add_Stmt & ";");
                        SL (Body_Text, "      end if;");
                     end;
                  end if;
               end Emit_Encode;

               --  Decode the case branch for one field.
               procedure Emit_Decode (F : Field_Def) is
                  T : constant Type_Info := Resolve (To_String (F.Proto_Type));
                  C : constant String := Field_Ident (F);
                  N : constant String := F.Number'Image;
               begin
                  SL (Body_Text, "            when" & N & " =>");
                  if Length (F.Oneof) > 0 then
                     declare
                        ON  : constant String := To_String (F.Oneof);
                        Mem : constant String := Oneof_Member_Ident (F);
                        Val : constant String :=
                          (if T.Category = Cat_Str then
                              Str_Decode (To_String (T.Suffix),
                                 "Protobuf.As_" & To_String (T.Suffix) & " (Item)")
                           elsif T.Category = Cat_Message then
                              "To_Holder (Parse_" & To_String (T.Ada_Type)
                              & " (Protobuf.As_Message_Bytes (Item)))"
                           else
                              "Protobuf.As_" & To_String (T.Suffix) & " (Item)");
                     begin
                        SL (Body_Text, "               Result." & Ada_Id (ON)
                                       & " := (Which => "
                                       & Lit_Mem (TName, ON, To_String (F.Name))
                                       & ", " & Mem & " => " & Val & ");");
                     end;
                     return;
                  end if;
                  if F.Repeated then
                     if T.Category = Cat_Message then
                        SL (Body_Text, "               Result." & C
                                       & ".Append (To_Holder (" & Msg_Parse_Fn (T)
                                       & " (Protobuf.As_Message_Bytes (Item))));");
                     elsif T.Category = Cat_Str then
                        SL (Body_Text, "               Result." & C & ".Append ("
                                       & Str_Decode (To_String (T.Suffix),
                                            "Protobuf.As_" & To_String (T.Suffix)
                                            & " (Item)") & ");");
                     else
                        --  accept both packed and unpacked encodings.
                        SL (Body_Text, "               if Item.Kind = "
                                       & "Protobuf.Length_Delimited_Wire then");
                        SL (Body_Text, "                  declare");
                        SL (Body_Text, "                     A : constant Protobuf."
                                       & To_String (T.Array_Type)
                                       & " := Protobuf.Decode_Packed_"
                                       & To_String (T.Suffix)
                                       & " (Protobuf.As_Bytes (Item));");
                        SL (Body_Text, "                  begin");
                        SL (Body_Text, "                     for V of A loop Result."
                                       & C & ".Append (V); end loop;");
                        SL (Body_Text, "                  end;");
                        SL (Body_Text, "               else");
                        SL (Body_Text, "                  Result." & C
                                       & ".Append (Protobuf.As_" & To_String (T.Suffix)
                                       & " (Item));");
                        SL (Body_Text, "               end if;");
                     end if;
                  elsif T.Category = Cat_Str then
                     SL (Body_Text, "               Result." & C & " := "
                                    & Str_Decode (To_String (T.Suffix),
                                         "Protobuf.As_" & To_String (T.Suffix)
                                         & " (Item)") & ";");
                  elsif T.Category = Cat_Message then
                     SL (Body_Text, "               Result." & C
                                    & " := To_Holder (" & Msg_Parse_Fn (T)
                                    & " (Protobuf.As_Message_Bytes (Item)));");
                  else
                     SL (Body_Text, "               Result." & C & " := Protobuf.As_"
                                    & To_String (T.Suffix) & " (Item);");
                  end if;
                  if F.Optional and then T.Category /= Cat_Message then
                     SL (Body_Text, "               Result." & C & "_Has := True;");
                  end if;
               end Emit_Decode;

               --  Encode an entire oneof: at most one member is set (always
               --  emitted, even at its default value).
               procedure Emit_Oneof_Encode (ON : String) is
               begin
                  SL (Body_Text, "      case Message." & Ada_Id (ON) & ".Which is");
                  SL (Body_Text, "         when " & Lit_NotSet (TName, ON)
                                 & " => null;");
                  for F of M.Fields loop
                     if To_String (F.Oneof) = ON then
                        declare
                           T   : constant Type_Info :=
                             Resolve (To_String (F.Proto_Type));
                           Mem : constant String := Oneof_Member_Ident (F);
                           N   : constant String := F.Number'Image;
                           Acc : constant String :=
                             "Message." & Ada_Id (ON) & "." & Mem;
                        begin
                           SL (Body_Text, "         when "
                                          & Lit_Mem (TName, ON, To_String (F.Name))
                                          & " =>");
                           if T.Category = Cat_Str then
                              SL (Body_Text, "            Protobuf.Add_"
                                             & To_String (T.Suffix) & " (Buffer," & N
                                             & ", To_String (" & Acc & "));");
                           elsif T.Category = Cat_Message then
                              SL (Body_Text, "            Protobuf.Add_Message (Buffer,"
                                             & N & ", Serialize (" & Acc & ".Element));");
                           else
                              SL (Body_Text, "            Protobuf.Add_"
                                             & To_String (T.Suffix) & " (Buffer," & N
                                             & ", " & Acc & ");");
                           end if;
                        end;
                     end if;
                  end loop;
                  SL (Body_Text, "      end case;");
               end Emit_Oneof_Encode;

               --  A map field encodes as one length-delimited entry message per
               --  pair (key = field 1, value = field 2, default omission inside).
               procedure Emit_Map_Encode (F : Field_Def) is
                  KT : constant Type_Info := Resolve (To_String (F.Map_Key));
                  VT : constant Type_Info := Resolve (To_String (F.Map_Value));
                  C  : constant String := Ada_Id (To_String (F.Name));
                  N  : constant String := F.Number'Image;
                  MP : constant String :=
                    Map_Pkg (To_String (KT.Ada_Type), To_String (VT.Ada_Type));

                  procedure Add_KV (T : Type_Info; Acc, FN : String) is
                  begin
                     case T.Category is
                        when Cat_Int =>
                           SL (Body_Text, "            if " & Acc & " /= 0 then");
                           SL (Body_Text, "               Protobuf.Add_"
                                          & To_String (T.Suffix) & " (Entry_Buf, " & FN
                                          & ", " & Acc & ");");
                           SL (Body_Text, "            end if;");
                        when Cat_Float =>
                           SL (Body_Text, "            if " & Acc & " /= 0.0 then");
                           SL (Body_Text, "               Protobuf.Add_"
                                          & To_String (T.Suffix) & " (Entry_Buf, " & FN
                                          & ", " & Acc & ");");
                           SL (Body_Text, "            end if;");
                        when Cat_Bool =>
                           SL (Body_Text, "            if " & Acc & " then");
                           SL (Body_Text, "               Protobuf.Add_Bool (Entry_Buf, "
                                          & FN & ", " & Acc & ");");
                           SL (Body_Text, "            end if;");
                        when Cat_Str =>
                           SL (Body_Text, "            if Length (" & Acc & ") > 0 then");
                           SL (Body_Text, "               Protobuf.Add_"
                                          & To_String (T.Suffix) & " (Entry_Buf, " & FN
                                          & ", To_String (" & Acc & "));");
                           SL (Body_Text, "            end if;");
                        when Cat_Message =>
                           SL (Body_Text, "            Protobuf.Add_Message (Entry_Buf, "
                                          & FN & ", Serialize (" & Acc & ".Element));");
                     end case;
                  end Add_KV;

                  V_Type : constant String :=
                    (if VT.Category = Cat_Message then
                        To_String (VT.Ada_Type) & "_Holder"
                     else To_String (VT.Ada_Type));
               begin
                  SL (Body_Text, "      for Cur in Message." & C & ".Iterate loop");
                  SL (Body_Text, "         declare");
                  SL (Body_Text, "            Entry_Buf : Protobuf.Message_Buffer;");
                  SL (Body_Text, "            K : constant " & To_String (KT.Ada_Type)
                                 & " := " & MP & ".Key (Cur);");
                  SL (Body_Text, "            V : constant " & V_Type
                                 & " := " & MP & ".Element (Cur);");
                  SL (Body_Text, "         begin");
                  Add_KV (KT, "K", "1");
                  Add_KV (VT, "V", "2");
                  SL (Body_Text, "            Protobuf.Add_Message (Buffer," & N
                                 & ", Protobuf.To_String (Entry_Buf));");
                  SL (Body_Text, "         end;");
                  SL (Body_Text, "      end loop;");
               end Emit_Map_Encode;

               procedure Emit_Map_Decode (F : Field_Def) is
                  KT : constant Type_Info := Resolve (To_String (F.Map_Key));
                  VT : constant Type_Info := Resolve (To_String (F.Map_Value));
                  C  : constant String := Ada_Id (To_String (F.Name));
                  N  : constant String := F.Number'Image;
               begin
                  SL (Body_Text, "            when" & N & " =>");
                  SL (Body_Text, "               declare");
                  SL (Body_Text, "                  Ent : constant "
                                 & "Protobuf.Parsed_Field_Vectors.Vector :=");
                  SL (Body_Text, "                    Protobuf.Parse_From_String "
                                 & "(Protobuf.As_Message_Bytes (Item));");
                  SL (Body_Text, "                  K : " & To_String (KT.Ada_Type)
                                 & " := " & To_String (KT.Default) & ";");
                  if VT.Category = Cat_Message then
                     SL (Body_Text, "                  V : " & To_String (VT.Ada_Type)
                                    & "_Holder;");
                  else
                     SL (Body_Text, "                  V : " & To_String (VT.Ada_Type)
                                    & " := " & To_String (VT.Default) & ";");
                  end if;
                  SL (Body_Text, "               begin");
                  SL (Body_Text, "                  for E of Ent loop");
                  SL (Body_Text, "                     case E.Number is");
                  SL (Body_Text, "                        when 1 => K := "
                                 & Decode_Expr (KT, "E") & ";");
                  SL (Body_Text, "                        when 2 => V := "
                                 & (if VT.Category = Cat_Message then
                                       "To_Holder (" & Decode_Expr (VT, "E") & ")"
                                    else Decode_Expr (VT, "E")) & ";");
                  SL (Body_Text, "                        when others => null;");
                  SL (Body_Text, "                     end case;");
                  SL (Body_Text, "                  end loop;");
                  SL (Body_Text, "                  Result." & C & ".Include (K, V);");
                  SL (Body_Text, "               end;");
               end Emit_Map_Decode;

               --  JSON value expression for a scalar/enum/message Acc, per the
               --  proto3 JSON mapping (64-bit ints as strings, bytes as base64,
               --  enums as names, float specials as strings).
               function JSON_Expr (Proto, Acc : String) return String is
                  T : constant Type_Info := Resolve (Proto);
                  S : constant String := To_String (T.Suffix);
               begin
                  if T.Is_Null then
                     return "JSON.Null_Value";
                  elsif Is_Enum (Proto) then
                     return Ada_Id (Proto) & "_To_JSON (" & Acc & ")";
                  end if;
                  case T.Category is
                     when Cat_Int =>
                        if S = "Int32" or else S = "SInt32" or else S = "SFixed32"
                        then
                           return "JSON.Number (Proto_JSON.Image "
                                  & "(Interfaces.Integer_64 (" & Acc & ")))";
                        elsif S = "UInt32" or else S = "Fixed32" then
                           return "JSON.Number (Proto_JSON.Image "
                                  & "(Interfaces.Unsigned_64 (" & Acc & ")))";
                        else  --  64-bit -> string
                           return "JSON.To_Value (Proto_JSON.Image (" & Acc & "))";
                        end if;
                     when Cat_Float =>
                        return (if S = "Float" then "Proto_JSON.Float_To_JSON ("
                                else "Proto_JSON.Double_To_JSON (") & Acc & ")";
                     when Cat_Bool =>
                        return "JSON.To_Value (" & Acc & ")";
                     when Cat_Str =>
                        if S = "Bytes" then
                           return "JSON.To_Value (Proto_JSON.To_Base64 "
                                  & "(To_String (" & Acc & ")))";
                        else
                           return "JSON.To_Value (To_String (" & Acc & "))";
                        end if;
                     when Cat_Message =>
                        return "To_JSON (" & Acc & ")";
                  end case;
               end JSON_Expr;

               procedure Emit_To_JSON_Field (F : Field_Def) is
                  T  : constant Type_Info := Resolve (To_String (F.Proto_Type));
                  C  : constant String := Field_Ident (F);
                  JN : constant String := Json_Name (To_String (F.Name));
                  P  : constant String := To_String (F.Proto_Type);
               begin
                  if F.Repeated then
                     SL (Body_Text, "      if not Message." & C & ".Is_Empty then");
                     SL (Body_Text, "         declare");
                     SL (Body_Text, "            Arr : JSON.JSON_Value := JSON.Empty_Array;");
                     SL (Body_Text, "         begin");
                     SL (Body_Text, "            for I in Message." & C
                                    & ".First_Index .. Message." & C
                                    & ".Last_Index loop");
                     SL (Body_Text, "               JSON.Append (Arr, "
                                    & JSON_Expr
                                        (P, (if T.Category = Cat_Message then
                                                "Element (Message." & C & " (I))"
                                             else "Message." & C & ".Element (I)"))
                                    & ");");
                     SL (Body_Text, "            end loop;");
                     SL (Body_Text, "            JSON.Insert (Obj, " & Q & JN & Q
                                    & ", Arr);");
                     SL (Body_Text, "         end;");
                     SL (Body_Text, "      end if;");
                  else
                     declare
                        Guard : constant String :=
                          (if F.Optional and then T.Category /= Cat_Message then
                              "Message." & C & "_Has"
                           else (case T.Category is
                                    when Cat_Int     => "Message." & C & " /= 0",
                                    when Cat_Float   => "Message." & C & " /= 0.0",
                                    when Cat_Bool    => "Message." & C,
                                    when Cat_Str  => "Length (Message." & C & ") > 0",
                                    when Cat_Message => "not Message." & C & ".Is_Empty"));
                        Acc : constant String :=
                          (if T.Category = Cat_Message
                           then "Message." & C & ".Element"
                           else "Message." & C);
                     begin
                        SL (Body_Text, "      if " & Guard & " then");
                        SL (Body_Text, "         JSON.Insert (Obj, " & Q & JN & Q
                                       & ", " & JSON_Expr (P, Acc) & ");");
                        SL (Body_Text, "      end if;");
                     end;
                  end if;
               end Emit_To_JSON_Field;

               procedure Emit_Oneof_JSON (ON : String) is
               begin
                  SL (Body_Text, "      case Message." & Ada_Id (ON) & ".Which is");
                  SL (Body_Text, "         when " & Lit_NotSet (TName, ON)
                                 & " => null;");
                  for F of M.Fields loop
                     if To_String (F.Oneof) = ON then
                        declare
                           P   : constant String := To_String (F.Proto_Type);
                           Mem : constant String := Oneof_Member_Ident (F);
                           Base : constant String :=
                             "Message." & Ada_Id (ON) & "." & Mem;
                           Acc : constant String :=
                             (if Resolve (P).Category = Cat_Message
                              then Base & ".Element" else Base);
                        begin
                           SL (Body_Text, "         when "
                                          & Lit_Mem (TName, ON, To_String (F.Name))
                                          & " => JSON.Insert (Obj, " & Q
                                          & Json_Name (To_String (F.Name)) & Q & ", "
                                          & JSON_Expr (P, Acc) & ");");
                        end;
                     end if;
                  end loop;
                  SL (Body_Text, "      end case;");
               end Emit_Oneof_JSON;

               procedure Emit_Map_JSON (F : Field_Def) is
                  KT : constant Type_Info := Resolve (To_String (F.Map_Key));
                  C  : constant String := Ada_Id (To_String (F.Name));
                  JN : constant String := Json_Name (To_String (F.Name));
                  MP : constant String :=
                    Map_Pkg (To_String (KT.Ada_Type),
                             To_String (Resolve (To_String (F.Map_Value)).Ada_Type));
                  Key_Str : constant String :=
                    (case KT.Category is
                        when Cat_Str  => "To_String (" & MP & ".Key (Cur))",
                        when Cat_Bool =>
                          "(if " & MP & ".Key (Cur) then " & Q & "true" & Q
                          & " else " & Q & "false" & Q & ")",
                        when others   =>
                          (if Index (KT.Ada_Type, "Unsigned") > 0
                           then "Proto_JSON.Image (Interfaces.Unsigned_64 ("
                           else "Proto_JSON.Image (Interfaces.Integer_64 (")
                          & MP & ".Key (Cur)))");
                  Val_Is_Msg : constant Boolean :=
                    Resolve (To_String (F.Map_Value)).Category = Cat_Message;
                  Val_Acc : constant String :=
                    (if Val_Is_Msg then "Element (" & MP & ".Element (Cur))"
                     else MP & ".Element (Cur)");
               begin
                  SL (Body_Text, "      if not Message." & C & ".Is_Empty then");
                  SL (Body_Text, "         declare");
                  SL (Body_Text, "            M2 : JSON.JSON_Value := JSON.Empty_Object;");
                  SL (Body_Text, "         begin");
                  SL (Body_Text, "            for Cur in Message." & C
                                 & ".Iterate loop");
                  SL (Body_Text, "               JSON.Insert (M2, " & Key_Str & ", "
                                 & JSON_Expr (To_String (F.Map_Value), Val_Acc)
                                 & ");");
                  SL (Body_Text, "            end loop;");
                  SL (Body_Text, "            JSON.Insert (Obj, " & Q & JN & Q
                                 & ", M2);");
                  SL (Body_Text, "         end;");
                  SL (Body_Text, "      end if;");
               end Emit_Map_JSON;

               --  Expression decoding a JSON value FV into a field's Ada value
               --  (message values are returned bare; callers wrap To_Holder).
               function From_JSON_Expr (Proto, FV : String) return String is
                  T : constant Type_Info := Resolve (Proto);
                  S : constant String := To_String (T.Suffix);
               begin
                  if T.Is_Null then
                     --  NullValue's only value is NULL_VALUE (0).
                     return "Interfaces.Integer_32'(0)";
                  elsif Is_Enum (Proto) then
                     return Ada_Id (Proto) & "_From_JSON (" & FV & ")";
                  end if;
                  case T.Category is
                     when Cat_Int =>
                        if S = "Int32" or else S = "SInt32" or else S = "SFixed32"
                        then
                           return "Interfaces.Integer_32 (Proto_JSON.To_Int64 "
                                  & "(Proto_JSON.Scalar_Text (" & FV & ")))";
                        elsif S = "UInt32" or else S = "Fixed32" then
                           return "Interfaces.Unsigned_32 (Proto_JSON.To_UInt64 "
                                  & "(Proto_JSON.Scalar_Text (" & FV & ")))";
                        elsif S = "UInt64" or else S = "Fixed64" then
                           return "Proto_JSON.To_UInt64 (Proto_JSON.Scalar_Text ("
                                  & FV & "))";
                        else
                           return "Proto_JSON.To_Int64 (Proto_JSON.Scalar_Text ("
                                  & FV & "))";
                        end if;
                     when Cat_Float =>
                        return (if S = "Float" then "Proto_JSON.To_Float"
                                else "Proto_JSON.To_Double")
                               & " (Proto_JSON.Scalar_Text (" & FV & "))";
                     when Cat_Bool =>
                        return "JSON.As_Boolean (" & FV & ")";
                     when Cat_Str =>
                        if S = "Bytes" then
                           return "To_Unbounded_String (Proto_JSON.From_Base64 "
                                  & "(JSON.As_String (" & FV & ")))";
                        else
                           return Str_Decode (S, "JSON.As_String (" & FV & ")");
                        end if;
                     when Cat_Message =>
                        return Msg_Type_Mark (T) & "'(From_JSON (" & FV & "))";
                  end case;
               end From_JSON_Expr;

               --  Wrap a message decode in To_Holder; pass other values through.
               function Stored_From_JSON (Proto, FV : String) return String is
               begin
                  if Resolve (Proto).Category = Cat_Message then
                     return "To_Holder (" & From_JSON_Expr (Proto, FV) & ")";
                  else
                     return From_JSON_Expr (Proto, FV);
                  end if;
               end Stored_From_JSON;

               --  Emit "FV := the field's JSON value, trying camelCase then the
               --  raw proto name" as a declare/begin opener.
               procedure Emit_Lookup (F : Field_Def) is
                  JN : constant String := Json_Name (To_String (F.Name));
                  PN : constant String := To_String (F.Name);
               begin
                  SL (Body_Text, "      declare");
                  SL (Body_Text, "         FV : JSON.JSON_Value := JSON.Get (V, "
                                 & Q & JN & Q & ");");
                  SL (Body_Text, "      begin");
                  if JN /= PN then
                     SL (Body_Text, "         if JSON.Kind (FV) = JSON.JSON_Null "
                                    & "then FV := JSON.Get (V, " & Q & PN & Q
                                    & "); end if;");
                  end if;
               end Emit_Lookup;

               procedure Emit_From_JSON_Field (F : Field_Def) is
                  T : constant Type_Info := Resolve (To_String (F.Proto_Type));
                  C : constant String := Field_Ident (F);
                  P : constant String := To_String (F.Proto_Type);
               begin
                  Emit_Lookup (F);
                  if F.Repeated then
                     SL (Body_Text, "         if JSON.Kind (FV) = JSON.JSON_Array then");
                     SL (Body_Text, "            for I in 1 .. JSON.Length (FV) loop");
                     SL (Body_Text, "               Result." & C & ".Append ("
                                    & Stored_From_JSON (P, "JSON.Element (FV, I)")
                                    & ");");
                     SL (Body_Text, "            end loop;");
                     SL (Body_Text, "         end if;");
                  else
                     SL (Body_Text, "         if JSON.Kind (FV) /= JSON.JSON_Null then");
                     SL (Body_Text, "            Result." & C & " := "
                                    & Stored_From_JSON (P, "FV") & ";");
                     if F.Optional and then T.Category /= Cat_Message then
                        SL (Body_Text, "            Result." & C & "_Has := True;");
                     end if;
                     SL (Body_Text, "         end if;");
                  end if;
                  SL (Body_Text, "      end;");
               end Emit_From_JSON_Field;

               procedure Emit_Oneof_From_JSON (F : Field_Def) is
                  P   : constant String := To_String (F.Proto_Type);
                  ON  : constant String := To_String (F.Oneof);
                  Mem : constant String := Oneof_Member_Ident (F);
                  JN  : constant String := Json_Name (To_String (F.Name));
                  PN  : constant String := To_String (F.Name);
               begin
                  if Resolve (P).Is_Null then
                     --  For a NullValue member, JSON null is the value, not
                     --  "absent": the key being present selects the member.
                     SL (Body_Text, "      if JSON.Has (V, " & Q & JN & Q & ")");
                     SL (Body_Text, "        or else JSON.Has (V, " & Q & PN & Q
                                    & ") then");
                     SL (Body_Text, "         Result." & Ada_Id (ON) & " := (Which => "
                                    & Lit_Mem (TName, ON, To_String (F.Name)) & ", "
                                    & Mem & " => Interfaces.Integer_32'(0));");
                     SL (Body_Text, "      end if;");
                     return;
                  end if;
                  Emit_Lookup (F);
                  SL (Body_Text, "         if JSON.Kind (FV) /= JSON.JSON_Null then");
                  SL (Body_Text, "            Result." & Ada_Id (ON) & " := (Which => "
                                 & Lit_Mem (TName, ON, To_String (F.Name)) & ", " & Mem
                                 & " => " & Stored_From_JSON (P, "FV") & ");");
                  SL (Body_Text, "         end if;");
                  SL (Body_Text, "      end;");
               end Emit_Oneof_From_JSON;

               procedure Emit_Map_From_JSON (F : Field_Def) is
                  KT : constant Type_Info := Resolve (To_String (F.Map_Key));
                  C  : constant String := Ada_Id (To_String (F.Name));
                  KS : constant String := To_String (KT.Suffix);
                  Key_Expr : constant String :=
                    (case KT.Category is
                        when Cat_Str  => "To_Unbounded_String (Kstr)",
                        when Cat_Bool => "(Kstr = " & Q & "true" & Q & ")",
                        when others   =>
                          (if KS = "UInt32" then
                              "Interfaces.Unsigned_32 (Proto_JSON.To_UInt64 (Kstr))"
                           elsif KS = "Fixed32" then
                              "Interfaces.Unsigned_32 (Proto_JSON.To_UInt64 (Kstr))"
                           elsif KS = "UInt64" or else KS = "Fixed64" then
                              "Proto_JSON.To_UInt64 (Kstr)"
                           elsif KS = "Int64" or else KS = "SInt64"
                             or else KS = "SFixed64" then
                              "Proto_JSON.To_Int64 (Kstr)"
                           else
                              "Interfaces.Integer_32 (Proto_JSON.To_Int64 (Kstr))"));
               begin
                  Emit_Lookup (F);
                  SL (Body_Text, "         if JSON.Kind (FV) = JSON.JSON_Object then");
                  SL (Body_Text, "            for I in 1 .. JSON.Length (FV) loop");
                  SL (Body_Text, "               declare");
                  SL (Body_Text, "                  Kstr : constant String := "
                                 & "JSON.Key (FV, I);");
                  SL (Body_Text, "                  VV : constant JSON.JSON_Value := "
                                 & "JSON.Get (FV, Kstr);");
                  SL (Body_Text, "               begin");
                  SL (Body_Text, "                  Result." & C & ".Include ("
                                 & Key_Expr & ", "
                                 & Stored_From_JSON (To_String (F.Map_Value), "VV")
                                 & ");");
                  SL (Body_Text, "               end;");
                  SL (Body_Text, "            end loop;");
                  SL (Body_Text, "         end if;");
                  SL (Body_Text, "      end;");
               end Emit_Map_From_JSON;

               Encoded_Oneofs : String_Vectors.Vector;
               JSON_Oneofs    : String_Vectors.Vector;
            begin
               SL (Body_Text, "   function Serialize (Message : " & TName
                              & ") return String is");
               SL (Body_Text, "      Buffer : Protobuf.Message_Buffer;");
               SL (Body_Text, "   begin");
               for F of M.Fields loop
                  if F.Is_Map then
                     Emit_Map_Encode (F);
                  elsif Length (F.Oneof) = 0 then
                     Emit_Encode (F);
                  elsif not In_Set (Encoded_Oneofs, To_String (F.Oneof)) then
                     Add_Once (Encoded_Oneofs, To_String (F.Oneof));
                     Emit_Oneof_Encode (To_String (F.Oneof));
                  end if;
               end loop;
               SL (Body_Text, "      return Protobuf.To_String (Buffer);");
               SL (Body_Text, "   end Serialize;");
               SL (Body_Text, "");

               SL (Body_Text, "   function Parse_" & TName
                              & " (Data : String) return " & TName & " is");
               SL (Body_Text, "      Result : " & TName & ";");
               SL (Body_Text, "      Fields : constant Protobuf.Parsed_Field_Vectors.Vector :=");
               SL (Body_Text, "        Protobuf.Parse_From_String (Data);");
               SL (Body_Text, "   begin");
               SL (Body_Text, "      for Item of Fields loop");
               SL (Body_Text, "         case Item.Number is");
               for F of M.Fields loop
                  if F.Is_Map then
                     Emit_Map_Decode (F);
                  else
                     Emit_Decode (F);
                  end if;
               end loop;
               SL (Body_Text, "            when others => null;");
               SL (Body_Text, "         end case;");
               SL (Body_Text, "      end loop;");
               SL (Body_Text, "      return Result;");
               SL (Body_Text, "   end Parse_" & TName & ";");
               SL (Body_Text, "");

               --  To_JSON: build a JSON object per the proto3 mapping, omitting
               --  default-valued fields.
               SL (Body_Text, "   function To_JSON (Message : " & TName
                              & ") return JSON.JSON_Value is");
               SL (Body_Text, "      Obj : JSON.JSON_Value := JSON.Empty_Object;");
               SL (Body_Text, "   begin");
               for F of M.Fields loop
                  if F.Is_Map then
                     Emit_Map_JSON (F);
                  elsif Length (F.Oneof) = 0 then
                     Emit_To_JSON_Field (F);
                  elsif not In_Set (JSON_Oneofs, To_String (F.Oneof)) then
                     Add_Once (JSON_Oneofs, To_String (F.Oneof));
                     Emit_Oneof_JSON (To_String (F.Oneof));
                  end if;
               end loop;
               SL (Body_Text, "      return Obj;");
               SL (Body_Text, "   end To_JSON;");
               SL (Body_Text, "");

               --  From_JSON: the inverse mapping. Missing/null fields keep their
               --  default; field names match either camelCase or the proto name.
               SL (Body_Text, "   function From_JSON (V : JSON.JSON_Value) return "
                              & TName & " is");
               SL (Body_Text, "      Result : " & TName & ";");
               SL (Body_Text, "   begin");
               for F of M.Fields loop
                  if F.Is_Map then
                     Emit_Map_From_JSON (F);
                  elsif Length (F.Oneof) > 0 then
                     Emit_Oneof_From_JSON (F);
                  else
                     Emit_From_JSON_Field (F);
                  end if;
               end loop;
               SL (Body_Text, "      return Result;");
               SL (Body_Text, "   end From_JSON;");
               SL (Body_Text, "");
            end;
         end loop;

         SL (Body_Text, "end " & Unit & ";");

         Write_File (Out_Dir & "/" & File_Base & ".ads", To_String (Spec));
         Write_File (Out_Dir & "/" & File_Base & ".adb", To_String (Body_Text));
         Ada.Text_IO.Put_Line
           ("generated " & File_Base & ".ads/.adb (" & Unit & ")");
      end;
   end Generate;

end Proto_Compiler;
