pragma Style_Checks (Off); pragma Warnings (Off);
with Ada.Calendar;
with Ada.Text_IO;
with Interfaces;
with Protobuf;

with GNATcov_RTS.Buffers.PB_protobuf_ada_bench;with GNATcov_RTS.Buffers.DB_protobuf_ada_bench;with GNATcov_RTS;pragma Compile_Time_Error(GNATcov_RTS.Version/=4,"Incompatible GNATcov_RTS version, please use the GNATcov_RTS project provided with your GNATcoverage distribution.");procedure Protobuf_Ada_Bench is
   begin
   GNATcov_Original_Main:declare use Ada.Calendar;
   use Interfaces;

   Discard_UNIT_BODY0:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,0);Iterations : constant Positive := 100_000;

   function Sample_Message return String is
      Discard_UNIT_BODY1:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,1);B : Protobuf.Message_Buffer;
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,2);Protobuf.Add_Int32 (B, 1, -123);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,3);Protobuf.Add_UInt64 (B, 2, 987_654_321_123);
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,4);Protobuf.Add_String (B, 3, "protobuf-ada-benchmark");
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,5);Protobuf.Add_Packed_SInt32 (B, 4, (-1, 0, 1, 2, 3, -4, 5));
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,6);return Protobuf.To_String (B);
   end Sample_Message;

   Discard_UNIT_BODY7:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,7);Data : constant String := Sample_Message;

   function Elapsed_Seconds (Start_Time, End_Time : Time) return Duration is
   begin
      GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,8);return End_Time - Start_Time;
   end Elapsed_Seconds;

   Discard_UNIT_BODY9:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,9);Encode_Start : Time;
   Discard_UNIT_BODY10:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,10);Encode_End : Time;
   Discard_UNIT_BODY11:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,11);Decode_Start : Time;
   Discard_UNIT_BODY12:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,12);Decode_End : Time;
begin GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,13);Encode_Start := Clock;
   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,14);for I in 1 .. Iterations loop
      declare
         Discard_UNIT_BODY15:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,15);B : Protobuf.Message_Buffer;
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,16);Protobuf.Add_Int32 (B, 1, Integer_32 (I));
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,17);Protobuf.Add_UInt64 (B, 2, Unsigned_64 (I) * 17);
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,18);Protobuf.Add_String (B, 3, "bench");
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,19);Protobuf.Add_Packed_SInt32 (B, 4, (-3, -2, -1, 0, 1, 2, 3));
         declare
            Discard_UNIT_BODY20:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,20);Ignore : constant String := Protobuf.To_String (B);
         begin
            GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,21);null;
         end;
      end;
   end loop;
   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,22);Encode_End := Clock;

   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,23);Decode_Start := Clock;
   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,24);for I in 1 .. Iterations loop
      declare
         Discard_UNIT_BODY25:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,25);Parsed : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Data);
         Discard_UNIT_BODY26:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,26);Ignore : constant Integer_32 := Protobuf.As_Int32 (Parsed (0));
      begin
         GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,27);null;
      end;
   end loop;
   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,28);Decode_End := Clock;

   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,29);Ada.Text_IO.Put_Line ("iterations=" & Iterations'Image);
   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,30);Ada.Text_IO.Put_Line ("sample_size=" & Data'Length'Image & " bytes");
   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,31);Ada.Text_IO.Put_Line ("encode_seconds=" & Duration'Image (Elapsed_Seconds (Encode_Start, Encode_End)));
   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_bench.Statement_Buffer,32);Ada.Text_IO.Put_Line ("decode_seconds=" & Duration'Image (Elapsed_Seconds (Decode_Start, Decode_End)));
end GNATcov_Original_Main;GNATcov_RTS.Buffers.DB_protobuf_ada_bench.Dump_Buffers;end Protobuf_Ada_Bench;

