pragma Style_Checks (Off); pragma Warnings (Off);
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;
with Interfaces;
with Protobuf;

with GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz;with GNATcov_RTS.Buffers.DB_protobuf_ada_fuzzzz;with GNATcov_RTS;pragma Compile_Time_Error(GNATcov_RTS.Version/=4,"Incompatible GNATcov_RTS version, please use the GNATcov_RTS project provided with your GNATcoverage distribution.");procedure Protobuf_Ada_Fuzz is
   begin
   GNATcov_Original_Main:declare Discard_UNIT_BODY0:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,0);package SIO renames Ada.Streams.Stream_IO;
   use type SIO.Count;
   use type Ada.Streams.Stream_Element_Offset;

   function Load_File (Path : String) return String is
      Discard_UNIT_BODY1:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,1);File : SIO.File_Type;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,2);SIO.Open (File, SIO.In_File, Path);
      declare
         Discard_UNIT_BODY3:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,3);Size : constant SIO.Count := SIO.Size (File);
         Discard_UNIT_BODY4:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,4);Data : Ada.Streams.Stream_Element_Array
           (1 .. Ada.Streams.Stream_Element_Offset'Max (1, Ada.Streams.Stream_Element_Offset (Size)));
         Discard_UNIT_BODY5:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,5);Last : Ada.Streams.Stream_Element_Offset := 0;
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,6);if Size = 0 then
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,7);SIO.Close (File);
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,8);return "";
         end if;

         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,9);SIO.Read (File, Data, Last);
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,10);SIO.Close (File);

         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,11);if Last /= Ada.Streams.Stream_Element_Offset (Size) then
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,12);raise Constraint_Error with "short read";
         end if;

         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,13);return Result : String (1 .. Integer (Last)) do
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,14);for I in Result'Range loop
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,15);Result (I) := Character'Val (Data (Ada.Streams.Stream_Element_Offset (I)));
            end loop;
         end return;
      end;
   end Load_File;

begin GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,16);if Ada.Command_Line.Argument_Count = 0 then
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,17);Ada.Text_IO.Put_Line ("usage: protobuf-ada-fuzz <input-file>");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,18);Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,19);return;
   end if;

   declare
      Discard_UNIT_BODY20:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,20);Data : constant String := Load_File (Ada.Command_Line.Argument (1));
   begin
      begin
         declare
            Discard_UNIT_BODY21:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,21);Parsed : constant Protobuf.Parsed_Field_Vectors.Vector :=
              Protobuf.Parse_From_String (Data);
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,22);for F of Parsed loop
               GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,23);case F.Kind is
                  when Protobuf.Varint_Wire =>
                     declare
                        Discard_UNIT_BODY24:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,24);Ignore_1 : constant Interfaces.Integer_64 := Protobuf.As_Int64 (F);
                        Discard_UNIT_BODY25:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,25);Ignore_2 : constant Interfaces.Integer_64 := Protobuf.As_SInt64 (F);
                        Discard_UNIT_BODY26:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,26);Ignore_3 : constant Interfaces.Unsigned_64 := Protobuf.As_UInt64 (F);
                        Discard_UNIT_BODY27:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,27);Ignore_4 : constant Boolean := Protobuf.As_Bool (F);
                     begin
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,28);null;
                     end;
                  when Protobuf.Fixed64_Wire =>
                     declare
                        Discard_UNIT_BODY29:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,29);Ignore_1 : constant Interfaces.Unsigned_64 := Protobuf.As_Fixed64 (F);
                        Discard_UNIT_BODY30:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,30);Ignore_2 : constant Interfaces.Integer_64 := Protobuf.As_SFixed64 (F);
                        Discard_UNIT_BODY31:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,31);Ignore_3 : constant Protobuf.Float64 := Protobuf.As_Double (F);
                     begin
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,32);null;
                     end;
                  when Protobuf.Length_Delimited_Wire =>
                     declare
                        Discard_UNIT_BODY33:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,33);Payload : constant String := Protobuf.As_Bytes (F);
                     begin
                        begin
                           declare
                              Discard_UNIT_BODY34:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,34);Nested : constant Protobuf.Parsed_Field_Vectors.Vector :=
                                Protobuf.Parse_From_String (Payload);
                           begin
                              GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,35);null;
                           end;
                        exception
                           when Protobuf.Parse_Error =>
                              GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,36);null;
                        end;
                     end;
                  when Protobuf.Fixed32_Wire =>
                     declare
                        Discard_UNIT_BODY37:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,37);Ignore_1 : constant Interfaces.Unsigned_32 := Protobuf.As_Fixed32 (F);
                        Discard_UNIT_BODY38:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,38);Ignore_2 : constant Interfaces.Integer_32 := Protobuf.As_SFixed32 (F);
                        Discard_UNIT_BODY39:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,39);Ignore_3 : constant Protobuf.Float32 := Protobuf.As_Float (F);
                     begin
                        GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,40);null;
                     end;
               end case;
            end loop;
         end;
      exception
         when Protobuf.Parse_Error =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,41);null;
         when E : others =>
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,42);Ada.Text_IO.Put_Line ("unexpected exception: " & Ada.Exceptions.Exception_Information (E));
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_fuzzzz.Statement_Buffer,43);Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
      end;
   end;
end GNATcov_Original_Main;GNATcov_RTS.Buffers.DB_protobuf_ada_fuzzzz.Dump_Buffers;end Protobuf_Ada_Fuzz;

