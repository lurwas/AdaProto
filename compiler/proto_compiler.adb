with Ada.Characters.Handling;  use Ada.Characters.Handling;
with Ada.Containers.Vectors;
with Ada.Directories;
with Ada.Streams.Stream_IO;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO;

package body Proto_Compiler is

   NL : constant Character := ASCII.LF;

   ---------------------------------------------------------------------------
   --  AST
   ---------------------------------------------------------------------------

   type Field_Def is record
      Proto_Type : Unbounded_String;
      Name       : Unbounded_String;
      Number     : Positive := 1;
   end record;

   package Field_Vectors is new Ada.Containers.Vectors (Positive, Field_Def);

   type Message_Def is record
      Name   : Unbounded_String;
      Fields : Field_Vectors.Vector;
   end record;

   package Message_Vectors is new Ada.Containers.Vectors (Positive, Message_Def);

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
            elsif Is_Digit (C) then
               declare
                  Start : constant Natural := I;
               begin
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
     (Toks : Token_Vectors.Vector;
      Pkg  : out Unbounded_String;
      Msgs : out Message_Vectors.Vector)
   is
      P : Positive := Toks.First_Index;

      function Cur return Token is (Toks (P));

      procedure Err (Message : String) is
      begin
         raise Compile_Error
           with "line" & Cur.Line'Image & ": " & Message;
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

      function Parse_Number return Positive is
      begin
         if Cur.Kind /= T_Number then
            Err ("expected field number");
         end if;
         declare
            V : constant Integer := Integer'Value (To_String (Cur.Text));
         begin
            Adv;
            if V < 1 then
               Err ("field number must be >= 1");
            end if;
            return Positive (V);
         end;
      exception
         when Constraint_Error =>
            Err ("invalid field number");
            raise;
      end Parse_Number;

      procedure Parse_Message is
         M : Message_Def;
      begin
         Adv;  -- 'message'
         M.Name := To_Unbounded_String (Expect_Ident);
         Expect_Symbol ("{");
         while not At_Symbol ("}") and then Cur.Kind /= T_EOF loop
            if At_Symbol (";") then
               Adv;
            elsif At_Ident ("reserved") or else At_Ident ("option") then
               Skip_To_Semicolon;
            elsif At_Ident ("repeated") or else At_Ident ("optional") then
               Err ("'" & To_String (Cur.Text)
                    & "' fields are not supported in this codegen phase");
            elsif At_Ident ("message") or else At_Ident ("enum")
              or else At_Ident ("oneof") or else At_Ident ("map")
            then
               Err ("nested '" & To_String (Cur.Text)
                    & "' is not supported in this codegen phase");
            else
               declare
                  F : Field_Def;
               begin
                  F.Proto_Type := To_Unbounded_String (Expect_Ident);
                  F.Name := To_Unbounded_String (Expect_Ident);
                  Expect_Symbol ("=");
                  F.Number := Parse_Number;
                  if At_Symbol ("[") then  -- field options, skipped
                     while not At_Symbol ("]") and then Cur.Kind /= T_EOF loop
                        Adv;
                     end loop;
                     Expect_Symbol ("]");
                  end if;
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
            Parse_Message;
         elsif At_Ident ("enum") then
            Err ("top-level 'enum' is not supported in this codegen phase");
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

   type Type_Category is (Cat_Int, Cat_Float, Cat_Bool, Cat_Str);

   type Type_Info is record
      Ada_Type : Unbounded_String;
      Default  : Unbounded_String;
      Suffix   : Unbounded_String;  --  e.g. "Int32" -> Add_Int32 / As_Int32
      Category : Type_Category := Cat_Int;
   end record;

   function Info
     (Ada_Type, Default, Suffix : String; Category : Type_Category)
      return Type_Info
   is
   begin
      return
        (To_Unbounded_String (Ada_Type),
         To_Unbounded_String (Default),
         To_Unbounded_String (Suffix),
         Category);
   end Info;

   function Map_Type (Proto : String) return Type_Info is
   begin
      if Proto = "int32" then
         return Info ("Interfaces.Integer_32", "0", "Int32", Cat_Int);
      elsif Proto = "int64" then
         return Info ("Interfaces.Integer_64", "0", "Int64", Cat_Int);
      elsif Proto = "uint32" then
         return Info ("Interfaces.Unsigned_32", "0", "UInt32", Cat_Int);
      elsif Proto = "uint64" then
         return Info ("Interfaces.Unsigned_64", "0", "UInt64", Cat_Int);
      elsif Proto = "sint32" then
         return Info ("Interfaces.Integer_32", "0", "SInt32", Cat_Int);
      elsif Proto = "sint64" then
         return Info ("Interfaces.Integer_64", "0", "SInt64", Cat_Int);
      elsif Proto = "fixed32" then
         return Info ("Interfaces.Unsigned_32", "0", "Fixed32", Cat_Int);
      elsif Proto = "fixed64" then
         return Info ("Interfaces.Unsigned_64", "0", "Fixed64", Cat_Int);
      elsif Proto = "sfixed32" then
         return Info ("Interfaces.Integer_32", "0", "SFixed32", Cat_Int);
      elsif Proto = "sfixed64" then
         return Info ("Interfaces.Integer_64", "0", "SFixed64", Cat_Int);
      elsif Proto = "float" then
         return Info ("Interfaces.IEEE_Float_32", "0.0", "Float", Cat_Float);
      elsif Proto = "double" then
         return Info ("Interfaces.IEEE_Float_64", "0.0", "Double", Cat_Float);
      elsif Proto = "bool" then
         return Info ("Boolean", "False", "Bool", Cat_Bool);
      elsif Proto = "string" then
         return Info
           ("Ada.Strings.Unbounded.Unbounded_String",
            "Ada.Strings.Unbounded.Null_Unbounded_String", "String", Cat_Str);
      elsif Proto = "bytes" then
         return Info
           ("Ada.Strings.Unbounded.Unbounded_String",
            "Ada.Strings.Unbounded.Null_Unbounded_String", "Bytes", Cat_Str);
      else
         raise Compile_Error with "unsupported field type '" & Proto & "'";
      end if;
   end Map_Type;

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

   --  Ada 2012 reserved words, space-delimited for membership testing.
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

   --  Turn a proto identifier into a valid, non-colliding Ada identifier:
   --  capitalise it, and suffix "_F" when it would clash with a reserved word.
   function Ada_Id (Proto_Name : String) return String is
   begin
      if Is_Reserved (To_Lower (Proto_Name)) then
         return Cap (Proto_Name) & "_F";
      else
         return Cap (Proto_Name);
      end if;
   end Ada_Id;

   --  Map a (possibly dotted) proto package name to a single Ada identifier:
   --  dots become underscores and each segment is capitalised.
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
                  Result (I) :=
                    Character'Val (Data (Stream_Element_Offset (I)));
               end loop;
            end return;
         end;
      end Read_File;

      Source   : constant String := Read_File (Proto_Path);
      Toks     : constant Token_Vectors.Vector := Lex (Source);
      Pkg      : Unbounded_String;
      Msgs     : Message_Vectors.Vector;
   begin
      Parse (Toks, Pkg, Msgs);

      declare
         Unit       : constant String :=
           Ada_Unit_Name
             (if Length (Pkg) > 0 then To_String (Pkg) else "Proto");
         File_Base  : constant String := To_Lower (Unit);
         Spec       : Unbounded_String;
         Body_Text  : Unbounded_String;

         procedure SL (To : in out Unbounded_String; Line : String) is
         begin
            Append (To, Line);
            Append (To, NL);
         end SL;
      begin
         --  Specification ----------------------------------------------------
         SL (Spec, "--  Generated by protoc-ada from "
                   & Ada.Directories.Simple_Name (Proto_Path));
         SL (Spec, "--  Do not edit by hand.");
         SL (Spec, "with Interfaces;");
         SL (Spec, "with Ada.Strings.Unbounded;");
         SL (Spec, "package " & Unit & " is");
         SL (Spec, "");

         for M of Msgs loop
            declare
               TName : constant String := Ada_Id (To_String (M.Name));
            begin
               SL (Spec, "   type " & TName & " is record");
               for F of M.Fields loop
                  declare
                     T : constant Type_Info := Map_Type (To_String (F.Proto_Type));
                  begin
                     SL (Spec, "      " & Ada_Id (To_String (F.Name)) & " : "
                               & To_String (T.Ada_Type) & " := "
                               & To_String (T.Default) & ";");
                  end;
               end loop;
               SL (Spec, "   end record;");
               SL (Spec, "");
               SL (Spec, "   function Serialize (Message : " & TName
                         & ") return String;");
               SL (Spec, "   function Parse_" & TName
                         & " (Data : String) return " & TName & ";");
               SL (Spec, "");
            end;
         end loop;

         SL (Spec, "end " & Unit & ";");

         --  Body -------------------------------------------------------------
         SL (Body_Text, "--  Generated by protoc-ada. Do not edit by hand.");
         SL (Body_Text, "with Interfaces; use Interfaces;");
         SL (Body_Text, "with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;");
         SL (Body_Text, "with Protobuf;");
         SL (Body_Text, "package body " & Unit & " is");
         SL (Body_Text, "");

         for M of Msgs loop
            declare
               TName : constant String := Ada_Id (To_String (M.Name));
            begin
               --  Serialize
               SL (Body_Text, "   function Serialize (Message : " & TName
                              & ") return String is");
               SL (Body_Text, "      Buffer : Protobuf.Message_Buffer;");
               SL (Body_Text, "   begin");
               for F of M.Fields loop
                  declare
                     T  : constant Type_Info := Map_Type (To_String (F.Proto_Type));
                     C  : constant String := Ada_Id (To_String (F.Name));
                     N  : constant String := F.Number'Image;
                     Op : constant String := "Protobuf.Add_" & To_String (T.Suffix);
                  begin
                     case T.Category is
                        when Cat_Int =>
                           SL (Body_Text, "      if Message." & C & " /= 0 then");
                           SL (Body_Text, "         " & Op & " (Buffer,"
                                          & N & ", Message." & C & ");");
                           SL (Body_Text, "      end if;");
                        when Cat_Float =>
                           SL (Body_Text, "      if Message." & C & " /= 0.0 then");
                           SL (Body_Text, "         " & Op & " (Buffer,"
                                          & N & ", Message." & C & ");");
                           SL (Body_Text, "      end if;");
                        when Cat_Bool =>
                           SL (Body_Text, "      if Message." & C & " then");
                           SL (Body_Text, "         " & Op & " (Buffer,"
                                          & N & ", Message." & C & ");");
                           SL (Body_Text, "      end if;");
                        when Cat_Str =>
                           SL (Body_Text, "      if Length (Message." & C
                                          & ") > 0 then");
                           SL (Body_Text, "         " & Op & " (Buffer,"
                                          & N & ", To_String (Message." & C & "));");
                           SL (Body_Text, "      end if;");
                     end case;
                  end;
               end loop;
               SL (Body_Text, "      return Protobuf.To_String (Buffer);");
               SL (Body_Text, "   end Serialize;");
               SL (Body_Text, "");

               --  Parse
               SL (Body_Text, "   function Parse_" & TName
                              & " (Data : String) return " & TName & " is");
               SL (Body_Text, "      Result : " & TName & ";");
               SL (Body_Text, "      Fields : constant Protobuf.Parsed_Field_Vectors.Vector :=");
               SL (Body_Text, "        Protobuf.Parse_From_String (Data);");
               SL (Body_Text, "   begin");
               SL (Body_Text, "      for Item of Fields loop");
               SL (Body_Text, "         case Item.Number is");
               for F of M.Fields loop
                  declare
                     T  : constant Type_Info := Map_Type (To_String (F.Proto_Type));
                     C  : constant String := Ada_Id (To_String (F.Name));
                     N  : constant String := F.Number'Image;
                     As : constant String := "Protobuf.As_" & To_String (T.Suffix)
                                             & " (Item)";
                  begin
                     SL (Body_Text, "            when" & N & " =>");
                     if T.Category = Cat_Str then
                        SL (Body_Text, "               Result." & C
                                       & " := To_Unbounded_String (" & As & ");");
                     else
                        SL (Body_Text, "               Result." & C
                                       & " := " & As & ";");
                     end if;
                  end;
               end loop;
               SL (Body_Text, "            when others => null;");
               SL (Body_Text, "         end case;");
               SL (Body_Text, "      end loop;");
               SL (Body_Text, "      return Result;");
               SL (Body_Text, "   end Parse_" & TName & ";");
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
