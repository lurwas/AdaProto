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
      Repeated   : Boolean := False;
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

      procedure Parse_Enum is
         E : Enum_Def;
      begin
         Adv;  -- 'enum'
         E.Name := To_Unbounded_String (Expect_Ident);
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
            elsif At_Ident ("optional") then
               Err ("'optional' fields are not supported in this codegen phase");
            elsif At_Ident ("message") or else At_Ident ("enum")
              or else At_Ident ("oneof") or else At_Ident ("map")
            then
               Err ("nested '" & To_String (Cur.Text)
                    & "' is not supported in this codegen phase");
            else
               declare
                  F : Field_Def;
               begin
                  if At_Ident ("repeated") then
                     F.Repeated := True;
                     Adv;
                  end if;
                  F.Proto_Type := To_Unbounded_String (Expect_Ident);
                  F.Name := To_Unbounded_String (Expect_Ident);
                  Expect_Symbol ("=");
                  F.Number := Positive (Parse_Int);
                  Skip_Field_Options;
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
            Parse_Enum;
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
         Category);
   end Info;

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

   function Ada_Id (Proto_Name : String) return String is
   begin
      if Is_Reserved (To_Lower (Proto_Name)) then
         return Cap (Proto_Name) & "_F";
      else
         return Cap (Proto_Name);
      end if;
   end Ada_Id;

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
         elsif Is_Enum (Proto) then
            return Info (Ada_Id (Proto), "0", "Int32", "Int32_Array", Cat_Int);
         elsif Is_Message (Proto) then
            return Info (Ada_Id (Proto), "", "Message", "", Cat_Message);
         else
            raise Compile_Error
              with "field type '" & Proto
                   & "' is not a scalar, enum, or message";
         end if;
      end Resolve;

      function Holder_Pkg (Ada_Type : String) return String is
        (Ada_Type & "_Holders");

      --  A field's Ada component identifier. For a singular field whose name
      --  equals its own (simple) type name, suffix "_F" so the component does
      --  not shadow the type mark (e.g. "color : Color" -> "Color_F : Color").
      function Field_Ident (F : Field_Def) return String is
         C : constant String := Ada_Id (To_String (F.Name));
      begin
         if F.Repeated
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

   begin
      Parse (Toks, Pkg, Msgs, Enums);
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
         Has_Repeated        : Boolean := False;  --  any repeated -> with Vectors
         Has_Packed_Repeated : Boolean := False;  --  repeated scalar -> Wire_Type
         Need_Holders        : Boolean := False;

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

         function Find_Msg (Proto : String) return Natural is
         begin
            for K in Msgs.First_Index .. Msgs.Last_Index loop
               if To_String (Msgs (K).Name) = Proto then
                  return K;
               end if;
            end loop;
            return 0;
         end Find_Msg;
      begin
         --  Discover required container instances per field shape.
         for M of Msgs loop
            for F of M.Fields loop
               declare
                  T : constant Type_Info := Resolve (To_String (F.Proto_Type));
               begin
                  if F.Repeated then
                     Has_Repeated := True;
                     if T.Category = Cat_Message then
                        Add_Once (Msg_Vec, To_String (T.Ada_Type));
                     else
                        Has_Packed_Repeated :=
                          Has_Packed_Repeated or else T.Category /= Cat_Str;
                        Add_Once (Vec_Types, To_String (T.Ada_Type));
                     end if;
                  elsif T.Category = Cat_Message then
                     Need_Holders := True;
                     Add_Once (Msg_Hold, To_String (T.Ada_Type));
                  end if;
               end;
            end loop;
         end loop;

         --  Topologically order messages so a message-typed field's type is
         --  declared first. A cycle means recursion, which Indefinite_Holders
         --  cannot express (the instantiation needs a complete type).
         declare
            Visited : array (1 .. N_Msgs) of Boolean := (others => False);
            Active  : array (1 .. N_Msgs) of Boolean := (others => False);

            procedure Visit (K : Positive) is
            begin
               if Active (K) then
                  raise Compile_Error
                    with "message '" & To_String (Msgs (K).Name)
                         & "' is recursive/mutually-recursive, which is not "
                         & "supported with Indefinite_Holders (needs access types)";
               end if;
               if Visited (K) then
                  return;
               end if;
               Active (K) := True;
               for F of Msgs (K).Fields loop
                  if Is_Message (To_String (F.Proto_Type)) then
                     Visit (Find_Msg (To_String (F.Proto_Type)));
                  end if;
               end loop;
               Active (K) := False;
               Visited (K) := True;
               Order.Append (K);
            end Visit;
         begin
            for K in 1 .. N_Msgs loop
               Visit (K);
            end loop;
         end;

         --  Specification ---------------------------------------------------
         SL (Spec, "--  Generated by protoc-ada from "
                   & Ada.Directories.Simple_Name (Proto_Path));
         SL (Spec, "--  Do not edit by hand.");
         SL (Spec, "with Interfaces;");
         SL (Spec, "with Ada.Strings.Unbounded;");
         if Has_Repeated then
            SL (Spec, "with Ada.Containers.Vectors;");
         end if;
         if Need_Holders then
            SL (Spec, "with Ada.Containers.Indefinite_Holders;");
         end if;
         SL (Spec, "package " & Unit & " is");
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
               SL (Spec, "");
            end;
         end loop;

         --  Scalar/enum repeated element vectors (element types available now).
         for T of Vec_Types loop
            SL (Spec, "   use type " & To_String (T) & ";");
         end loop;
         for T of Vec_Types loop
            SL (Spec, "   package " & Vector_Pkg (To_String (T))
                      & " is new Ada.Containers.Vectors (Positive, "
                      & To_String (T) & ");");
         end loop;
         if not Vec_Types.Is_Empty then
            SL (Spec, "");
         end if;

         --  Message record types (topo order) + their container instances +
         --  subprogram declarations.
         for OI in Order.First_Index .. Order.Last_Index loop
            declare
               M     : constant Message_Def := Msgs (Order (OI));
               TName : constant String := Ada_Id (To_String (M.Name));
            begin
               SL (Spec, "   type " & TName & " is record");
               for F of M.Fields loop
                  declare
                     T : constant Type_Info := Resolve (To_String (F.Proto_Type));
                     C : constant String := Field_Ident (F);
                  begin
                     if F.Repeated then
                        SL (Spec, "      " & C & " : "
                                  & Vector_Pkg (To_String (T.Ada_Type)) & ".Vector;");
                     elsif T.Category = Cat_Message then
                        SL (Spec, "      " & C & " : "
                                  & Holder_Pkg (To_String (T.Ada_Type)) & ".Holder;");
                     else
                        SL (Spec, "      " & C & " : " & To_String (T.Ada_Type)
                                  & " := " & To_String (T.Default) & ";");
                     end if;
                  end;
               end loop;
               SL (Spec, "   end record;");

               --  Container instances over this message type, for later users.
               if In_Set (Msg_Hold, TName) or else In_Set (Msg_Vec, TName) then
                  SL (Spec, "   use type " & TName & ";");
               end if;
               if In_Set (Msg_Hold, TName) then
                  SL (Spec, "   package " & Holder_Pkg (TName)
                            & " is new Ada.Containers.Indefinite_Holders ("
                            & TName & ");");
               end if;
               if In_Set (Msg_Vec, TName) then
                  SL (Spec, "   package " & Vector_Pkg (TName)
                            & " is new Ada.Containers.Vectors (Positive, "
                            & TName & ");");
               end if;

               SL (Spec, "");
               SL (Spec, "   function Serialize (Message : " & TName
                         & ") return String;");
               SL (Spec, "   function Parse_" & TName
                         & " (Data : String) return " & TName & ";");
               SL (Spec, "");
            end;
         end loop;

         SL (Spec, "end " & Unit & ";");

         --  Body ------------------------------------------------------------
         SL (Body_Text, "--  Generated by protoc-ada. Do not edit by hand.");
         SL (Body_Text, "with Interfaces; use Interfaces;");
         SL (Body_Text, "with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;");
         SL (Body_Text, "with Protobuf;");
         if Has_Packed_Repeated then
            SL (Body_Text, "use type Protobuf.Wire_Type;");
         end if;
         SL (Body_Text, "package body " & Unit & " is");
         SL (Body_Text, "");

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
                                       & ", Serialize (Message." & C & " (I)));");
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
                     case T.Category is
                        when Cat_Int =>
                           SL (Body_Text, "      if Message." & C & " /= 0 then");
                           SL (Body_Text, "         Protobuf.Add_" & To_String (T.Suffix)
                                          & " (Buffer," & N & ", Message." & C & ");");
                           SL (Body_Text, "      end if;");
                        when Cat_Float =>
                           SL (Body_Text, "      if Message." & C & " /= 0.0 then");
                           SL (Body_Text, "         Protobuf.Add_" & To_String (T.Suffix)
                                          & " (Buffer," & N & ", Message." & C & ");");
                           SL (Body_Text, "      end if;");
                        when Cat_Bool =>
                           SL (Body_Text, "      if Message." & C & " then");
                           SL (Body_Text, "         Protobuf.Add_" & To_String (T.Suffix)
                                          & " (Buffer," & N & ", Message." & C & ");");
                           SL (Body_Text, "      end if;");
                        when Cat_Str =>
                           SL (Body_Text, "      if Length (Message." & C & ") > 0 then");
                           SL (Body_Text, "         Protobuf.Add_" & To_String (T.Suffix)
                                          & " (Buffer," & N & ", To_String (Message."
                                          & C & "));");
                           SL (Body_Text, "      end if;");
                        when Cat_Message =>
                           SL (Body_Text, "      if not Message." & C & ".Is_Empty then");
                           SL (Body_Text, "         Protobuf.Add_Message (Buffer," & N
                                          & ", Serialize (Message." & C & ".Element));");
                           SL (Body_Text, "      end if;");
                     end case;
                  end if;
               end Emit_Encode;

               --  Decode the case branch for one field.
               procedure Emit_Decode (F : Field_Def) is
                  T : constant Type_Info := Resolve (To_String (F.Proto_Type));
                  C : constant String := Field_Ident (F);
                  N : constant String := F.Number'Image;
               begin
                  SL (Body_Text, "            when" & N & " =>");
                  if F.Repeated then
                     if T.Category = Cat_Message then
                        SL (Body_Text, "               Result." & C
                                       & ".Append (Parse_" & To_String (T.Ada_Type)
                                       & " (Protobuf.As_Message_Bytes (Item)));");
                     elsif T.Category = Cat_Str then
                        SL (Body_Text, "               Result." & C
                                       & ".Append (To_Unbounded_String (Protobuf.As_"
                                       & To_String (T.Suffix) & " (Item)));");
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
                     SL (Body_Text, "               Result." & C
                                    & " := To_Unbounded_String (Protobuf.As_"
                                    & To_String (T.Suffix) & " (Item));");
                  elsif T.Category = Cat_Message then
                     SL (Body_Text, "               Result." & C & " := "
                                    & Holder_Pkg (To_String (T.Ada_Type))
                                    & ".To_Holder (Parse_" & To_String (T.Ada_Type)
                                    & " (Protobuf.As_Message_Bytes (Item)));");
                  else
                     SL (Body_Text, "               Result." & C & " := Protobuf.As_"
                                    & To_String (T.Suffix) & " (Item);");
                  end if;
               end Emit_Decode;

            begin
               SL (Body_Text, "   function Serialize (Message : " & TName
                              & ") return String is");
               SL (Body_Text, "      Buffer : Protobuf.Message_Buffer;");
               SL (Body_Text, "   begin");
               for F of M.Fields loop
                  Emit_Encode (F);
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
                  Emit_Decode (F);
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
