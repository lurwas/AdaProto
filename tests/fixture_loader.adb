with Ada.Directories;
with Ada.Streams.Stream_IO;

package body Fixture_Loader is

   function Try_Path (Path : String) return String is
      use Ada.Streams;
      use Ada.Streams.Stream_IO;
      File : File_Type;
   begin
      Open (File, In_File, Path);
      declare
         File_Size : constant Count := Size (File);
         Data : Stream_Element_Array (1 .. Stream_Element_Offset'Max (1, Stream_Element_Offset (File_Size)));
         Last : Stream_Element_Offset := 0;
      begin
         if File_Size = 0 then
            Close (File);
            return "";
         end if;
         Read (File, Data, Last);
         Close (File);
         if Last /= Data'Last then
            return "";
         end if;
         declare
            Result : String (1 .. Integer (Last));
         begin
            for I in Data'Range loop
               Result (Integer (I)) := Character'Val (Data (I));
            end loop;
            return Result;
         end;
      end;
   exception
      when others =>
         if Is_Open (File) then
            Close (File);
         end if;
         raise;
   end Try_Path;

   function Read_Fixture (Name : String) return String is
      Path_1 : constant String := "fixtures/" & Name;
      Path_2 : constant String := "../fixtures/" & Name;
      Path_3 : constant String := "../../fixtures/" & Name;
   begin
      if Ada.Directories.Exists (Path_1) then
         return Try_Path (Path_1);
      elsif Ada.Directories.Exists (Path_2) then
         return Try_Path (Path_2);
      elsif Ada.Directories.Exists (Path_3) then
         return Try_Path (Path_3);
      end if;
      raise Ada.Directories.Name_Error with "fixture not found: " & Name;
   end Read_Fixture;

end Fixture_Loader;
