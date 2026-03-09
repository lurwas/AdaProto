pragma Style_Checks (Off); pragma Warnings (Off);
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

with GNATcov_RTS.Buffers.PB_protobuf_tests;package body Protobuf_Tests is
   use AUnit.Assertions;
   use Interfaces;
   use type Ada.Containers.Count_Type;
   use type Ada.Streams.Stream_Element_Offset;
   use type AUnit.Message_String;
   use type AUnit.Simple_Test_Cases.Test_Case_Access;
   use type AUnit.Test_Suites.Access_Test_Suite;

   Discard_UNIT_BODY0:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,0);type Test_Proc is access procedure;

   Discard_UNIT_BODY1:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,1);type Callback_Case is new AUnit.Simple_Test_Cases.Test_Case with record
      Test_Name : AUnit.Message_String;
      Proc : Test_Proc;
   end record;

   Discard_UNIT_BODY2:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,2);Max_Tests : constant Positive := 64;
   Discard_UNIT_BODY3:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,3);type Test_Case_Array is array (Positive range <>) of AUnit.Simple_Test_Cases.Test_Case_Access;
   Discard_UNIT_BODY4:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,4);Registered_Cases : Test_Case_Array (1 .. Max_Tests) := (others => null);
   Discard_UNIT_BODY5:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,5);Registered_Count : Natural := 0;
   Discard_UNIT_BODY6:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,6);Registered_Suite : AUnit.Test_Suites.Access_Test_Suite := null;

   overriding function Name (Test : Callback_Case) return AUnit.Message_String;
   overriding procedure Run_Test (Test : in out Callback_Case);

   function Name (Test : Callback_Case) return AUnit.Message_String is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,7);return Test.Test_Name;
   end Name;

   procedure Run_Test (Test : in out Callback_Case) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,8);Test.Proc.all;
   end Run_Test;

   function New_Case (Test_Name : String; Proc : Test_Proc) return AUnit.Simple_Test_Cases.Test_Case_Access is
      Discard_UNIT_BODY9:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,9);Case_Ptr : constant AUnit.Simple_Test_Cases.Test_Case_Access :=
        new Callback_Case'
          (AUnit.Simple_Test_Cases.Test_Case with
           Test_Name => AUnit.Format (Test_Name),
           Proc => Proc);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,10);if Registered_Count = Max_Tests then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,11);raise Constraint_Error with "too many tests registered";
      end if;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,12);Registered_Count := Registered_Count + 1;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,13);Registered_Cases (Registered_Count) := Case_Ptr;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,14);return Case_Ptr;
   end New_Case;

   Discard_UNIT_BODY15:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,15);function To_Signed_32 is new Ada.Unchecked_Conversion (Unsigned_32, Integer_32);
   Discard_UNIT_BODY16:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,16);function To_Signed_64 is new Ada.Unchecked_Conversion (Unsigned_64, Integer_64);

   function Find_Field
     (Fields : Protobuf.Parsed_Field_Vectors.Vector;
      Number : Protobuf.Field_Number;
      Occurrence : Positive := 1) return Protobuf.Parsed_Field is
      Discard_UNIT_BODY17:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,17);Seen : Natural := 0;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,18);for F of Fields loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,19);if F.Number = Number then
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,20);Seen := Seen + 1;
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,21);if Seen = Occurrence then
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,22);return F;
            end if;
         end if;
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,23);raise Protobuf.Parse_Error with "field not found";
   end Find_Field;

   function Count_Field
     (Fields : Protobuf.Parsed_Field_Vectors.Vector;
      Number : Protobuf.Field_Number) return Natural is
      Discard_UNIT_BODY24:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,24);Count : Natural := 0;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,25);for F of Fields loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,26);if F.Number = Number then
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,27);Count := Count + 1;
         end if;
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,28);return Count;
   end Count_Field;

   function Decode_Fixed64_LE (Bytes : String; Offset : Positive) return Unsigned_64 is
      Discard_UNIT_BODY29:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,29);Value : Unsigned_64 := 0;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,30);for I in 0 .. 7 loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,31);Value :=
           Value or
           Shift_Left
             (Unsigned_64 (Character'Pos (Bytes (Offset + I))),
              8 * I);
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,32);return Value;
   end Decode_Fixed64_LE;

   function Hex_Nibble (C : Character) return Unsigned_8 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,33);case C is
         when '0' .. '9' =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,34);return Unsigned_8 (Character'Pos (C) - Character'Pos ('0'));
         when 'a' .. 'f' =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,35);return Unsigned_8 (10 + Character'Pos (C) - Character'Pos ('a'));
         when 'A' .. 'F' =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,36);return Unsigned_8 (10 + Character'Pos (C) - Character'Pos ('A'));
         when others =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,37);raise Constraint_Error with "invalid hex digit";
      end case;
   end Hex_Nibble;

   function Decode_Hex (Hex : String) return String is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,38);if Hex'Length = 0 then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,39);return "";
      end if;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,40);if Hex'Length mod 2 /= 0 then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,41);raise Constraint_Error with "hex length must be even";
      end if;
      declare
         Discard_UNIT_BODY42:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,42);Bytes : String (1 .. Hex'Length / 2);
         Discard_UNIT_BODY43:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,43);J : Positive := Hex'First;
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,44);for I in Bytes'Range loop
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,45);Bytes (I) := Character'Val
              (Integer (Shift_Left (Hex_Nibble (Hex (J)), 4) or Hex_Nibble (Hex (J + 1))));
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,46);J := J + 2;
         end loop;
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,47);return Bytes;
      end;
   end Decode_Hex;

   function Next_Rand (State : in out Unsigned_64) return Unsigned_64 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,48);State := State * 6364136223846793005 + 1442695040888963407;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,49);return State;
   end Next_Rand;

   function Rand_I32 (State : in out Unsigned_64) return Integer_32 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,50);return To_Signed_32 (Unsigned_32 (Next_Rand (State) and 16#FFFF_FFFF#));
   end Rand_I32;

   function Rand_I64 (State : in out Unsigned_64) return Integer_64 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,51);return To_Signed_64 (Next_Rand (State));
   end Rand_I64;

   function Rand_U32 (State : in out Unsigned_64) return Unsigned_32 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,52);return Unsigned_32 (Next_Rand (State) and 16#FFFF_FFFF#);
   end Rand_U32;

   function Rand_U64 (State : in out Unsigned_64) return Unsigned_64 is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,53);return Next_Rand (State);
   end Rand_U64;

   function Rand_Bool (State : in out Unsigned_64) return Boolean is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,54);return (Next_Rand (State) and 1) = 1;
   end Rand_Bool;

   function Rand_Ascii (State : in out Unsigned_64; Length : Positive) return String is
      Discard_UNIT_BODY55:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,55);S : String (1 .. Length);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,56);for I in S'Range loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,57);S (I) := Character'Val (Character'Pos ('a') + Integer (Next_Rand (State) mod 26));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,58);return S;
   end Rand_Ascii;

   function Img_U64 (Value : Unsigned_64) return String is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,59);return Ada.Strings.Fixed.Trim (Unsigned_64'Image (Value), Ada.Strings.Both);
   end Img_U64;

   procedure Populate_Diff_Case_From_Seed
     (B : in out Protobuf.Message_Buffer;
      Seed : Unsigned_64) is
      Discard_UNIT_BODY60:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,60);I32 : constant Integer_32 :=
        Integer_32 ((Seed * 1103515245 + 12345) mod 2_000_001) - 1_000_000;
      Discard_UNIT_BODY61:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,61);U64 : constant Unsigned_64 :=
        Seed * 6364136223846793005 + 1442695040888963407;
      Discard_UNIT_BODY62:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,62);S32 : constant Integer_32 :=
        Integer_32 ((Seed * 214013 + 2531011) mod 200_001) - 100_000;
      Discard_UNIT_BODY63:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,63);S64 : constant Integer_64 :=
        To_Signed_64 ((Seed * 11400714819323198485) xor 16#A5A5_A5A5_A5A5_A5A5#);
      Discard_UNIT_BODY64:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,64);B0 : constant Character := Character'Val (Integer (Seed and 16#FF#));
      Discard_UNIT_BODY65:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,65);B1 : constant Character := Character'Val (Integer (Shift_Right (Seed and 16#FF00#, 8)));
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,66);Protobuf.Add_Int32 (B, 1, I32);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,67);Protobuf.Add_UInt64 (B, 4, U64);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,68);Protobuf.Add_SInt32 (B, 5, S32);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,69);Protobuf.Add_SInt64 (B, 6, S64);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,70);Protobuf.Add_String (B, 14, "seed-" & Img_U64 (Seed));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,71);Protobuf.Add_Bytes (B, 15, B0 & B1 & Character'Val (16#AA#));
      declare
         Discard_UNIT_BODY72:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,72);Nested : Protobuf.Message_Buffer;
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,73);Protobuf.Add_Int32 (Nested, 1, Integer_32 (Seed mod 10_000) - 5_000);
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,74);Protobuf.Add_String (Nested, 2, "n-" & Img_U64 (Seed mod 97));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,75);Protobuf.Add_Message (B, 16, Protobuf.To_String (Nested));
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,76);Protobuf.Add_Int32 (B, 17, I32);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,77);Protobuf.Add_Int32 (B, 17, -I32);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,78);Protobuf.Add_Int32 (B, 17, Integer_32 (Seed mod 1000));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,79);Protobuf.Add_Packed_SInt32 (B, 18, (S32, -S32, Integer_32 (Seed mod 101) - 50));
   end Populate_Diff_Case_From_Seed;

   Discard_UNIT_BODY80:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,80);type Chunked_Input_Stream is new Ada.Streams.Root_Stream_Type with record
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
      Discard_UNIT_BODY81:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,81);Source : constant String := Ada.Strings.Unbounded.To_String (Stream.Data);
      Discard_UNIT_BODY82:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,82);Remaining : Natural := 0;
      Discard_UNIT_BODY83:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,83);To_Copy : Natural := 0;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,84);if Stream.Pos > Source'Length then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,85);Last := Item'First - 1;
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,86);return;
      end if;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,87);Remaining := Source'Length - Stream.Pos + 1;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,88);To_Copy := Natural'Min (Natural (Item'Length), Natural'Min (Stream.Chunk_Size, Remaining));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,89);for I in 0 .. To_Copy - 1 loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,90);Item (Item'First + Ada.Streams.Stream_Element_Offset (I)) :=
           Ada.Streams.Stream_Element (Character'Pos (Source (Stream.Pos + I)));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,91);Stream.Pos := Stream.Pos + To_Copy;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,92);Last := Item'First + Ada.Streams.Stream_Element_Offset (To_Copy) - 1;
   end Read;

   procedure Write
     (Stream : in out Chunked_Input_Stream;
      Item   : Ada.Streams.Stream_Element_Array) is
      pragma Unreferenced (Stream, Item);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,93);raise Program_Error with "write not supported";
   end Write;

   procedure Populate_All_Types (B : in out Protobuf.Message_Buffer) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,94);Protobuf.Add_Int32 (B, 1, -123);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,95);Protobuf.Add_Int64 (B, 2, -4_567_890_123);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,96);Protobuf.Add_UInt32 (B, 3, 3_000_000_000);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,97);Protobuf.Add_UInt64 (B, 4, 1_234_567_890_123_456_789);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,98);Protobuf.Add_SInt32 (B, 5, -321);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,99);Protobuf.Add_SInt64 (B, 6, -6_543_219_876_543);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,100);Protobuf.Add_Bool (B, 7, True);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,101);Protobuf.Add_Fixed32 (B, 8, 16#DEAD_BEEF#);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,102);Protobuf.Add_Fixed64 (B, 9, 16#0123_4567_89AB_CDEF#);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,103);Protobuf.Add_SFixed32 (B, 10, -2_222);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,104);Protobuf.Add_SFixed64 (B, 11, -3_333_333_333);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,105);Protobuf.Add_Float (B, 12, 3.5);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,106);Protobuf.Add_Double (B, 13, -12_345.6789);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,107);Protobuf.Add_String (B, 14, "hello ada");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,108);Protobuf.Add_Bytes (B, 15, Character'Val (0) & Character'Val (1) & Character'Val (16#FE#));

      declare
         Discard_UNIT_BODY109:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,109);Nested : Protobuf.Message_Buffer;
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,110);Protobuf.Add_Int32 (Nested, 1, 7);
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,111);Protobuf.Add_String (Nested, 2, "nested");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,112);Protobuf.Add_Message (B, 16, Protobuf.To_String (Nested));
      end;

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,113);Protobuf.Add_Int32 (B, 17, 1);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,114);Protobuf.Add_Int32 (B, 17, -1);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,115);Protobuf.Add_Int32 (B, 17, 150);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,116);Protobuf.Add_Packed_SInt32 (B, 18, (-1, 0, 1, 150, -150));
   end Populate_All_Types;

   procedure Populate_Advanced_Types (B : in out Protobuf.Message_Buffer) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,117);Protobuf.Add_String (B, 2, "selected");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,118);Protobuf.Add_Packed_Fixed64
        (B,
         3,
         (16#1122_3344_5566_7788#,
          16#FFEE_DDCC_BBAA_0099#));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,119);Protobuf.Add_Bytes (B, 4, "");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,120);Protobuf.Add_Bytes (B, 4, Character'Val (0) & Character'Val (16#AB#) & Character'Val (16#CD#));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,121);Protobuf.Add_Bool (B, 5, True);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,122);Protobuf.Add_String (B, 6, "hello-advanced");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,123);Protobuf.Add_Bytes (B, 7, Character'Val (0) & Character'Val (16#7F#) & Character'Val (16#80#) & Character'Val (16#FF#));
      declare
         Discard_UNIT_BODY124:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,124);Nested : Protobuf.Message_Buffer;
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,125);Protobuf.Add_Int32 (Nested, 1, -42);
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,126);Protobuf.Add_String (Nested, 2, "edge");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,127);Protobuf.Add_Message (B, 8, Protobuf.To_String (Nested));
      end;
   end Populate_Advanced_Types;

   procedure Assert_All_Types_Fields (Fields : Protobuf.Parsed_Field_Vectors.Vector) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,128);Assert (Protobuf.As_Int32 (Find_Field (Fields, 1)) = -123, "int32");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,129);Assert (Protobuf.As_Int64 (Find_Field (Fields, 2)) = -4_567_890_123, "int64");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,130);Assert (Protobuf.As_UInt32 (Find_Field (Fields, 3)) = 3_000_000_000, "uint32");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,131);Assert (Protobuf.As_UInt64 (Find_Field (Fields, 4)) = 1_234_567_890_123_456_789, "uint64");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,132);Assert (Protobuf.As_SInt32 (Find_Field (Fields, 5)) = -321, "sint32");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,133);Assert (Protobuf.As_SInt64 (Find_Field (Fields, 6)) = -6_543_219_876_543, "sint64");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,134);Assert (Protobuf.As_Bool (Find_Field (Fields, 7)), "bool");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,135);Assert (Protobuf.As_Fixed32 (Find_Field (Fields, 8)) = 16#DEAD_BEEF#, "fixed32");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,136);Assert (Protobuf.As_Fixed64 (Find_Field (Fields, 9)) = 16#0123_4567_89AB_CDEF#, "fixed64");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,137);Assert (Protobuf.As_SFixed32 (Find_Field (Fields, 10)) = -2_222, "sfixed32");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,138);Assert (Protobuf.As_SFixed64 (Find_Field (Fields, 11)) = -3_333_333_333, "sfixed64");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,139);Assert (abs (Protobuf.As_Float (Find_Field (Fields, 12)) - 3.5) < 0.0001, "float");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,140);Assert (abs (Protobuf.As_Double (Find_Field (Fields, 13)) - (-12_345.6789)) < 0.000001, "double");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,141);Assert (Protobuf.As_String (Find_Field (Fields, 14)) = "hello ada", "string");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,142);Assert (Protobuf.As_Bytes (Find_Field (Fields, 15)) =
              Character'Val (0) & Character'Val (1) & Character'Val (16#FE#),
              "bytes");

      declare
         Discard_UNIT_BODY143:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,143);Nested_Bytes : constant String := Protobuf.As_Message_Bytes (Find_Field (Fields, 16));
         Discard_UNIT_BODY144:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,144);Nested_Fields : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Nested_Bytes);
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,145);Assert (Protobuf.As_Int32 (Find_Field (Nested_Fields, 1)) = 7, "nested int32");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,146);Assert (Protobuf.As_String (Find_Field (Nested_Fields, 2)) = "nested", "nested string");
      end;

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,147);Assert (Count_Field (Fields, 17) = 3, "repeated int32 count");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,148);Assert (Protobuf.As_Int32 (Find_Field (Fields, 17, 1)) = 1, "repeated #1");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,149);Assert (Protobuf.As_Int32 (Find_Field (Fields, 17, 2)) = -1, "repeated #2");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,150);Assert (Protobuf.As_Int32 (Find_Field (Fields, 17, 3)) = 150, "repeated #3");

      declare
         Discard_UNIT_BODY151:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,151);Packed : constant Protobuf.Int32_Array := Protobuf.Decode_Packed_SInt32 (Protobuf.As_Bytes (Find_Field (Fields, 18)));
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,152);Assert (Packed'Length = 5, "packed length");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,153);Assert (Packed (1) = -1 and Packed (2) = 0 and Packed (3) = 1 and Packed (4) = 150 and Packed (5) = -150,
                 "packed sint32 values");
      end;
   end Assert_All_Types_Fields;

   procedure Assert_Advanced_Types_Fields (Fields : Protobuf.Parsed_Field_Vectors.Vector) is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,154);Assert (Count_Field (Fields, 1) = 0, "oneof int32 branch should not be present");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,155);Assert (Protobuf.As_String (Find_Field (Fields, 2)) = "selected", "oneof text");
      declare
         Discard_UNIT_BODY156:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,156);Packed : constant String := Protobuf.As_Bytes (Find_Field (Fields, 3));
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,157);Assert (Packed'Length = 16, "packed fixed64 payload length");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,158);Assert (Decode_Fixed64_LE (Packed, Packed'First) = 16#1122_3344_5566_7788#, "packed fixed64 #1");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,159);Assert (Decode_Fixed64_LE (Packed, Packed'First + 8) = 16#FFEE_DDCC_BBAA_0099#, "packed fixed64 #2");
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,160);Assert (Count_Field (Fields, 4) = 2, "chunks count");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,161);Assert (Protobuf.As_Bytes (Find_Field (Fields, 4, 1)) = "", "empty chunk");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,162);Assert (Protobuf.As_Bytes (Find_Field (Fields, 4, 2)) =
                Character'Val (0) & Character'Val (16#AB#) & Character'Val (16#CD#),
              "binary chunk");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,163);Assert (Protobuf.As_Bool (Find_Field (Fields, 5)), "flag");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,164);Assert (Protobuf.As_String (Find_Field (Fields, 6)) = "hello-advanced", "utf8/ascii");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,165);Assert (Protobuf.As_Bytes (Find_Field (Fields, 7)) =
                Character'Val (0) & Character'Val (16#7F#) & Character'Val (16#80#) & Character'Val (16#FF#),
              "blob");
      declare
         Discard_UNIT_BODY166:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,166);Nested_Bytes : constant String := Protobuf.As_Message_Bytes (Find_Field (Fields, 8));
         Discard_UNIT_BODY167:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,167);Nested_Fields : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Nested_Bytes);
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,168);Assert (Protobuf.As_Int32 (Find_Field (Nested_Fields, 1)) = -42, "advanced nested int32");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,169);Assert (Protobuf.As_String (Find_Field (Nested_Fields, 2)) = "edge", "advanced nested string");
      end;
   end Assert_Advanced_Types_Fields;

   procedure Test_Empty_Message_Encodes_Empty is
      Discard_UNIT_BODY170:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,170);B : Protobuf.Message_Buffer;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,171);Assert (Protobuf.To_String (B) = "", "empty message must serialize to empty string");
   end Test_Empty_Message_Encodes_Empty;

   procedure Test_All_Scalar_Encodings is
      Discard_UNIT_BODY172:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,172);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY173:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,173);Fields : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,174);Populate_All_Types (B);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,175);Fields := Protobuf.Parse_From_String (Protobuf.To_String (B));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,176);Assert_All_Types_Fields (Fields);
   end Test_All_Scalar_Encodings;

   procedure Test_Serialize_Deserialize_String_Aliases is
      Discard_UNIT_BODY177:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,177);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY178:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,178);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,179);Protobuf.Add_Int32 (B, 1, 12345);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,180);Protobuf.Add_String (B, 2, "alias-check");

      declare
         Discard_UNIT_BODY181:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,181);Encoded_A : constant String := Protobuf.To_String (B);
         Discard_UNIT_BODY182:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,182);Encoded_B : constant String := Protobuf.Serialize_To_String (B);
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,183);Assert (Encoded_A = Encoded_B, "Serialize_To_String must match To_String");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,184);Parsed := Protobuf.Deserialize_From_String (Encoded_B);
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,185);Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1)) = 12345, "Deserialize_From_String int32");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,186);Assert (Protobuf.As_String (Find_Field (Parsed, 2)) = "alias-check", "Deserialize_From_String string");
   end Test_Serialize_Deserialize_String_Aliases;

   procedure Test_Randomized_Roundtrip is
      Discard_UNIT_BODY187:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,187);State : Unsigned_64 := 16#C0DE_CAFE_1234_5678#;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,188);for I in 1 .. 300 loop
         declare
            Discard_UNIT_BODY189:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,189);B : Protobuf.Message_Buffer;
            Discard_UNIT_BODY190:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,190);V_I32 : constant Integer_32 := Rand_I32 (State);
            Discard_UNIT_BODY191:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,191);V_I64 : constant Integer_64 := Rand_I64 (State);
            Discard_UNIT_BODY192:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,192);V_U32 : constant Unsigned_32 := Rand_U32 (State);
            Discard_UNIT_BODY193:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,193);V_U64 : constant Unsigned_64 := Rand_U64 (State);
            Discard_UNIT_BODY194:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,194);V_S32 : constant Integer_32 := Rand_I32 (State);
            Discard_UNIT_BODY195:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,195);V_S64 : constant Integer_64 := Rand_I64 (State);
            Discard_UNIT_BODY196:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,196);V_Bool : constant Boolean := Rand_Bool (State);
            Discard_UNIT_BODY197:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,197);V_Str : constant String := Rand_Ascii (State, 8);
            Discard_UNIT_BODY198:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,198);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,199);Protobuf.Add_Int32 (B, 1, V_I32);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,200);Protobuf.Add_Int64 (B, 2, V_I64);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,201);Protobuf.Add_UInt32 (B, 3, V_U32);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,202);Protobuf.Add_UInt64 (B, 4, V_U64);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,203);Protobuf.Add_SInt32 (B, 5, V_S32);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,204);Protobuf.Add_SInt64 (B, 6, V_S64);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,205);Protobuf.Add_Bool (B, 7, V_Bool);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,206);Protobuf.Add_String (B, 8, V_Str);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,207);Protobuf.Add_Packed_SInt32 (B, 9, (V_S32, -V_S32, Integer_32 (I)));

            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,208);Parsed := Protobuf.Deserialize_From_String (Protobuf.Serialize_To_String (B));
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,209);Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1)) = V_I32, "random int32");
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,210);Assert (Protobuf.As_Int64 (Find_Field (Parsed, 2)) = V_I64, "random int64");
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,211);Assert (Protobuf.As_UInt32 (Find_Field (Parsed, 3)) = V_U32, "random uint32");
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,212);Assert (Protobuf.As_UInt64 (Find_Field (Parsed, 4)) = V_U64, "random uint64");
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,213);Assert (Protobuf.As_SInt32 (Find_Field (Parsed, 5)) = V_S32, "random sint32");
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,214);Assert (Protobuf.As_SInt64 (Find_Field (Parsed, 6)) = V_S64, "random sint64");
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,215);Assert (Protobuf.As_Bool (Find_Field (Parsed, 7)) = V_Bool, "random bool");
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,216);Assert (Protobuf.As_String (Find_Field (Parsed, 8)) = V_Str, "random string");
         end;
      end loop;
   end Test_Randomized_Roundtrip;

   procedure Test_Boundary_Value_Matrix is
      Discard_UNIT_BODY217:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,217);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY218:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,218);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,219);Protobuf.Add_Int32 (B, 1, Integer_32'First);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,220);Protobuf.Add_Int32 (B, 1, Integer_32'Last);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,221);Protobuf.Add_Int64 (B, 2, Integer_64'First);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,222);Protobuf.Add_Int64 (B, 2, Integer_64'Last);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,223);Protobuf.Add_UInt32 (B, 3, Unsigned_32'First);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,224);Protobuf.Add_UInt32 (B, 3, Unsigned_32'Last);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,225);Protobuf.Add_UInt64 (B, 4, Unsigned_64'First);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,226);Protobuf.Add_UInt64 (B, 4, Unsigned_64'Last);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,227);Protobuf.Add_SInt32 (B, 5, Integer_32'First);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,228);Protobuf.Add_SInt32 (B, 5, Integer_32'Last);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,229);Protobuf.Add_SInt64 (B, 6, Integer_64'First);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,230);Protobuf.Add_SInt64 (B, 6, Integer_64'Last);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,231);Protobuf.Add_Float (B, 7, Protobuf.Float32'First);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,232);Protobuf.Add_Float (B, 7, Protobuf.Float32'Last);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,233);Protobuf.Add_Double (B, 8, Protobuf.Float64'First);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,234);Protobuf.Add_Double (B, 8, Protobuf.Float64'Last);

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,235);Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,236);Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1, 1)) = Integer_32'First, "boundary int32 first");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,237);Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1, 2)) = Integer_32'Last, "boundary int32 last");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,238);Assert (Protobuf.As_Int64 (Find_Field (Parsed, 2, 1)) = Integer_64'First, "boundary int64 first");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,239);Assert (Protobuf.As_Int64 (Find_Field (Parsed, 2, 2)) = Integer_64'Last, "boundary int64 last");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,240);Assert (Protobuf.As_UInt32 (Find_Field (Parsed, 3, 1)) = Unsigned_32'First, "boundary uint32 first");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,241);Assert (Protobuf.As_UInt32 (Find_Field (Parsed, 3, 2)) = Unsigned_32'Last, "boundary uint32 last");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,242);Assert (Protobuf.As_UInt64 (Find_Field (Parsed, 4, 1)) = Unsigned_64'First, "boundary uint64 first");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,243);Assert (Protobuf.As_UInt64 (Find_Field (Parsed, 4, 2)) = Unsigned_64'Last, "boundary uint64 last");
   end Test_Boundary_Value_Matrix;

   procedure Test_Large_Payload_Stress is
      Discard_UNIT_BODY244:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,244);Large : String (1 .. 1_000_000);
      Discard_UNIT_BODY245:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,245);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY246:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,246);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,247);for I in Large'Range loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,248);Large (I) := Character'Val (Character'Pos ('a') + (I mod 26));
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,249);Protobuf.Add_String (B, 1, Large);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,250);Protobuf.Add_Packed_UInt32
        (B,
         2,
         (1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,251);Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,252);Assert (Protobuf.As_String (Find_Field (Parsed, 1)) = Large, "large string roundtrip");
   end Test_Large_Payload_Stress;

   procedure Test_Malformed_Fuzz_Corpus is
      Discard_UNIT_BODY253:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,253);State : Unsigned_64 := 16#1234_5678_9ABC_DEF0#;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,254);for I in 1 .. 500 loop
         declare
            Discard_UNIT_BODY255:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,255);Len : constant Natural := Natural (Next_Rand (State) mod 64);
            Discard_UNIT_BODY256:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,256);S : String (1 .. (if Len = 0 then 1 else Len));
            Discard_UNIT_BODY257:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,257);Failed_Ok : Boolean := False;
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,258);if Len = 0 then
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,259);S (1) := Character'Val (0);
            else
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,260);for J in 1 .. Len loop
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,261);S (J) := Character'Val (Integer (Next_Rand (State) and 16#FF#));
               end loop;
            end if;
            begin
               declare
                  Discard_UNIT_BODY262:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,262);Ignore : constant Protobuf.Parsed_Field_Vectors.Vector :=
                    Protobuf.Parse_From_String (if Len = 0 then "" else S (1 .. Len));
               begin
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,263);null;
               end;
            exception
               when Protobuf.Parse_Error =>
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,264);Failed_Ok := True;
               when others =>
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,265);Assert (False, "unexpected exception in fuzz corpus");
            end;
            pragma Unreferenced (Failed_Ok);
         end;
      end loop;
   end Test_Malformed_Fuzz_Corpus;

   procedure Test_Malformed_Corpus_Fixture is
      Discard_UNIT_BODY266:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,266);Corpus : constant String := Fixture_Loader.Read_Fixture ("malformed_corpus.hex");
      Discard_UNIT_BODY267:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,267);Line_Start : Positive := Corpus'First;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,268);for I in Corpus'Range loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,269);if Corpus (I) = ASCII.LF then
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,270);if I > Line_Start then
               declare
                  Discard_UNIT_BODY271:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,271);Line : constant String := Corpus (Line_Start .. I - 1);
                  Discard_UNIT_BODY272:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,272);Data : constant String := Decode_Hex (Line);
               begin
                  begin
                     declare
                        Discard_UNIT_BODY273:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,273);Ignore : constant Protobuf.Parsed_Field_Vectors.Vector :=
                          Protobuf.Parse_From_String (Data);
                     begin
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,274);null;
                     end;
                  exception
                     when Protobuf.Parse_Error =>
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,275);null;
                     when others =>
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,276);Assert (False, "unexpected exception in malformed corpus fixture");
                  end;
               end;
            end if;
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,277);if I < Corpus'Last then
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,278);Line_Start := I + 1;
            end if;
         end if;
      end loop;
   end Test_Malformed_Corpus_Fixture;

   procedure Test_Cpp_Differential_Corpus is
      Discard_UNIT_BODY279:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,279);Corpus : constant String := Fixture_Loader.Read_Fixture ("all_types_corpus.hex");
      Discard_UNIT_BODY280:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,280);Line_Start : Positive := Corpus'First;
      Discard_UNIT_BODY281:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,281);Seed : Unsigned_64 := 1;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,282);for I in Corpus'Range loop
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,283);if Corpus (I) = ASCII.LF then
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,284);if I > Line_Start then
               declare
                  Discard_UNIT_BODY285:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,285);Line : constant String := Corpus (Line_Start .. I - 1);
                  Discard_UNIT_BODY286:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,286);Expected : constant String := Decode_Hex (Line);
                  Discard_UNIT_BODY287:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,287);B : Protobuf.Message_Buffer;
               begin
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,288);Populate_Diff_Case_From_Seed (B, Seed);
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,289);Assert (Protobuf.To_String (B) = Expected, "cpp differential mismatch seed=" & Img_U64 (Seed));
                  GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,290);Seed := Seed + 1;
               end;
            end if;
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,291);if I < Corpus'Last then
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,292);Line_Start := I + 1;
            end if;
         end if;
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,293);Assert (Seed = 129, "corpus should contain 128 lines");
   end Test_Cpp_Differential_Corpus;

   procedure Test_Unknown_Fields_Stability is
      Discard_UNIT_BODY294:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,294);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY295:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,295);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,296);Protobuf.Add_Int32 (B, 1, 10);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,297);Protobuf.Add_Fixed32 (B, 19_000, 16#DEAD_BEEF#);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,298);Protobuf.Add_String (B, 2, "known");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,299);Protobuf.Add_UInt64 (B, 29_000, 123456789);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,300);Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,301);Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1)) = 10, "known field #1");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,302);Assert (Protobuf.As_String (Find_Field (Parsed, 2)) = "known", "known field #2");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,303);Assert (Count_Field (Parsed, 19_000) = 1, "unknown fixed field preserved");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,304);Assert (Count_Field (Parsed, 29_000) = 1, "unknown varint field preserved");
   end Test_Unknown_Fields_Stability;

   procedure Test_Packed_Unpacked_Equivalence is
      Discard_UNIT_BODY305:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,305);Packed_B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY306:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,306);Unpacked_B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY307:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,307);Packed_Parsed : Protobuf.Parsed_Field_Vectors.Vector;
      Discard_UNIT_BODY308:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,308);Unpacked_Parsed : Protobuf.Parsed_Field_Vectors.Vector;
      Discard_UNIT_BODY309:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,309);Packed_Values : Protobuf.Int32_Array (1 .. 3) := (-10, 0, 25);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,310);Protobuf.Add_Packed_Int32 (Packed_B, 1, Packed_Values);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,311);Protobuf.Add_Int32 (Unpacked_B, 1, -10);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,312);Protobuf.Add_Int32 (Unpacked_B, 1, 0);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,313);Protobuf.Add_Int32 (Unpacked_B, 1, 25);

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,314);Packed_Parsed := Protobuf.Parse_From_String (Protobuf.To_String (Packed_B));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,315);Unpacked_Parsed := Protobuf.Parse_From_String (Protobuf.To_String (Unpacked_B));

      declare
         Discard_UNIT_BODY316:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,316);Decoded_Packed : constant Protobuf.Int32_Array :=
           Protobuf.Decode_Packed_Int32 (Protobuf.As_Bytes (Find_Field (Packed_Parsed, 1)));
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,317);Assert (Decoded_Packed'Length = 3, "packed len");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,318);Assert (Decoded_Packed (1) = Protobuf.As_Int32 (Find_Field (Unpacked_Parsed, 1, 1)), "eq #1");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,319);Assert (Decoded_Packed (2) = Protobuf.As_Int32 (Find_Field (Unpacked_Parsed, 1, 2)), "eq #2");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,320);Assert (Decoded_Packed (3) = Protobuf.As_Int32 (Find_Field (Unpacked_Parsed, 1, 3)), "eq #3");
      end;
   end Test_Packed_Unpacked_Equivalence;

   procedure Test_Public_Packed_Decode_Helpers is
      Discard_UNIT_BODY321:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,321);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY322:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,322);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,323);Protobuf.Add_Packed_Bool (B, 1, (True, False, True));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,324);Protobuf.Add_Packed_Fixed64 (B, 2, (16#0102_0304_0506_0708#, 16#F0E0_D0C0_B0A0_9080#));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,325);Protobuf.Add_Packed_SFixed32 (B, 3, (-1, 0, 1));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,326);Protobuf.Add_Packed_Float (B, 4, (1.25, -2.5));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,327);Protobuf.Add_Packed_Double (B, 5, (3.25, -9.5));

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,328);Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));

      declare
         Discard_UNIT_BODY329:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,329);V1 : constant Protobuf.Bool_Array := Protobuf.Decode_Packed_Bool (Protobuf.As_Bytes (Find_Field (Parsed, 1)));
         Discard_UNIT_BODY330:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,330);V2 : constant Protobuf.Fixed64_Array := Protobuf.Decode_Packed_Fixed64 (Protobuf.As_Bytes (Find_Field (Parsed, 2)));
         Discard_UNIT_BODY331:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,331);V3 : constant Protobuf.SFixed32_Array := Protobuf.Decode_Packed_SFixed32 (Protobuf.As_Bytes (Find_Field (Parsed, 3)));
         Discard_UNIT_BODY332:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,332);V4 : constant Protobuf.Float_Array := Protobuf.Decode_Packed_Float (Protobuf.As_Bytes (Find_Field (Parsed, 4)));
         Discard_UNIT_BODY333:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,333);V5 : constant Protobuf.Double_Array := Protobuf.Decode_Packed_Double (Protobuf.As_Bytes (Find_Field (Parsed, 5)));
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,334);Assert (V1'Length = 3 and V1 (1) and (not V1 (2)) and V1 (3), "decode packed bool");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,335);Assert (V2'Length = 2 and V2 (1) = 16#0102_0304_0506_0708# and V2 (2) = 16#F0E0_D0C0_B0A0_9080#, "decode packed fixed64");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,336);Assert (V3'Length = 3 and V3 (1) = -1 and V3 (2) = 0 and V3 (3) = 1, "decode packed sfixed32");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,337);Assert (V4'Length = 2 and abs (V4 (1) - 1.25) < 0.0001 and abs (V4 (2) - (-2.5)) < 0.0001, "decode packed float");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,338);Assert (V5'Length = 2 and abs (V5 (1) - 3.25) < 0.0000001 and abs (V5 (2) - (-9.5)) < 0.0000001, "decode packed double");
      end;
   end Test_Public_Packed_Decode_Helpers;

   procedure Test_Stream_Chunking is
      Discard_UNIT_BODY339:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,339);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY340:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,340);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
      Discard_UNIT_BODY341:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,341);S : aliased Chunked_Input_Stream;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,342);Populate_All_Types (B);
      declare
         Discard_UNIT_BODY343:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,343);Encoded : constant String := Protobuf.To_String (B);
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,344);S.Data := Ada.Strings.Unbounded.To_Unbounded_String (Encoded);
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,345);S.Pos := 1;
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,346);S.Chunk_Size := 3;
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,347);Parsed := Protobuf.Parse_From_Stream (S'Access, Encoded'Length);
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,348);Assert_All_Types_Fields (Parsed);
   end Test_Stream_Chunking;

   procedure Test_Benchmark_Regression_Guard is
      use Ada.Calendar;
      Discard_UNIT_BODY349:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,349);Start_Time : Time;
      Discard_UNIT_BODY350:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,350);End_Time : Time;
      Discard_UNIT_BODY351:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,351);Iterations : constant Positive := 20_000;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,352);Start_Time := Clock;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,353);for I in 1 .. Iterations loop
         declare
            Discard_UNIT_BODY354:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,354);B : Protobuf.Message_Buffer;
            Discard_UNIT_BODY355:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,355);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,356);Protobuf.Add_Int32 (B, 1, Integer_32 (I));
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,357);Protobuf.Add_UInt64 (B, 2, Unsigned_64 (I) * 17);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,358);Protobuf.Add_String (B, 3, "bench");
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,359);Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,360);Assert (Protobuf.As_Int32 (Find_Field (Parsed, 1)) = Integer_32 (I), "bench guard parse");
         end;
      end loop;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,361);End_Time := Clock;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,362);Assert (End_Time - Start_Time < 30.0, "benchmark guard exceeded threshold");
   end Test_Benchmark_Regression_Guard;

   procedure Test_Stream_Serialization is
      Discard_UNIT_BODY363:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,363);package SIO renames Ada.Streams.Stream_IO;
      Discard_UNIT_BODY364:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,364);Tmp : constant String := "tests/.tmp-stream.bin";
      Discard_UNIT_BODY365:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,365);File : SIO.File_Type;
      Discard_UNIT_BODY366:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,366);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY367:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,367);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,368);Protobuf.Add_String (B, 1, "stream");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,369);Protobuf.Add_Int32 (B, 2, 42);

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,370);SIO.Create (File, SIO.Out_File, Tmp);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,371);Protobuf.Write_To_Stream (B, SIO.Stream (File));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,372);SIO.Close (File);

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,373);SIO.Open (File, SIO.In_File, Tmp);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,374);Parsed := Protobuf.Parse_From_Stream (SIO.Stream (File), Natural (SIO.Size (File)));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,375);SIO.Close (File);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,376);Ada.Directories.Delete_File (Tmp);

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,377);Assert (Protobuf.As_String (Find_Field (Parsed, 1)) = "stream", "stream string");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,378);Assert (Protobuf.As_Int32 (Find_Field (Parsed, 2)) = 42, "stream int");
   end Test_Stream_Serialization;

   procedure Test_Fixture_Empty is
      Discard_UNIT_BODY379:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,379);Data : constant String := Fixture_Loader.Read_Fixture ("empty.bin");
      Discard_UNIT_BODY380:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,380);Parsed : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Data);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,381);Assert (Data'Length = 0, "empty fixture should be empty bytes");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,382);Assert (Parsed.Length = 0, "empty fixture should parse as no fields");
   end Test_Fixture_Empty;

   procedure Test_Fixture_All_Types_Compatibility is
      Discard_UNIT_BODY383:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,383);Data : constant String := Fixture_Loader.Read_Fixture ("all_types.bin");
      Discard_UNIT_BODY384:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,384);Parsed : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Data);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,385);Assert_All_Types_Fields (Parsed);
   end Test_Fixture_All_Types_Compatibility;

   procedure Test_Ada_Encoding_Matches_Golden is
      Discard_UNIT_BODY386:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,386);Golden : constant String := Fixture_Loader.Read_Fixture ("all_types.bin");
      Discard_UNIT_BODY387:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,387);B : Protobuf.Message_Buffer;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,388);Populate_All_Types (B);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,389);Assert (Protobuf.To_String (B) = Golden, "encoded bytes must match C++ fixture");
   end Test_Ada_Encoding_Matches_Golden;

   procedure Test_Fixture_Advanced_Types_Compatibility is
      Discard_UNIT_BODY390:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,390);Data : constant String := Fixture_Loader.Read_Fixture ("advanced_types.bin");
      Discard_UNIT_BODY391:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,391);Parsed : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Data);
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,392);Assert_Advanced_Types_Fields (Parsed);
   end Test_Fixture_Advanced_Types_Compatibility;

   procedure Test_Ada_Encoding_Matches_Advanced_Golden is
      Discard_UNIT_BODY393:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,393);Golden : constant String := Fixture_Loader.Read_Fixture ("advanced_types.bin");
      Discard_UNIT_BODY394:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,394);B : Protobuf.Message_Buffer;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,395);Populate_Advanced_Types (B);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,396);Assert (Protobuf.To_String (B) = Golden, "advanced encoded bytes must match C++ fixture");
   end Test_Ada_Encoding_Matches_Advanced_Golden;

   procedure Test_Truncated_Varint_Fails is
      Discard_UNIT_BODY397:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,397);Failed : Boolean := False;
      Discard_UNIT_BODY398:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,398);Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,399);Ignore := Protobuf.Parse_From_String (Character'Val (8) & Character'Val (16#80#));
      exception
         when Protobuf.Parse_Error =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,400);Failed := True;
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,401);Assert (Failed, "truncated varint should fail");
   end Test_Truncated_Varint_Fails;

   procedure Test_Unsupported_Group_Wire_Fails is
      Discard_UNIT_BODY402:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,402);Failed : Boolean := False;
      Discard_UNIT_BODY403:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,403);Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,404);Ignore := Protobuf.Parse_From_String ("" & Character'Val (11));
      exception
         when Protobuf.Parse_Error =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,405);Failed := True;
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,406);Assert (Failed, "group wire should fail");
   end Test_Unsupported_Group_Wire_Fails;

   procedure Test_Wire_Mismatch_Fails is
      Discard_UNIT_BODY407:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,407);Failed : Boolean := False;
      Discard_UNIT_BODY408:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,408);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY409:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,409);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,410);Protobuf.Add_Fixed32 (B, 1, 123);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,411);Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));
      begin
         declare
            Discard_UNIT_BODY412:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,412);Ignore : constant Integer_32 := Protobuf.As_Int32 (Find_Field (Parsed, 1));
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,413);null;
         end;
      exception
         when Protobuf.Parse_Error =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,414);Failed := True;
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,415);Assert (Failed, "wire mismatch should fail");
   end Test_Wire_Mismatch_Fails;

   procedure Test_Clear_Buffer is
      Discard_UNIT_BODY416:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,416);B : Protobuf.Message_Buffer;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,417);Protobuf.Add_Int32 (B, 1, 1);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,418);Assert (Protobuf.To_String (B)'Length > 0, "buffer has content");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,419);Protobuf.Clear (B);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,420);Assert (Protobuf.To_String (B) = "", "buffer cleared");
   end Test_Clear_Buffer;

   procedure Test_Packed_Fixed32 is
      Discard_UNIT_BODY421:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,421);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY422:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,422);Fields : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,423);Protobuf.Add_Packed_Fixed32 (B, 1, (16#0102_0304#, 16#DEAD_BEEF#));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,424);Fields := Protobuf.Parse_From_String (Protobuf.To_String (B));
      declare
         Discard_UNIT_BODY425:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,425);Payload : constant String := Protobuf.As_Bytes (Find_Field (Fields, 1));
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,426);Assert (Payload'Length = 8, "packed fixed32 payload length");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,427);Assert (Character'Pos (Payload (1)) = 16#04# and Character'Pos (Payload (4)) = 16#01#, "little endian #1");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,428);Assert (Character'Pos (Payload (5)) = 16#EF# and Character'Pos (Payload (8)) = 16#DE#, "little endian #2");
      end;
   end Test_Packed_Fixed32;

   procedure Test_Zero_Field_Number_Fails is
      Discard_UNIT_BODY429:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,429);Failed : Boolean := False;
      Discard_UNIT_BODY430:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,430);Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,431);Ignore := Protobuf.Parse_From_String ("" & Character'Val (0));
      exception
         when Protobuf.Parse_Error =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,432);Failed := True;
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,433);Assert (Failed, "field number zero must fail");
   end Test_Zero_Field_Number_Fails;

   procedure Test_Truncated_Length_Field_Fails is
      Discard_UNIT_BODY434:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,434);Failed : Boolean := False;
      Discard_UNIT_BODY435:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,435);Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,436);Ignore := Protobuf.Parse_From_String (Character'Val (10) & Character'Val (3) & "ab");
      exception
         when Protobuf.Parse_Error =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,437);Failed := True;
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,438);Assert (Failed, "truncated length-delimited field must fail");
   end Test_Truncated_Length_Field_Fails;

   procedure Test_Empty_Length_Field is
      Discard_UNIT_BODY439:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,439);Parsed : constant Protobuf.Parsed_Field_Vectors.Vector :=
        Protobuf.Parse_From_String (Character'Val (10) & Character'Val (0));
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,440);Assert (Parsed.Length = 1, "single empty field parsed");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,441);Assert (Protobuf.As_String (Find_Field (Parsed, 1)) = "", "empty bytes/string value");
   end Test_Empty_Length_Field;

   procedure Test_Truncated_Fixed32_Fails is
      Discard_UNIT_BODY442:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,442);Failed : Boolean := False;
      Discard_UNIT_BODY443:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,443);Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,444);Ignore :=
           Protobuf.Parse_From_String
             (Character'Val (16#0D#) &
              Character'Val (16#11#) &
              Character'Val (16#22#) &
              Character'Val (16#33#));
      exception
         when Protobuf.Parse_Error =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,445);Failed := True;
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,446);Assert (Failed, "truncated fixed32 must fail");
   end Test_Truncated_Fixed32_Fails;

   procedure Test_Truncated_Fixed64_Fails is
      Discard_UNIT_BODY447:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,447);Failed : Boolean := False;
      Discard_UNIT_BODY448:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,448);Ignore : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,449);Ignore :=
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
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,450);Failed := True;
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,451);Assert (Failed, "truncated fixed64 must fail");
   end Test_Truncated_Fixed64_Fails;

   procedure Test_Find_Field_Not_Found_Fails is
      Discard_UNIT_BODY452:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,452);Failed : Boolean := False;
      Discard_UNIT_BODY453:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,453);Empty  : Protobuf.Parsed_Field_Vectors.Vector;
      Discard_UNIT_BODY454:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,454);Ignore : Protobuf.Parsed_Field;
   begin
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,455);Ignore := Find_Field (Empty, 1);
      exception
         when Protobuf.Parse_Error =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,456);Failed := True;
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,457);Assert (Failed, "Find_Field should fail when field is absent");
   end Test_Find_Field_Not_Found_Fails;

   procedure Test_Decode_Hex_Invalid_Digit_Fails is
      Discard_UNIT_BODY458:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,458);Failed : Boolean := False;
      Discard_UNIT_BODY459:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,459);Ignore : String := "";
   begin
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,460);Ignore := Decode_Hex ("GG");
      exception
         when Constraint_Error =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,461);Failed := True;
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,462);Assert (Failed, "invalid hex digit should raise Constraint_Error");
   end Test_Decode_Hex_Invalid_Digit_Fails;

   procedure Test_Decode_Hex_Odd_Length_Fails is
      Discard_UNIT_BODY463:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,463);Failed : Boolean := False;
      Discard_UNIT_BODY464:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,464);Ignore : String := "";
   begin
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,465);Ignore := Decode_Hex ("ABC");
      exception
         when Constraint_Error =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,466);Failed := True;
      end;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,467);Assert (Failed, "odd-length hex should raise Constraint_Error");
   end Test_Decode_Hex_Odd_Length_Fails;

   procedure Test_Chunked_Read_EOF is
      Discard_UNIT_BODY468:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,468);S : Chunked_Input_Stream;
      Discard_UNIT_BODY469:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,469);Item : Ada.Streams.Stream_Element_Array (1 .. 4);
      Discard_UNIT_BODY470:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,470);Last : Ada.Streams.Stream_Element_Offset;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,471);S.Data := Ada.Strings.Unbounded.To_Unbounded_String ("");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,472);S.Pos := 1;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,473);S.Chunk_Size := 1;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,474);Read (S, Item, Last);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,475);Assert (Last = Item'First - 1, "empty stream read should report EOF");
   end Test_Chunked_Read_EOF;

   procedure Test_Enum_And_Packed_Int64 is
      Discard_UNIT_BODY476:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,476);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY477:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,477);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,478);Protobuf.Add_Enum (B, 1, -42);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,479);Protobuf.Add_Packed_Int64 (B, 2, (-9_223_372_036_854_775_808, -1, 0, 1, 9_223_372_036_854_775_807));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,480);Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,481);Assert (Protobuf.As_Enum (Find_Field (Parsed, 1)) = -42, "enum value");
      declare
         Discard_UNIT_BODY482:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,482);Decoded : constant Protobuf.Int64_Array :=
           Protobuf.Decode_Packed_Int64 (Protobuf.As_Bytes (Find_Field (Parsed, 2)));
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,483);Assert (Decoded'Length = 5, "packed int64 size");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,484);Assert (Decoded (1) = -9_223_372_036_854_775_808, "packed int64 #1");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,485);Assert (Decoded (2) = -1, "packed int64 #2");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,486);Assert (Decoded (3) = 0, "packed int64 #3");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,487);Assert (Decoded (4) = 1, "packed int64 #4");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,488);Assert (Decoded (5) = 9_223_372_036_854_775_807, "packed int64 #5");
      end;
   end Test_Enum_And_Packed_Int64;

   procedure Test_Stream_Serialization_Empty_Buffer is
      Discard_UNIT_BODY489:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,489);package SIO renames Ada.Streams.Stream_IO;
      Discard_UNIT_BODY490:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,490);Tmp : constant String := "tests/.tmp-stream-empty.bin";
      Discard_UNIT_BODY491:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,491);File : SIO.File_Type;
      Discard_UNIT_BODY492:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,492);B : Protobuf.Message_Buffer;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,493);SIO.Create (File, SIO.Out_File, Tmp);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,494);Protobuf.Write_To_Stream (B, SIO.Stream (File));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,495);SIO.Close (File);

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,496);SIO.Open (File, SIO.In_File, Tmp);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,497);Assert (Natural (SIO.Size (File)) = 0, "empty buffer should write zero bytes");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,498);SIO.Close (File);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,499);Ada.Directories.Delete_File (Tmp);
   end Test_Stream_Serialization_Empty_Buffer;

   procedure Test_Packed_UInt64_And_SInt64 is
      Discard_UNIT_BODY500:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,500);B : Protobuf.Message_Buffer;
      Discard_UNIT_BODY501:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,501);Parsed : Protobuf.Parsed_Field_Vectors.Vector;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,502);Protobuf.Add_Packed_UInt64
        (B,
         1,
         (0,
          1,
          127,
          128,
          16#FFFF_FFFF_FFFF_FFFF#));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,503);Protobuf.Add_Packed_SInt64
        (B,
         2,
         (-9_223_372_036_854_775_808,
          -1,
          0,
          1,
          9_223_372_036_854_775_807));

      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,504);Parsed := Protobuf.Parse_From_String (Protobuf.To_String (B));

      declare
         Discard_UNIT_BODY505:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,505);U : constant Protobuf.UInt64_Array :=
           Protobuf.Decode_Packed_UInt64 (Protobuf.As_Bytes (Find_Field (Parsed, 1)));
         Discard_UNIT_BODY506:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,506);S : constant Protobuf.Int64_Array :=
           Protobuf.Decode_Packed_SInt64 (Protobuf.As_Bytes (Find_Field (Parsed, 2)));
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,507);Assert (U'Length = 5, "packed uint64 size");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,508);Assert (U (1) = 0, "packed uint64 #1");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,509);Assert (U (2) = 1, "packed uint64 #2");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,510);Assert (U (3) = 127, "packed uint64 #3");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,511);Assert (U (4) = 128, "packed uint64 #4");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,512);Assert (U (5) = 16#FFFF_FFFF_FFFF_FFFF#, "packed uint64 #5");

         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,513);Assert (S'Length = 5, "packed sint64 size");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,514);Assert (S (1) = -9_223_372_036_854_775_808, "packed sint64 #1");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,515);Assert (S (2) = -1, "packed sint64 #2");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,516);Assert (S (3) = 0, "packed sint64 #3");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,517);Assert (S (4) = 1, "packed sint64 #4");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,518);Assert (S (5) = 9_223_372_036_854_775_807, "packed sint64 #5");
      end;
   end Test_Packed_UInt64_And_SInt64;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,519);if Registered_Suite = null then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,520);Registered_Suite := AUnit.Test_Suites.New_Suite;
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,521);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("empty message", Test_Empty_Message_Encodes_Empty'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,522);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("all scalar encodings", Test_All_Scalar_Encodings'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,523);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("string alias api", Test_Serialize_Deserialize_String_Aliases'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,524);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("randomized roundtrip", Test_Randomized_Roundtrip'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,525);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("boundary matrix", Test_Boundary_Value_Matrix'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,526);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("large payload stress", Test_Large_Payload_Stress'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,527);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("malformed fuzz", Test_Malformed_Fuzz_Corpus'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,528);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("malformed corpus fixture", Test_Malformed_Corpus_Fixture'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,529);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("cpp differential corpus", Test_Cpp_Differential_Corpus'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,530);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("stream serialization", Test_Stream_Serialization'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,531);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("stream chunking", Test_Stream_Chunking'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,532);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("fixture empty", Test_Fixture_Empty'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,533);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("fixture all types", Test_Fixture_All_Types_Compatibility'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,534);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("golden match", Test_Ada_Encoding_Matches_Golden'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,535);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("fixture advanced types", Test_Fixture_Advanced_Types_Compatibility'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,536);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("advanced golden match", Test_Ada_Encoding_Matches_Advanced_Golden'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,537);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("unknown fields stability", Test_Unknown_Fields_Stability'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,538);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("packed unpacked equivalence", Test_Packed_Unpacked_Equivalence'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,539);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("public packed decode helpers", Test_Public_Packed_Decode_Helpers'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,540);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("benchmark regression guard", Test_Benchmark_Regression_Guard'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,541);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("truncated varint", Test_Truncated_Varint_Fails'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,542);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("unsupported group", Test_Unsupported_Group_Wire_Fails'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,543);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("wire mismatch", Test_Wire_Mismatch_Fails'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,544);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("clear buffer", Test_Clear_Buffer'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,545);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("packed fixed32", Test_Packed_Fixed32'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,546);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("zero field number", Test_Zero_Field_Number_Fails'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,547);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("truncated length", Test_Truncated_Length_Field_Fails'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,548);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("empty length", Test_Empty_Length_Field'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,549);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("truncated fixed32", Test_Truncated_Fixed32_Fails'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,550);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("truncated fixed64", Test_Truncated_Fixed64_Fails'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,551);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("find field missing", Test_Find_Field_Not_Found_Fails'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,552);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("decode hex invalid digit", Test_Decode_Hex_Invalid_Digit_Fails'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,553);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("decode hex odd length", Test_Decode_Hex_Odd_Length_Fails'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,554);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("chunked read eof", Test_Chunked_Read_EOF'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,555);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("enum and packed int64", Test_Enum_And_Packed_Int64'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,556);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("stream serialization empty", Test_Stream_Serialization_Empty_Buffer'Access));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,557);AUnit.Test_Suites.Add_Test (Registered_Suite, New_Case ("packed uint64 and sint64", Test_Packed_UInt64_And_SInt64'Access));
      end if;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,558);return Registered_Suite;
   end Suite;

   procedure Cleanup is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_tests.Statement_Buffer,559);null;
   end Cleanup;

end Protobuf_Tests;

