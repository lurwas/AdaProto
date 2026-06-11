with Ada.Containers;
with Ada.Calendar;
with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Streams.Stream_IO;
with Ada.Unchecked_Conversion;
with AUnit;
with AUnit.Assertions;
with AUnit.Simple_Test_Cases;
with AUnit.Test_Suites;
with Fixture_Loader;
with Interfaces;
with Protobuf;
with Sample;

package body Protobuf_Tests is
   use AUnit.Assertions;
   use Interfaces;
   use type Ada.Containers.Count_Type;
   use type Ada.Streams.Stream_Element_Offset;
   use type AUnit.Message_String;
   use type AUnit.Simple_Test_Cases.Test_Case_Access;
   use type AUnit.Test_Suites.Access_Test_Suite;

   type Test_Proc is access procedure;

   type Callback_Case is new AUnit.Simple_Test_Cases.Test_Case with record
      Test_Name : AUnit.Message_String;
      Proc : Test_Proc;
   end record;

   Max_Tests : constant Positive := 64;
   type Test_Case_Array is array (Positive range <>) of AUnit.Simple_Test_Cases.Test_Case_Access;
   Registered_Cases : Test_Case_Array (1 .. Max_Tests) := (others => null);
   Registered_Count : Natural := 0;
   Registered_Suite : AUnit.Test_Suites.Access_Test_Suite := null;

   overriding function Name (Test : Callback_Case) return AUnit.Message_String;
   overriding procedure Run_Test (Test : in out Callback_Case);

   function Name (Test : Callback_Case) return AUnit.Message_String is
   begin
      return Test.Test_Name;
   end Name;

   procedure Run_Test (Test : in out Callback_Case) is
   begin
      Test.Proc.all;
   end Run_Test;

   function New_Case (Test_Name : String; Proc : Test_Proc) return AUnit.Simple_Test_Cases.Test_Case_Access is
      Case_Ptr : constant AUnit.Simple_Test_Cases.Test_Case_Access :=
        new Callback_Case'
          (AUnit.Simple_Test_Cases.Test_Case with
           Test_Name => AUnit.Format (Test_Name),
           Proc => Proc);
   begin
      if Registered_Count = Max_Tests then
         raise Constraint_Error with "too many tests registered";
      end if;
      Registered_Count := Registered_Count + 1;
      Registered_Cases (Registered_Count) := Case_Ptr;
      return Case_Ptr;
   end New_Case;

   function To_Signed_32 is new Ada.Unchecked_Conversion (Unsigned_32, Integer_32);
   function To_Signed_64 is new Ada.Unchecked_Conversion (Unsigned_64, Integer_64);

   function Find_Field
     (Fields : Protobuf.Parsed_Field_Vectors.Vector;
      Number : Protobuf.Field_Number;
      Occurrence : Positive := 1) return Protobuf.Parsed_Field is
      Seen : Natural := 0;
   begin
      for F of Fields loop
         if F.Number = Number then
            Seen := Seen + 1;
            if Seen = Occurrence then
               return F;
            end if;
         end if;
      end loop;
      raise Protobuf.Parse_Error with "field not found";
   end Find_Field;

   function Count_Field
     (Fields : Protobuf.Parsed_Field_Vectors.Vector;
      Number : Protobuf.Field_Number) return Natural is
      Count : Natural := 0;
   begin
      for F of Fields loop
         if F.Number = Number then
            Count := Count + 1;
         end if;
      end loop;
      return Count;
   end Count_Field;

   function Decode_Fixed64_LE (Bytes : String; Offset : Positive) return Unsigned_64 is
      Value : Unsigned_64 := 0;
   begin
      for I in 0 .. 7 loop
         Value :=
           Value or
           Shift_Left
             (Unsigned_64 (Character'Pos (Bytes (Offset + I))),
              8 * I);
      end loop;
      return Value;
   end Decode_Fixed64_LE;

   function Hex_Nibble (C : Character) return Unsigned_8 is
   begin
      case C is
         when '0' .. '9' =>
            return Unsigned_8 (Character'Pos (C) - Character'Pos ('0'));
         when 'a' .. 'f' =>
            return Unsigned_8 (10 + Character'Pos (C) - Character'Pos ('a'));
         when 'A' .. 'F' =>
            return Unsigned_8 (10 + Character'Pos (C) - Character'Pos ('A'));
         when others =>
            raise Constraint_Error with "invalid hex digit";
      end case;
   end Hex_Nibble;

   function Decode_Hex (Hex : String) return String is
   begin
      if Hex'Length = 0 then
         return "";
      end if;
      if Hex'Length mod 2 /= 0 then
         raise Constraint_Error with "hex length must be even";
      end if;
      declare
         Bytes : String (1 .. Hex'Length / 2);
         J : Positive := Hex'First;
      begin
         for I in Bytes'Range loop
            Bytes (I) := Character'Val
              (Integer (Shift_Left (Hex_Nibble (Hex (J)), 4) or Hex_Nibble (Hex (J + 1))));
            J := J + 2;
         end loop;
         return Bytes;
      end;
   end Decode_Hex;

   function Next_Rand (State : in out Unsigned_64) return Unsigned_64 is
   begin
      State := State * 6364136223846793005 + 1442695040888963407;
      return State;
   end Next_Rand;

   function Rand_I32 (State : in out Unsigned_64) return Integer_32 is
   begin
      return To_Signed_32 (Unsigned_32 (Next_Rand (State) and 16#FFFF_FFFF#));
   end Rand_I32;

   function Rand_I64 (State : in out Unsigned_64) return Integer_64 is
   begin
      return To_Signed_64 (Next_Rand (State));
   end Rand_I64;

   function Rand_U32 (State : in out Unsigned_64) return Unsigned_32 is
   begin
      return Unsigned_32 (Next_Rand (State) and 16#FFFF_FFFF#);
   end Rand_U32;

   function Rand_U64 (State : in out Unsigned_64) return Unsigned_64 is
   begin
      return Next_Rand (State);
   end Rand_U64;

   function Rand_Bool (State : in out Unsigned_64) return Boolean is
   begin
      return (Next_Rand (State) and 1) = 1;
   end Rand_Bool;

   function Rand_Ascii (State : in out Unsigned_64; Length : Positive) return String is
      S : String (1 .. Length);
   begin
      for I in S'Range loop
         S (I) := Character'Val (Character'Pos ('a') + Integer (Next_Rand (State) mod 26));
      end loop;
      return S;
   end Rand_Ascii;

   function Img_U64 (Value : Unsigned_64) return String is
   begin
      return Ada.Strings.Fixed.Trim (Unsigned_64'Image (Value), Ada.Strings.Both);
   end Img_U64;

   procedure Populate_Diff_Case_From_Seed
     (B : in out Protobuf.Message_Buffer;
      Seed : Unsigned_64) is
      I32 : constant Integer_32 :=
        Integer_32 ((Seed * 1103515245 + 12345) mod 2_000_001) - 1_000_000;
      U64 : constant Unsigned_64 :=
        Seed * 6364136223846793005 + 1442695040888963407;
      S32 : constant Integer_32 :=
        Integer_32 ((Seed * 214013 + 2531011) mod 200_001) - 100_000;
      S64 : constant Integer_64 :=
        To_Signed_64 ((Seed * 11400714819323198485) xor 16#A5A5_A5A5_A5A5_A5A5#);
      B0 : constant Character := Character'Val (Integer (Seed and 16#FF#));
      B1 : constant Character := Character'Val (Integer (Shift_Right (Seed and 16#FF00#, 8)));
   begin
      Protobuf.Add_Int32 (B, 1, I32);
      Protobuf.Add_UInt64 (B, 4, U64);
      Protobuf.Add_SInt32 (B, 5, S32);
      Protobuf.Add_SInt64 (B, 6, S64);
      Protobuf.Add_String (B, 14, "seed-" & Img_U64 (Seed));
      Protobuf.Add_Bytes (B, 15, B0 & B1 & Character'Val (16#AA#));
      declare
         Nested : Protobuf.Message_Buffer;
      begin
         Protobuf.Add_Int32 (Nested, 1, Integer_32 (Seed mod 10_000) - 5_000);
         Protobuf.Add_String (Nested, 2, "n-" & Img_U64 (Seed mod 97));
         Protobuf.Add_Message (B, 16, Protobuf.To_String (Nested));
      end;
      Protobuf.Add_Int32 (B, 17, I32);
      Protobuf.Add_Int32 (B, 17, -I32);
      Protobuf.Add_Int32 (B, 17, Integer_32 (Seed mod 1000));
      Protobuf.Add_Packed_SInt32 (B, 18, (S32, -S32, Integer_32 (Seed mod 101) - 50));
   end Populate_Diff_Case_From_Seed;

   type Chunked_Input_Stream is new Ada.Streams.Root_Stream_Type with record
      Data : Ada.Strings.Unbounded.Unbounded_String;
      Pos  : Natural := 1;
      Chunk_Size : Positive := 1;
   end record;

   overriding procedure Read
     (Stream : in out Chunked_Input_Stream;
      Item   : out Ada.Streams.Stream_Element_Array;
      Last   : out Ada.Streams.Stream_Element_Offset);

   overriding procedure Write
     (Stream : in out Chunked_Input_Stream;
      Item   : Ada.Streams.Stream_Element_Array);

   procedure Read
     (Stream : in out Chunked_Input_Stream;
      Item   : out Ada.Streams.Stream_Element_Array;
      Last   : out Ada.Streams.Stream_Element_Offset) is
      Source : constant String := Ada.Strings.Unbounded.To_String (Stream.Data);
      Remaining : Natural := 0;
      To_Copy : Natural := 0;
   begin
      if Stream.Pos > Source'Length then
         Last := Item'First - 1;
         return;
      end if;
      Remaining := Source'Length - Stream.Pos + 1;
      To_Copy := Natural'Min (Natural (Item'Length), Natural'Min (Stream.Chunk_Size, Remaining));
      for I in 0 .. To_Copy - 1 loop
         Item (Item'First + Ada.Streams.Stream_Element_Offset (I)) :=
           Ada.Streams.Stream_Element (Character'Pos (Source (Stream.Pos + I)));
      end loop;
      Stream.Pos := Stream.Pos + To_Copy;
      Last := Item'First + Ada.Streams.Stream_Element_Offset (To_Copy) - 1;
   end Read;

   procedure Write
     (Stream : in out Chunked_Input_Stream;
      Item   : Ada.Streams.Stream_Element_Array) is
      pragma Unreferenced (Stream, Item);
   begin
      raise Program_Error with "write not supported";
   end Write;

   procedure Populate_All_Types (B : in out Protobuf.Message_Buffer) is
   begin
      Protobuf.Add_Int32 (B, 1, -123);
      Protobuf.Add_Int64 (B, 2, -4_567_890_123);
      Protobuf.Add_UInt32 (B, 3, 3_000_000_000);
      Protobuf.Add_UInt64 (B, 4, 1_234_567_890_123_456_789);
      Protobuf.Add_SInt32 (B, 5, -321);
      Protobuf.Add_SInt64 (B, 6, -6_543_219_876_543);
      Protobuf.Add_Bool (B, 7, True);
      Protobuf.Add_Fixed32 (B, 8, 16#DEAD_BEEF#);
      Protobuf.Add_Fixed64 (B, 9, 16#0123_4567_89AB_CDEF#);
      Protobuf.Add_SFixed32 (B, 10, -2_222);
      Protobuf.Add_SFixed64 (B, 11, -3_333_333_333);
      Protobuf.Add_Float (B, 12, 3.5);
      Protobuf.Add_Double (B, 13, -12_345.6789);
      Protobuf.Add_String (B, 14, "hello ada");
      Protobuf.Add_Bytes (B, 15, Character'Val (0) & Character'Val (1) & Character'Val (16#FE#));

      declare
         Nested : Protobuf.Message_Buffer;
      begin
         Protobuf.Add_Int32 (Nested, 1, 7);
         Protobuf.Add_String (Nested, 2, "nested");
         Protobuf.Add_Message (B, 16, Protobuf.To_String (Nested));
      end;

      Protobuf.Add_Int32 (B, 17, 1);
      Protobuf.Add_Int32 (B, 17, -1);
      Protobuf.Add_Int32 (B, 17, 150);
      Protobuf.Add_Packed_SInt32 (B, 18, (-1, 0, 1, 150, -150));
   end Populate_All_Types;

   procedure Populate_Advanced_Types (B : in out Protobuf.Message_Buffer) is
   begin
      Protobuf.Add_String (B, 2, "selected");
      Protobuf.Add_Packed_Fixed64
        (B,
         3,
         (16#1122_3344_5566_7788#,
          16#FFEE_DDCC_BBAA_0099#));
      Protobuf.Add_Bytes (B, 4, "");
      Protobuf.Add_Bytes (B, 4, Character'Val (0) & Character'Val (16#AB#) & Character'Val (16#CD#));
      Protobuf.Add_Bool (B, 5, True);
      Protobuf.Add_String (B, 6, "hello-advanced");
      Protobuf.Add_Bytes (B, 7, Character'Val (0) & Character'Val (16#7F#) & Character'Val (16#80#) & Character'Val (16#FF#));
      declare
         Nested : Protobuf.Message_Buffer;
      begin
         Protobuf.Add_Int32 (Nested, 1, -42);
         Protobuf.Add_String (Nested, 2, "edge");
         Protobuf.Add_Message (B, 8, Protobuf.To_String (Nested));
      end;
   end Populate_Advanced_Types;

   procedure Assert_All_Types_Fields (Fields : Protobuf.Parsed_Field_Vectors.Vector) is
   begin
      Assert (Protobuf.As_Int32 (Find_Field (Fields, 1)) = -123, "int32");
      Assert (Protobuf.As_Int64 (Find_Field (Fields, 2)) = -4_567_890_123, "int64");
      Assert (Protobuf.As_UInt32 (Find_Field (Fields, 3)) = 3_000_000_000, "uint32");
      Assert (Protobuf.As_UInt64 (Find_Field (Fields, 4)) = 1_234_567_890_123_456_789, "uint64");
      Assert (Protobuf.As_SInt32 (Find_Field (Fields, 5)) = -321, "sint32");
      Assert (Protobuf.As_SInt64 (Find_Field (Fields, 6)) = -6_543_219_876_543, "sint64");
      Assert (Protobuf.As_Bool (Find_Field (Fields, 7)), "bool");
      Assert (Protobuf.As_Fixed32 (Find_Field (Fields, 8)) = 16#DEAD_BEEF#, "fixed32");
      Assert (Protobuf.As_Fixed64 (Find_Field (Fields, 9)) = 16#0123_4567_89AB_CDEF#, "fixed64");
      Assert (Protobuf.As_SFixed32 (Find_Field (Fields, 10)) = -2_222, "sfixed32");
      Assert (Protobuf.As_SFixed64 (Find_Field (Fields, 11)) = -3_333_333_333, "sfixed64");
      Assert (abs (Protobuf.As_Float (Find_Field (Fields, 12)) - 3.5) < 0.0001, "float");
      Assert (abs (Protobuf.As_Double (Find_Field (Fields, 13)) - (-12_345.6789)) < 0.000001, "double");
      Assert (Protobuf.As_String (Find_Field (Fields, 14)) = "hello ada", "string");
      Assert (Protobuf.As_Bytes (Find_Field (Fields, 15)) =
              Character'Val (0) & Character'Val (1) & Character'Val (16#FE#),
              "bytes");

      declare
         Nested_Bytes : constant String := Protobuf.As_Message_Bytes (Find_Field (Fields, 16));
         Nested_Fields : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Nested_Bytes);
      begin
         Assert (Protobuf.As_Int32 (Find_Field (Nested_Fields, 1)) = 7, "nested int32");
         Assert (Protobuf.As_String (Find_Field (Nested_Fields, 2)) = "nested", "nested string");
      end;

      Assert (Count_Field (Fields, 17) = 3, "repeated int32 count");
      Assert (Protobuf.As_Int32 (Find_Field (Fields, 17, 1)) = 1, "repeated #1");
      Assert (Protobuf.As_Int32 (Find_Field (Fields, 17, 2)) = -1, "repeated #2");
      Assert (Protobuf.As_Int32 (Find_Field (Fields, 17, 3)) = 150, "repeated #3");

      declare
         Packed : constant Protobuf.Int32_Array := Protobuf.Decode_Packed_SInt32 (Protobuf.As_Bytes (Find_Field (Fields, 18)));
      begin
         Assert (Packed'Length = 5, "packed length");
         Assert (Packed (1) = -1 and Packed (2) = 0 and Packed (3) = 1 and Packed (4) = 150 and Packed (5) = -150,
                 "packed sint32 values");
      end;
   end Assert_All_Types_Fields;

   procedure Assert_Advanced_Types_Fields (Fields : Protobuf.Parsed_Field_Vectors.Vector) is
   begin
      Assert (Count_Field (Fields, 1) = 0, "oneof int32 branch should not be present");
      Assert (Protobuf.As_String (Find_Field (Fields, 2)) = "selected", "oneof text");
      declare
         Packed : constant String := Protobuf.As_Bytes (Find_Field (Fields, 3));
      begin
         Assert (Packed'Length = 16, "packed fixed64 payload length");
         Assert (Decode_Fixed64_LE (Packed, Packed'First) = 16#1122_3344_5566_7788#, "packed fixed64 #1");
         Assert (Decode_Fixed64_LE (Packed, Packed'First + 8) = 16#FFEE_DDCC_BBAA_0099#, "packed fixed64 #2");
      end;
      Assert (Count_Field (Fields, 4) = 2, "chunks count");
      Assert (Protobuf.As_Bytes (Find_Field (Fields, 4, 1)) = "", "empty chunk");
      Assert (Protobuf.As_Bytes (Find_Field (Fields, 4, 2)) =
                Character'Val (0) & Character'Val (16#AB#) & Character'Val (16#CD#),
              "binary chunk");
      Assert (Protobuf.As_Bool (Find_Field (Fields, 5)), "flag");
      Assert (Protobuf.As_String (Find_Field (Fields, 6)) = "hello-advanced", "utf8/ascii");
      Assert (Protobuf.As_Bytes (Find_Field (Fields, 7)) =
                Character'Val (0) & Character'Val (16#7F#) & Character'Val (16#80#) & Character'Val (16#FF#),
              "blob");
      declare
         Nested_Bytes : constant String := Protobuf.As_Message_Bytes (Find_Field (Fields, 8));
         Nested_Fields : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Nested_Bytes);
      begin
         Assert (Protobuf.As_Int32 (Find_Field (Nested_Fields, 1)) = -42, "advanced nested int32");
         Assert (Protobuf.As_String (Find_Field (Nested_Fields, 2)) = "edge", "advanced nested string");
      end;
   end Assert_Advanced_Types_Fields;

   procedure Test_Empty_Message_Encodes_Empty is
      B : Protobuf.Message_Buffer;
   begin
      Assert (Protobuf.To_String (B) = "", "empty message must serialize to empty string");
   end Test_Empty_Message_Encodes_Empty;

   procedure Test_All_Scalar_Encodings is
      B : Protobuf.Message_Buffer;
      Fields : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      Populate_All_Types (B);
      Fields := Protobuf.Parse_From_String (Protobuf.To_String (B));
      Assert_All_Types_Fields (Fields);
   end Test_All_Scalar_Encodings;

   procedure Test_Serialize_Deserialize_String_Aliases is
      B : Protobuf.Message_Buffer;
      Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      Protobuf.Add_Int32 (B, 1, 12345);
      Protobuf.Add_String (B, 2, "alias-check");

      declare
         Encoded_A : constant String := Protobuf.To_String (B);
         Encoded_B : constant String := Protobuf.Serialize_To_String (B);
      begin
         Assert (Encoded_A = Encoded_B, "Serialize_To_String must match To_String");
         Parsed := Protobuf.Deserialize_From_String (Encoded_B);
      end;
      Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1)) = 12345, "Deserialize_From_String int32");
      Assert (Protobuf.As_String (Find_Field (Parsed, 2)) = "alias-check", "Deserialize_From_String string");
   end Test_Serialize_Deserialize_String_Aliases;

   procedure Test_Randomized_Roundtrip is
      State : Unsigned_64 := 16#C0DE_CAFE_1234_5678#;
   begin
      for I in 1 .. 300 loop
         declare
            B : Protobuf.Message_Buffer;
            V_I32 : constant Integer_32 := Rand_I32 (State);
            V_I64 : constant Integer_64 := Rand_I64 (State);
            V_U32 : constant Unsigned_32 := Rand_U32 (State);
            V_U64 : constant Unsigned_64 := Rand_U64 (State);
            V_S32 : constant Integer_32 := Rand_I32 (State);
            V_S64 : constant Integer_64 := Rand_I64 (State);
            V_Bool : constant Boolean := Rand_Bool (State);
            V_Str : constant String := Rand_Ascii (State, 8);
            Parsed : Protobuf.Parsed_Field_Vectors.Vector;
         begin
            Protobuf.Add_Int32 (B, 1, V_I32);
            Protobuf.Add_Int64 (B, 2, V_I64);
            Protobuf.Add_UInt32 (B, 3, V_U32);
            Protobuf.Add_UInt64 (B, 4, V_U64);
            Protobuf.Add_SInt32 (B, 5, V_S32);
            Protobuf.Add_SInt64 (B, 6, V_S64);
            Protobuf.Add_Bool (B, 7, V_Bool);
            Protobuf.Add_String (B, 8, V_Str);
            Protobuf.Add_Packed_SInt32 (B, 9, (V_S32, -V_S32, Integer_32 (I)));

            Parsed := Protobuf.Deserialize_From_String (Protobuf.Serialize_To_String (B));
            Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1)) = V_I32, "random int32");
            Assert (Protobuf.As_Int64 (Find_Field (Parsed, 2)) = V_I64, "random int64");
            Assert (Protobuf.As_UInt32 (Find_Field (Parsed, 3)) = V_U32, "random uint32");
            Assert (Protobuf.As_UInt64 (Find_Field (Parsed, 4)) = V_U64, "random uint64");
            Assert (Protobuf.As_SInt32 (Find_Field (Parsed, 5)) = V_S32, "random sint32");
            Assert (Protobuf.As_SInt64 (Find_Field (Parsed, 6)) = V_S64, "random sint64");
            Assert (Protobuf.As_Bool (Find_Field (Parsed, 7)) = V_Bool, "random bool");
            Assert (Protobuf.As_String (Find_Field (Parsed, 8)) = V_Str, "random string");
         end;
      end loop;
   end Test_Randomized_Roundtrip;

   procedure Test_Boundary_Value_Matrix is
      B : Protobuf.Message_Buffer;
      Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      Protobuf.Add_Int32 (B, 1, Integer_32'First);
      Protobuf.Add_Int32 (B, 1, Integer_32'Last);
      Protobuf.Add_Int64 (B, 2, Integer_64'First);
      Protobuf.Add_Int64 (B, 2, Integer_64'Last);
      Protobuf.Add_UInt32 (B, 3, Unsigned_32'First);
      Protobuf.Add_UInt32 (B, 3, Unsigned_32'Last);
      Protobuf.Add_UInt64 (B, 4, Unsigned_64'First);
      Protobuf.Add_UInt64 (B, 4, Unsigned_64'Last);
      Protobuf.Add_SInt32 (B, 5, Integer_32'First);
      Protobuf.Add_SInt32 (B, 5, Integer_32'Last);
      Protobuf.Add_SInt64 (B, 6, Integer_64'First);
      Protobuf.Add_SInt64 (B, 6, Integer_64'Last);
      Protobuf.Add_Float (B, 7, Protobuf.Float32'First);
      Protobuf.Add_Float (B, 7, Protobuf.Float32'Last);
      Protobuf.Add_Double (B, 8, Protobuf.Float64'First);
      Protobuf.Add_Double (B, 8, Protobuf.Float64'Last);

      Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));
      Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1, 1)) = Integer_32'First, "boundary int32 first");
      Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1, 2)) = Integer_32'Last, "boundary int32 last");
      Assert (Protobuf.As_Int64 (Find_Field (Parsed, 2, 1)) = Integer_64'First, "boundary int64 first");
      Assert (Protobuf.As_Int64 (Find_Field (Parsed, 2, 2)) = Integer_64'Last, "boundary int64 last");
      Assert (Protobuf.As_UInt32 (Find_Field (Parsed, 3, 1)) = Unsigned_32'First, "boundary uint32 first");
      Assert (Protobuf.As_UInt32 (Find_Field (Parsed, 3, 2)) = Unsigned_32'Last, "boundary uint32 last");
      Assert (Protobuf.As_UInt64 (Find_Field (Parsed, 4, 1)) = Unsigned_64'First, "boundary uint64 first");
      Assert (Protobuf.As_UInt64 (Find_Field (Parsed, 4, 2)) = Unsigned_64'Last, "boundary uint64 last");
   end Test_Boundary_Value_Matrix;

   procedure Test_Large_Payload_Stress is
      Large : String (1 .. 1_000_000);
      B : Protobuf.Message_Buffer;
      Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      for I in Large'Range loop
         Large (I) := Character'Val (Character'Pos ('a') + (I mod 26));
      end loop;
      Protobuf.Add_String (B, 1, Large);
      Protobuf.Add_Packed_UInt32
        (B,
         2,
         (1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10));
      Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));
      Assert (Protobuf.As_String (Find_Field (Parsed, 1)) = Large, "large string roundtrip");
   end Test_Large_Payload_Stress;

   procedure Test_Malformed_Fuzz_Corpus is
      State : Unsigned_64 := 16#1234_5678_9ABC_DEF0#;
   begin
      for I in 1 .. 500 loop
         declare
            Len : constant Natural := Natural (Next_Rand (State) mod 64);
            S : String (1 .. (if Len = 0 then 1 else Len));
            Failed_Ok : Boolean := False;
         begin
            if Len = 0 then
               S (1) := Character'Val (0);
            else
               for J in 1 .. Len loop
                  S (J) := Character'Val (Integer (Next_Rand (State) and 16#FF#));
               end loop;
            end if;
            begin
               declare
                  Ignore : constant Protobuf.Parsed_Field_Vectors.Vector :=
                    Protobuf.Parse_From_String (if Len = 0 then "" else S (1 .. Len));
               begin
                  null;
               end;
            exception
               when Protobuf.Parse_Error =>
                  Failed_Ok := True;
               when others =>
                  Assert (False, "unexpected exception in fuzz corpus");
            end;
            pragma Unreferenced (Failed_Ok);
         end;
      end loop;
   end Test_Malformed_Fuzz_Corpus;

   procedure Test_Malformed_Corpus_Fixture is
      Corpus : constant String := Fixture_Loader.Read_Fixture ("malformed_corpus.hex");
      Line_Start : Positive := Corpus'First;
   begin
      for I in Corpus'Range loop
         if Corpus (I) = ASCII.LF then
            if I > Line_Start then
               declare
                  Line : constant String := Corpus (Line_Start .. I - 1);
                  Data : constant String := Decode_Hex (Line);
               begin
                  begin
                     declare
                        Ignore : constant Protobuf.Parsed_Field_Vectors.Vector :=
                          Protobuf.Parse_From_String (Data);
                     begin
                        null;
                     end;
                  exception
                     when Protobuf.Parse_Error =>
                        null;
                     when others =>
                        Assert (False, "unexpected exception in malformed corpus fixture");
                  end;
               end;
            end if;
            if I < Corpus'Last then
               Line_Start := I + 1;
            end if;
         end if;
      end loop;
   end Test_Malformed_Corpus_Fixture;

   procedure Test_Cpp_Differential_Corpus is
      Corpus : constant String := Fixture_Loader.Read_Fixture ("all_types_corpus.hex");
      Line_Start : Positive := Corpus'First;
      Seed : Unsigned_64 := 1;
   begin
      for I in Corpus'Range loop
         if Corpus (I) = ASCII.LF then
            if I > Line_Start then
               declare
                  Line : constant String := Corpus (Line_Start .. I - 1);
                  Expected : constant String := Decode_Hex (Line);
                  B : Protobuf.Message_Buffer;
               begin
                  Populate_Diff_Case_From_Seed (B, Seed);
                  Assert (Protobuf.To_String (B) = Expected, "cpp differential mismatch seed=" & Img_U64 (Seed));
                  Seed := Seed + 1;
               end;
            end if;
            if I < Corpus'Last then
               Line_Start := I + 1;
            end if;
         end if;
      end loop;
      Assert (Seed = 129, "corpus should contain 128 lines");
   end Test_Cpp_Differential_Corpus;

   procedure Test_Unknown_Fields_Stability is
      B : Protobuf.Message_Buffer;
      Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      Protobuf.Add_Int32 (B, 1, 10);
      Protobuf.Add_Fixed32 (B, 19_000, 16#DEAD_BEEF#);
      Protobuf.Add_String (B, 2, "known");
      Protobuf.Add_UInt64 (B, 29_000, 123456789);
      Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));
      Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1)) = 10, "known field #1");
      Assert (Protobuf.As_String (Find_Field (Parsed, 2)) = "known", "known field #2");
      Assert (Count_Field (Parsed, 19_000) = 1, "unknown fixed field preserved");
      Assert (Count_Field (Parsed, 29_000) = 1, "unknown varint field preserved");
   end Test_Unknown_Fields_Stability;

   procedure Test_Packed_Unpacked_Equivalence is
      Packed_B : Protobuf.Message_Buffer;
      Unpacked_B : Protobuf.Message_Buffer;
      Packed_Parsed : Protobuf.Parsed_Field_Vectors.Vector;
      Unpacked_Parsed : Protobuf.Parsed_Field_Vectors.Vector;
      Packed_Values : Protobuf.Int32_Array (1 .. 3) := (-10, 0, 25);
   begin
      Protobuf.Add_Packed_Int32 (Packed_B, 1, Packed_Values);
      Protobuf.Add_Int32 (Unpacked_B, 1, -10);
      Protobuf.Add_Int32 (Unpacked_B, 1, 0);
      Protobuf.Add_Int32 (Unpacked_B, 1, 25);

      Packed_Parsed := Protobuf.Parse_From_String (Protobuf.To_String (Packed_B));
      Unpacked_Parsed := Protobuf.Parse_From_String (Protobuf.To_String (Unpacked_B));

      declare
         Decoded_Packed : constant Protobuf.Int32_Array :=
           Protobuf.Decode_Packed_Int32 (Protobuf.As_Bytes (Find_Field (Packed_Parsed, 1)));
      begin
         Assert (Decoded_Packed'Length = 3, "packed len");
         Assert (Decoded_Packed (1) = Protobuf.As_Int32 (Find_Field (Unpacked_Parsed, 1, 1)), "eq #1");
         Assert (Decoded_Packed (2) = Protobuf.As_Int32 (Find_Field (Unpacked_Parsed, 1, 2)), "eq #2");
         Assert (Decoded_Packed (3) = Protobuf.As_Int32 (Find_Field (Unpacked_Parsed, 1, 3)), "eq #3");
      end;
   end Test_Packed_Unpacked_Equivalence;

   procedure Test_Public_Packed_Decode_Helpers is
      B : Protobuf.Message_Buffer;
      Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      Protobuf.Add_Packed_Bool (B, 1, (True, False, True));
      Protobuf.Add_Packed_Fixed64 (B, 2, (16#0102_0304_0506_0708#, 16#F0E0_D0C0_B0A0_9080#));
      Protobuf.Add_Packed_SFixed32 (B, 3, (-1, 0, 1));
      Protobuf.Add_Packed_Float (B, 4, (1.25, -2.5));
      Protobuf.Add_Packed_Double (B, 5, (3.25, -9.5));

      Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));

      declare
         V1 : constant Protobuf.Bool_Array := Protobuf.Decode_Packed_Bool (Protobuf.As_Bytes (Find_Field (Parsed, 1)));
         V2 : constant Protobuf.Fixed64_Array := Protobuf.Decode_Packed_Fixed64 (Protobuf.As_Bytes (Find_Field (Parsed, 2)));
         V3 : constant Protobuf.SFixed32_Array := Protobuf.Decode_Packed_SFixed32 (Protobuf.As_Bytes (Find_Field (Parsed, 3)));
         V4 : constant Protobuf.Float_Array := Protobuf.Decode_Packed_Float (Protobuf.As_Bytes (Find_Field (Parsed, 4)));
         V5 : constant Protobuf.Double_Array := Protobuf.Decode_Packed_Double (Protobuf.As_Bytes (Find_Field (Parsed, 5)));
      begin
         Assert (V1'Length = 3 and V1 (1) and (not V1 (2)) and V1 (3), "decode packed bool");
         Assert (V2'Length = 2 and V2 (1) = 16#0102_0304_0506_0708# and V2 (2) = 16#F0E0_D0C0_B0A0_9080#, "decode packed fixed64");
         Assert (V3'Length = 3 and V3 (1) = -1 and V3 (2) = 0 and V3 (3) = 1, "decode packed sfixed32");
         Assert (V4'Length = 2 and abs (V4 (1) - 1.25) < 0.0001 and abs (V4 (2) - (-2.5)) < 0.0001, "decode packed float");
         Assert (V5'Length = 2 and abs (V5 (1) - 3.25) < 0.0000001 and abs (V5 (2) - (-9.5)) < 0.0000001, "decode packed double");
      end;
   end Test_Public_Packed_Decode_Helpers;

   procedure Test_Stream_Chunking is
      B : Protobuf.Message_Buffer;
      Parsed : Protobuf.Parsed_Field_Vectors.Vector;
      S : aliased Chunked_Input_Stream;
   begin
      Populate_All_Types (B);
      declare
         Encoded : constant String := Protobuf.To_String (B);
      begin
         S.Data := Ada.Strings.Unbounded.To_Unbounded_String (Encoded);
         S.Pos := 1;
         S.Chunk_Size := 3;
         Parsed := Protobuf.Parse_From_Stream (S'Access, Encoded'Length);
      end;
      Assert_All_Types_Fields (Parsed);
   end Test_Stream_Chunking;

   procedure Test_Benchmark_Regression_Guard is
      use Ada.Calendar;
      Start_Time : Time;
      End_Time : Time;
      Iterations : constant Positive := 20_000;
   begin
      Start_Time := Clock;
      for I in 1 .. Iterations loop
         declare
            B : Protobuf.Message_Buffer;
            Parsed : Protobuf.Parsed_Field_Vectors.Vector;
         begin
            Protobuf.Add_Int32 (B, 1, Integer_32 (I));
            Protobuf.Add_UInt64 (B, 2, Unsigned_64 (I) * 17);
            Protobuf.Add_String (B, 3, "bench");
            Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));
            Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1)) = Integer_32 (I), "bench guard parse");
         end;
      end loop;
      End_Time := Clock;
      Assert (End_Time - Start_Time < 30.0, "benchmark guard exceeded threshold");
   end Test_Benchmark_Regression_Guard;

   procedure Test_Stream_Serialization is
      package SIO renames Ada.Streams.Stream_IO;
      Tmp : constant String := "tests/.tmp-stream.bin";
      File : SIO.File_Type;
      B : Protobuf.Message_Buffer;
      Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      Protobuf.Add_String (B, 1, "stream");
      Protobuf.Add_Int32 (B, 2, 42);

      SIO.Create (File, SIO.Out_File, Tmp);
      Protobuf.Write_To_Stream (B, SIO.Stream (File));
      SIO.Close (File);

      SIO.Open (File, SIO.In_File, Tmp);
      Parsed := Protobuf.Parse_From_Stream (SIO.Stream (File), Natural (SIO.Size (File)));
      SIO.Close (File);
      Ada.Directories.Delete_File (Tmp);

      Assert (Protobuf.As_String (Find_Field (Parsed, 1)) = "stream", "stream string");
      Assert (Protobuf.As_Int32 (Find_Field (Parsed, 2)) = 42, "stream int");
   end Test_Stream_Serialization;

   procedure Test_Fixture_Empty is
      Data : constant String := Fixture_Loader.Read_Fixture ("empty.bin");
      Parsed : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Data);
   begin
      Assert (Data'Length = 0, "empty fixture should be empty bytes");
      Assert (Parsed.Length = 0, "empty fixture should parse as no fields");
   end Test_Fixture_Empty;

   procedure Test_Fixture_All_Types_Compatibility is
      Data : constant String := Fixture_Loader.Read_Fixture ("all_types.bin");
      Parsed : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Data);
   begin
      Assert_All_Types_Fields (Parsed);
   end Test_Fixture_All_Types_Compatibility;

   procedure Test_Ada_Encoding_Matches_Golden is
      Golden : constant String := Fixture_Loader.Read_Fixture ("all_types.bin");
      B : Protobuf.Message_Buffer;
   begin
      Populate_All_Types (B);
      Assert (Protobuf.To_String (B) = Golden, "encoded bytes must match C++ fixture");
   end Test_Ada_Encoding_Matches_Golden;

   procedure Test_Fixture_Advanced_Types_Compatibility is
      Data : constant String := Fixture_Loader.Read_Fixture ("advanced_types.bin");
      Parsed : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Data);
   begin
      Assert_Advanced_Types_Fields (Parsed);
   end Test_Fixture_Advanced_Types_Compatibility;

   procedure Test_Ada_Encoding_Matches_Advanced_Golden is
      Golden : constant String := Fixture_Loader.Read_Fixture ("advanced_types.bin");
      B : Protobuf.Message_Buffer;
   begin
      Populate_Advanced_Types (B);
      Assert (Protobuf.To_String (B) = Golden, "advanced encoded bytes must match C++ fixture");
   end Test_Ada_Encoding_Matches_Advanced_Golden;

   procedure Test_Truncated_Varint_Fails is
      Failed : Boolean := False;
      Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         Ignore := Protobuf.Parse_From_String (Character'Val (8) & Character'Val (16#80#));
      exception
         when Protobuf.Parse_Error =>
            Failed := True;
      end;
      Assert (Failed, "truncated varint should fail");
   end Test_Truncated_Varint_Fails;

   procedure Test_Unsupported_Group_Wire_Fails is
      Failed : Boolean := False;
      Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         Ignore := Protobuf.Parse_From_String ("" & Character'Val (11));
      exception
         when Protobuf.Parse_Error =>
            Failed := True;
      end;
      Assert (Failed, "group wire should fail");
   end Test_Unsupported_Group_Wire_Fails;

   procedure Test_Wire_Mismatch_Fails is
      Failed : Boolean := False;
      B : Protobuf.Message_Buffer;
      Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      Protobuf.Add_Fixed32 (B, 1, 123);
      Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));
      begin
         declare
            Ignore : constant Integer_32 := Protobuf.As_Int32 (Find_Field (Parsed, 1));
         begin
            null;
         end;
      exception
         when Protobuf.Parse_Error =>
            Failed := True;
      end;
      Assert (Failed, "wire mismatch should fail");
   end Test_Wire_Mismatch_Fails;

   procedure Test_Clear_Buffer is
      B : Protobuf.Message_Buffer;
   begin
      Protobuf.Add_Int32 (B, 1, 1);
      Assert (Protobuf.To_String (B)'Length > 0, "buffer has content");
      Protobuf.Clear (B);
      Assert (Protobuf.To_String (B) = "", "buffer cleared");
   end Test_Clear_Buffer;

   procedure Test_Packed_Fixed32 is
      B : Protobuf.Message_Buffer;
      Fields : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      Protobuf.Add_Packed_Fixed32 (B, 1, (16#0102_0304#, 16#DEAD_BEEF#));
      Fields := Protobuf.Parse_From_String (Protobuf.To_String (B));
      declare
         Payload : constant String := Protobuf.As_Bytes (Find_Field (Fields, 1));
      begin
         Assert (Payload'Length = 8, "packed fixed32 payload length");
         Assert (Character'Pos (Payload (1)) = 16#04# and Character'Pos (Payload (4)) = 16#01#, "little endian #1");
         Assert (Character'Pos (Payload (5)) = 16#EF# and Character'Pos (Payload (8)) = 16#DE#, "little endian #2");
      end;
   end Test_Packed_Fixed32;

   procedure Test_Zero_Field_Number_Fails is
      Failed : Boolean := False;
      Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         Ignore := Protobuf.Parse_From_String ("" & Character'Val (0));
      exception
         when Protobuf.Parse_Error =>
            Failed := True;
      end;
      Assert (Failed, "field number zero must fail");
   end Test_Zero_Field_Number_Fails;

   procedure Test_Truncated_Length_Field_Fails is
      Failed : Boolean := False;
      Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         Ignore := Protobuf.Parse_From_String (Character'Val (10) & Character'Val (3) & "ab");
      exception
         when Protobuf.Parse_Error =>
            Failed := True;
      end;
      Assert (Failed, "truncated length-delimited field must fail");
   end Test_Truncated_Length_Field_Fails;

   procedure Test_Empty_Length_Field is
      Parsed : constant Protobuf.Parsed_Field_Vectors.Vector :=
        Protobuf.Parse_From_String (Character'Val (10) & Character'Val (0));
   begin
      Assert (Parsed.Length = 1, "single empty field parsed");
      Assert (Protobuf.As_String (Find_Field (Parsed, 1)) = "", "empty bytes/string value");
   end Test_Empty_Length_Field;

   procedure Test_Truncated_Fixed32_Fails is
      Failed : Boolean := False;
      Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         Ignore :=
           Protobuf.Parse_From_String
             (Character'Val (16#0D#) &
              Character'Val (16#11#) &
              Character'Val (16#22#) &
              Character'Val (16#33#));
      exception
         when Protobuf.Parse_Error =>
            Failed := True;
      end;
      Assert (Failed, "truncated fixed32 must fail");
   end Test_Truncated_Fixed32_Fails;

   procedure Test_Truncated_Fixed64_Fails is
      Failed : Boolean := False;
      Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         Ignore :=
           Protobuf.Parse_From_String
             (Character'Val (16#09#) &
              Character'Val (16#11#) &
              Character'Val (16#22#) &
              Character'Val (16#33#) &
              Character'Val (16#44#) &
              Character'Val (16#55#) &
              Character'Val (16#66#) &
              Character'Val (16#77#));
      exception
         when Protobuf.Parse_Error =>
            Failed := True;
      end;
      Assert (Failed, "truncated fixed64 must fail");
   end Test_Truncated_Fixed64_Fails;

   procedure Test_Find_Field_Not_Found_Fails is
      Failed : Boolean := False;
      Empty  : Protobuf.Parsed_Field_Vectors.Vector;
      Ignore : Protobuf.Parsed_Field;
   begin
      begin
         Ignore := Find_Field (Empty, 1);
      exception
         when Protobuf.Parse_Error =>
            Failed := True;
      end;
      Assert (Failed, "Find_Field should fail when field is absent");
   end Test_Find_Field_Not_Found_Fails;

   procedure Test_Decode_Hex_Invalid_Digit_Fails is
      Failed : Boolean := False;
      Ignore : String := "";
   begin
      begin
         Ignore := Decode_Hex ("GG");
      exception
         when Constraint_Error =>
            Failed := True;
      end;
      Assert (Failed, "invalid hex digit should raise Constraint_Error");
   end Test_Decode_Hex_Invalid_Digit_Fails;

   procedure Test_Decode_Hex_Odd_Length_Fails is
      Failed : Boolean := False;
      Ignore : String := "";
   begin
      begin
         Ignore := Decode_Hex ("ABC");
      exception
         when Constraint_Error =>
            Failed := True;
      end;
      Assert (Failed, "odd-length hex should raise Constraint_Error");
   end Test_Decode_Hex_Odd_Length_Fails;

   procedure Test_Chunked_Read_EOF is
      S : Chunked_Input_Stream;
      Item : Ada.Streams.Stream_Element_Array (1 .. 4);
      Last : Ada.Streams.Stream_Element_Offset;
   begin
      S.Data := Ada.Strings.Unbounded.To_Unbounded_String ("");
      S.Pos := 1;
      S.Chunk_Size := 1;
      Read (S, Item, Last);
      Assert (Last = Item'First - 1, "empty stream read should report EOF");
   end Test_Chunked_Read_EOF;

   procedure Test_Enum_And_Packed_Int64 is
      B : Protobuf.Message_Buffer;
      Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      Protobuf.Add_Enum (B, 1, -42);
      Protobuf.Add_Packed_Int64 (B, 2, (-9_223_372_036_854_775_808, -1, 0, 1, 9_223_372_036_854_775_807));
      Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));

      Assert (Protobuf.As_Enum (Find_Field (Parsed, 1)) = -42, "enum value");
      declare
         Decoded : constant Protobuf.Int64_Array :=
           Protobuf.Decode_Packed_Int64 (Protobuf.As_Bytes (Find_Field (Parsed, 2)));
      begin
         Assert (Decoded'Length = 5, "packed int64 size");
         Assert (Decoded (1) = -9_223_372_036_854_775_808, "packed int64 #1");
         Assert (Decoded (2) = -1, "packed int64 #2");
         Assert (Decoded (3) = 0, "packed int64 #3");
         Assert (Decoded (4) = 1, "packed int64 #4");
         Assert (Decoded (5) = 9_223_372_036_854_775_807, "packed int64 #5");
      end;
   end Test_Enum_And_Packed_Int64;

   procedure Test_Stream_Serialization_Empty_Buffer is
      package SIO renames Ada.Streams.Stream_IO;
      Tmp : constant String := "tests/.tmp-stream-empty.bin";
      File : SIO.File_Type;
      B : Protobuf.Message_Buffer;
   begin
      SIO.Create (File, SIO.Out_File, Tmp);
      Protobuf.Write_To_Stream (B, SIO.Stream (File));
      SIO.Close (File);

      SIO.Open (File, SIO.In_File, Tmp);
      Assert (Natural (SIO.Size (File)) = 0, "empty buffer should write zero bytes");
      SIO.Close (File);
      Ada.Directories.Delete_File (Tmp);
   end Test_Stream_Serialization_Empty_Buffer;

   procedure Test_Packed_UInt64_And_SInt64 is
      B : Protobuf.Message_Buffer;
      Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      Protobuf.Add_Packed_UInt64
        (B,
         1,
         (0,
          1,
          127,
          128,
          16#FFFF_FFFF_FFFF_FFFF#));
      Protobuf.Add_Packed_SInt64
        (B,
         2,
         (-9_223_372_036_854_775_808,
          -1,
          0,
          1,
          9_223_372_036_854_775_807));

      Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));

      declare
         U : constant Protobuf.UInt64_Array :=
           Protobuf.Decode_Packed_UInt64 (Protobuf.As_Bytes (Find_Field (Parsed, 1)));
         S : constant Protobuf.Int64_Array :=
           Protobuf.Decode_Packed_SInt64 (Protobuf.As_Bytes (Find_Field (Parsed, 2)));
      begin
         Assert (U'Length = 5, "packed uint64 size");
         Assert (U (1) = 0, "packed uint64 #1");
         Assert (U (2) = 1, "packed uint64 #2");
         Assert (U (3) = 127, "packed uint64 #3");
         Assert (U (4) = 128, "packed uint64 #4");
         Assert (U (5) = 16#FFFF_FFFF_FFFF_FFFF#, "packed uint64 #5");

         Assert (S'Length = 5, "packed sint64 size");
         Assert (S (1) = -9_223_372_036_854_775_808, "packed sint64 #1");
         Assert (S (2) = -1, "packed sint64 #2");
         Assert (S (3) = 0, "packed sint64 #3");
         Assert (S (4) = 1, "packed sint64 #4");
         Assert (S (5) = 9_223_372_036_854_775_807, "packed sint64 #5");
      end;
   end Test_Packed_UInt64_And_SInt64;

   --  Proves the protoc-ada generated types (Sample.Person / Sample.Pair):
   --  (1) serialize byte-identically to hand-written runtime calls,
   --  (2) round-trip through encode + decode,
   --  (3) honour proto3 default omission (default scalars are not emitted),
   --  including the reserved-word-escaped field Delta_F (proto field "delta").
   procedure Test_Generated_Types_Roundtrip is
      use Ada.Strings.Unbounded;
      P : constant Sample.Person :=
        (Id      => 42,
         Name    => To_Unbounded_String ("alice"),
         Active  => True,
         Balance => 3.5,
         Delta_F => -7,
         Blob    => To_Unbounded_String ("blob"));
      Reference : Protobuf.Message_Buffer;
   begin
      --  Wire compatibility: the generated encoder must match the exact bytes
      --  produced by the equivalent runtime calls, in field-number order.
      Protobuf.Add_Int32  (Reference, 1, 42);
      Protobuf.Add_String (Reference, 2, "alice");
      Protobuf.Add_Bool   (Reference, 3, True);
      Protobuf.Add_Double (Reference, 4, 3.5);
      Protobuf.Add_SInt64 (Reference, 5, -7);
      Protobuf.Add_Bytes  (Reference, 6, "blob");
      Assert (Sample.Serialize (P) = Protobuf.To_String (Reference),
              "generated Serialize matches hand-written wire bytes");

      --  Round-trip.
      declare
         D : constant Sample.Person :=
           Sample.Parse_Person (Sample.Serialize (P));
      begin
         Assert (D.Id = 42, "id round-trips");
         Assert (To_String (D.Name) = "alice", "name round-trips");
         Assert (D.Active = True, "active round-trips");
         Assert (D.Balance = 3.5, "balance round-trips");
         Assert (D.Delta_F = -7, "reserved-word field round-trips");
         Assert (To_String (D.Blob) = "blob", "bytes round-trip");
      end;

      --  proto3 default omission: an all-default message encodes to nothing.
      declare
         Empty : Sample.Person;
      begin
         Assert (Sample.Serialize (Empty) = "",
                 "default scalar fields are omitted on the wire");
      end;

      --  A second generated message type in the same unit.
      declare
         Q : constant Sample.Pair := (First => 1, Second => 2);
         R : constant Sample.Pair := Sample.Parse_Pair (Sample.Serialize (Q));
      begin
         Assert (R.First = 1 and R.Second = 2, "Pair round-trips");
      end;
   end Test_Generated_Types_Roundtrip;

   --  Phase 1b: enums (open, int32-valued) and repeated fields. Proves packed
   --  encode/decode wire-compatibility, repeated-string handling, and that the
   --  decoder also accepts the unpacked repeated encoding (conformance).
   procedure Test_Generated_Enums_And_Repeated is
      use Ada.Strings.Unbounded;
      B : Sample.Bag;
      Reference : Protobuf.Message_Buffer;
   begin
      B.Numbers.Append (1);
      B.Numbers.Append (2);
      B.Numbers.Append (-3);
      B.Tags.Append (To_Unbounded_String ("a"));
      B.Tags.Append (To_Unbounded_String ("bb"));
      B.Color_F := Sample.Color_GREEN;
      B.Palette.Append (Sample.Color_RED);
      B.Palette.Append (Sample.Color_BLUE);

      --  Wire compatibility: packed repeated scalars, repeated strings (one
      --  field each), and the enum encoded as int32.
      Protobuf.Add_Packed_Int32 (Reference, 1, (1, 2, -3));
      Protobuf.Add_String       (Reference, 2, "a");
      Protobuf.Add_String       (Reference, 2, "bb");
      Protobuf.Add_Int32        (Reference, 3, 2);
      Protobuf.Add_Packed_Int32 (Reference, 4, (1, 3));
      Assert (Sample.Serialize (B) = Protobuf.To_String (Reference),
              "generated repeated/enum encoder matches hand-written bytes");

      --  Round-trip.
      declare
         D : constant Sample.Bag := Sample.Parse_Bag (Sample.Serialize (B));
      begin
         Assert (Natural (D.Numbers.Length) = 3
                 and then D.Numbers (1) = 1 and then D.Numbers (3) = -3,
                 "packed repeated int32 round-trips");
         Assert (Natural (D.Tags.Length) = 2
                 and then To_String (D.Tags (2)) = "bb",
                 "repeated string round-trips");
         Assert (D.Color_F = Sample.Color_GREEN, "enum round-trips");
         Assert (Natural (D.Palette.Length) = 2
                 and then D.Palette (1) = Sample.Color_RED
                 and then D.Palette (2) = Sample.Color_BLUE,
                 "repeated enum round-trips");
      end;

      --  Conformance: the decoder must also accept the *unpacked* encoding of a
      --  packable repeated field (each element as a separate field entry).
      declare
         Unpacked : Protobuf.Message_Buffer;
      begin
         Protobuf.Add_Int32 (Unpacked, 1, 7);
         Protobuf.Add_Int32 (Unpacked, 1, 8);
         declare
            D : constant Sample.Bag :=
              Sample.Parse_Bag (Protobuf.To_String (Unpacked));
         begin
            Assert (Natural (D.Numbers.Length) = 2
                    and then D.Numbers (1) = 7 and then D.Numbers (2) = 8,
                    "decoder accepts unpacked repeated encoding");
         end;
      end;

      --  Empty repeated fields and a default enum encode to nothing.
      declare
         Empty : Sample.Bag;
      begin
         Assert (Sample.Serialize (Empty) = "",
                 "empty repeated fields and default enum are omitted");
      end;
   end Test_Generated_Enums_And_Repeated;

   --  Exercises the reserve-once / geometrically-grown serialization buffer:
   --  many fields force several reallocations past the initial capacity, a
   --  maximal varint exercises the 10-byte worst case, and Clear+reuse must
   --  reproduce a fresh encoding byte-for-byte. This pins the behaviour of the
   --  optimized encode path that replaced per-character Unbounded_String appends.
   procedure Test_Serialization_Buffer_Growth_And_Reuse is

      procedure Build (B : in out Protobuf.Message_Buffer) is
      begin
         --  50 varint fields + a 500-byte string + fixed64 + a 64-element packed
         --  field push the buffer well past its initial capacity, through
         --  multiple doublings (each of which copies the live bytes forward).
         for K in 1 .. 50 loop
            Protobuf.Add_UInt64
              (B, Protobuf.Field_Number (K), Unsigned_64 (K) * 1_000_000);
         end loop;
         Protobuf.Add_String (B, 200, (1 .. 500 => 'z'));
         Protobuf.Add_Fixed64 (B, 201, 16#0102_0304_0506_0708#);
         Protobuf.Add_Packed_UInt32 (B, 202, (1 .. 64 => 16#0FFF_FFFF#));
      end Build;

      B1 : Protobuf.Message_Buffer;
      B2 : Protobuf.Message_Buffer;
   begin
      Build (B1);
      Build (B2);

      --  Determinism: identical input must yield identical bytes across buffers.
      Assert (Protobuf.To_String (B1) = Protobuf.To_String (B2),
              "growth path is deterministic across buffers");

      --  Clear keeps the storage but resets length; reusing the buffer must
      --  reproduce exactly the same bytes as a fresh one.
      declare
         Fresh : constant String := Protobuf.To_String (B1);
      begin
         Protobuf.Clear (B1);
         Assert (Protobuf.To_String (B1) = "", "cleared buffer serializes to empty");
         Build (B1);
         Assert (Protobuf.To_String (B1) = Fresh,
                 "reused buffer matches a fresh encoding");
      end;

      --  Every value must survive encode + decode through the grown buffer.
      declare
         Parsed : constant Protobuf.Parsed_Field_Vectors.Vector :=
           Protobuf.Parse_From_String (Protobuf.To_String (B2));
      begin
         for K in 1 .. 50 loop
            Assert
              (Protobuf.As_UInt64 (Find_Field (Parsed, Protobuf.Field_Number (K)))
                 = Unsigned_64 (K) * 1_000_000,
               "uint64 field roundtrip after growth");
         end loop;
         Assert (Protobuf.As_String (Find_Field (Parsed, 200))'Length = 500,
                 "500-byte string preserved across growth");
         Assert (Protobuf.As_Fixed64 (Find_Field (Parsed, 201))
                   = 16#0102_0304_0506_0708#,
                 "fixed64 preserved across growth");
         declare
            U : constant Protobuf.UInt32_Array :=
              Protobuf.Decode_Packed_UInt32
                (Protobuf.As_Bytes (Find_Field (Parsed, 202)));
         begin
            Assert (U'Length = 64, "packed field length preserved");
            Assert (U (1) = 16#0FFF_FFFF# and U (64) = 16#0FFF_FFFF#,
                    "packed field values preserved");
         end;
      end;

      --  A maximal varint must use all 10 wire bytes and round-trip exactly,
      --  exercising the worst-case width the encoder reserves for.
      declare
         B : Protobuf.Message_Buffer;
      begin
         Protobuf.Add_UInt64 (B, 1, Unsigned_64'Last);
         declare
            S : constant String := Protobuf.To_String (B);
            Parsed : constant Protobuf.Parsed_Field_Vectors.Vector :=
              Protobuf.Parse_From_String (S);
         begin
            Assert (S'Length = 11, "max uint64 encodes to 1 tag + 10 value bytes");
            Assert (Protobuf.As_UInt64 (Find_Field (Parsed, 1)) = Unsigned_64'Last,
                    "max uint64 round-trips");
         end;
      end;
   end Test_Serialization_Buffer_Growth_And_Reuse;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   begin
      if Registered_Suite = null then
         Registered_Suite := AUnit.Test_Suites.New_Suite;
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("empty message", Test_Empty_Message_Encodes_Empty'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("all scalar encodings", Test_All_Scalar_Encodings'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("string alias api", Test_Serialize_Deserialize_String_Aliases'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("randomized roundtrip", Test_Randomized_Roundtrip'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("boundary matrix", Test_Boundary_Value_Matrix'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("large payload stress", Test_Large_Payload_Stress'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("malformed fuzz", Test_Malformed_Fuzz_Corpus'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("malformed corpus fixture", Test_Malformed_Corpus_Fixture'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("cpp differential corpus", Test_Cpp_Differential_Corpus'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("stream serialization", Test_Stream_Serialization'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("stream chunking", Test_Stream_Chunking'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("fixture empty", Test_Fixture_Empty'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("fixture all types", Test_Fixture_All_Types_Compatibility'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("golden match", Test_Ada_Encoding_Matches_Golden'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("fixture advanced types", Test_Fixture_Advanced_Types_Compatibility'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("advanced golden match", Test_Ada_Encoding_Matches_Advanced_Golden'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("unknown fields stability", Test_Unknown_Fields_Stability'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("packed unpacked equivalence", Test_Packed_Unpacked_Equivalence'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("public packed decode helpers", Test_Public_Packed_Decode_Helpers'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("benchmark regression guard", Test_Benchmark_Regression_Guard'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("truncated varint", Test_Truncated_Varint_Fails'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("unsupported group", Test_Unsupported_Group_Wire_Fails'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("wire mismatch", Test_Wire_Mismatch_Fails'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("clear buffer", Test_Clear_Buffer'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("packed fixed32", Test_Packed_Fixed32'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("zero field number", Test_Zero_Field_Number_Fails'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("truncated length", Test_Truncated_Length_Field_Fails'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("empty length", Test_Empty_Length_Field'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("truncated fixed32", Test_Truncated_Fixed32_Fails'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("truncated fixed64", Test_Truncated_Fixed64_Fails'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("find field missing", Test_Find_Field_Not_Found_Fails'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("decode hex invalid digit", Test_Decode_Hex_Invalid_Digit_Fails'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("decode hex odd length", Test_Decode_Hex_Odd_Length_Fails'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("chunked read eof", Test_Chunked_Read_EOF'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("enum and packed int64", Test_Enum_And_Packed_Int64'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("stream serialization empty", Test_Stream_Serialization_Empty_Buffer'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("packed uint64 and sint64", Test_Packed_UInt64_And_SInt64'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("serialization buffer growth and reuse", Test_Serialization_Buffer_Growth_And_Reuse'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("generated types roundtrip", Test_Generated_Types_Roundtrip'Access));
         AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("generated enums and repeated", Test_Generated_Enums_And_Repeated'Access));
      end if;
      return Registered_Suite;
   end Suite;

   procedure Cleanup is
   begin
      null;
   end Cleanup;

end Protobuf_Tests;
