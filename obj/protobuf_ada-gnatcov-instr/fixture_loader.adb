pragma Style_Checks (Off); pragma Warnings (Off);
with Ada.Directories;
with Ada.Streams.Stream_IO;

with GNATcov_RTS.Buffers.PB_fixture_loader;package body Fixture_Loader is

   function Try_Path (Path : String) return String is
      use Ada.Streams;
      use Ada.Streams.Stream_IO;
      Discard_UNIT_BODY0:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,0);File : File_Type;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,1);Open (File, In_File, Path);
      declare
         Discard_UNIT_BODY2:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,2);File_Size : constant Count := Size (File);
         Discard_UNIT_BODY3:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,3);Data : Stream_Element_Array (1 .. Stream_Element_Offset'Max (1, Stream_Element_Offset (File_Size)));
         Discard_UNIT_BODY4:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,4);Last : Stream_Element_Offset := 0;
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,5);if File_Size = 0 then
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,6);Close (File);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,7);return "";
         end if;
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,8);Read (File, Data, Last);
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,9);Close (File);
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,10);if Last /= Data'Last then
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,11);return "";
         end if;
         declare
            Discard_UNIT_BODY12:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,12);Result : String (1 .. Integer (Last));
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,13);for I in Data'Range loop
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,14);Result (Integer (I)) := Character'Val (Data (I));
            end loop;
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,15);return Result;
         end;
      end;
   exception
      when others =>
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,16);if Is_Open (File) then
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,17);Close (File);
         end if;
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,18);raise;
   end Try_Path;

   function Read_Fixture (Name : String) return String is
      Discard_UNIT_BODY19:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,19);Path_1 : constant String := "fixtures/" & Name;
      Discard_UNIT_BODY20:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,20);Path_2 : constant String := "../fixtures/" & Name;
      Discard_UNIT_BODY21:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,21);Path_3 : constant String := "../../fixtures/" & Name;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,22);if Ada.Directories.Exists (Path_1) then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,23);return Try_Path (Path_1);
      elsif GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,24)or else(Ada.Directories.Exists (Path_2) )then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,25);return Try_Path (Path_2);
      elsif GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,26)or else(Ada.Directories.Exists (Path_3) )then
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,27);return Try_Path (Path_3);
      end if;
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_fixture_loader.Statement_Buffer,28);raise Ada.Directories.Name_Error with "fixture not found: " & Name;
   end Read_Fixture;

end Fixture_Loader;

