with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;
with Interfaces;
with Protobuf;

procedure Protobuf_Ada_Fuzz is
   package SIO renames Ada.Streams.Stream_IO;
   use type SIO.Count;
   use type Ada.Streams.Stream_Element_Offset;

   function Load_File (Path : String) return String is
      File : SIO.File_Type;
   begin
      SIO.Open (File, SIO.In_File, Path);
      declare
         Size : constant SIO.Count := SIO.Size (File);
         Data : Ada.Streams.Stream_Element_Array
           (1 .. Ada.Streams.Stream_Element_Offset'Max (1, Ada.Streams.Stream_Element_Offset (Size)));
         Last : Ada.Streams.Stream_Element_Offset := 0;
      begin
         if Size = 0 then
            SIO.Close (File);
            return "";
         end if;

         SIO.Read (File, Data, Last);
         SIO.Close (File);

         if Last /= Ada.Streams.Stream_Element_Offset (Size) then
            raise Constraint_Error with "short read";
         end if;

         return Result : String (1 .. Integer (Last)) do
            for I in Result'Range loop
               Result (I) := Character'Val (Data (Ada.Streams.Stream_Element_Offset (I)));
            end loop;
         end return;
      end;
   end Load_File;

begin
   if Ada.Command_Line.Argument_Count = 0 then
      Ada.Text_IO.Put_Line ("usage: protobuf-ada-fuzz <input-file>");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      return;
   end if;

   declare
      Data : constant String := Load_File (Ada.Command_Line.Argument (1));
   begin
      begin
         declare
            Parsed : constant Protobuf.Parsed_Field_Vectors.Vector :=
              Protobuf.Parse_From_String (Data);
         begin
            for F of Parsed loop
               case F.Kind is
                  when Protobuf.Varint_Wire =>
                     declare
                        Ignore_1 : constant Interfaces.Integer_64 := Protobuf.As_Int64 (F);
                        Ignore_2 : constant Interfaces.Integer_64 := Protobuf.As_SInt64 (F);
                        Ignore_3 : constant Interfaces.Unsigned_64 := Protobuf.As_UInt64 (F);
                        Ignore_4 : constant Boolean := Protobuf.As_Bool (F);
                     begin
                        null;
                     end;
                  when Protobuf.Fixed64_Wire =>
                     declare
                        Ignore_1 : constant Interfaces.Unsigned_64 := Protobuf.As_Fixed64 (F);
                        Ignore_2 : constant Interfaces.Integer_64 := Protobuf.As_SFixed64 (F);
                        Ignore_3 : constant Protobuf.Float64 := Protobuf.As_Double (F);
                     begin
                        null;
                     end;
                  when Protobuf.Length_Delimited_Wire =>
                     declare
                        Payload : constant String := Protobuf.As_Bytes (F);
                     begin
                        begin
                           declare
                              Nested : constant Protobuf.Parsed_Field_Vectors.Vector :=
                                Protobuf.Parse_From_String (Payload);
                           begin
                              null;
                           end;
                        exception
                           when Protobuf.Parse_Error =>
                              null;
                        end;
                     end;
                  when Protobuf.Fixed32_Wire =>
                     declare
                        Ignore_1 : constant Interfaces.Unsigned_32 := Protobuf.As_Fixed32 (F);
                        Ignore_2 : constant Interfaces.Integer_32 := Protobuf.As_SFixed32 (F);
                        Ignore_3 : constant Protobuf.Float32 := Protobuf.As_Float (F);
                     begin
                        null;
                     end;
               end case;
            end loop;
         end;
      exception
         when Protobuf.Parse_Error =>
            null;
         when E : others =>
            Ada.Text_IO.Put_Line ("unexpected exception: " & Ada.Exceptions.Exception_Information (E));
            Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      end;
   end;
end Protobuf_Ada_Fuzz;
