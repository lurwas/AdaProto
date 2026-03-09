with Ada.Calendar;
with Ada.Text_IO;
with Interfaces;
with Protobuf;

procedure Protobuf_Ada_Bench is
   use Ada.Calendar;
   use Interfaces;

   Iterations : constant Positive := 100_000;

   function Sample_Message return String is
      B : Protobuf.Message_Buffer;
   begin
      Protobuf.Add_Int32 (B, 1, -123);
      Protobuf.Add_UInt64 (B, 2, 987_654_321_123);
      Protobuf.Add_String (B, 3, "protobuf-ada-benchmark");
      Protobuf.Add_Packed_SInt32 (B, 4, (-1, 0, 1, 2, 3, -4, 5));
      return Protobuf.To_String (B);
   end Sample_Message;

   Data : constant String := Sample_Message;

   function Elapsed_Seconds (Start_Time, End_Time : Time) return Duration is
   begin
      return End_Time - Start_Time;
   end Elapsed_Seconds;

   Encode_Start : Time;
   Encode_End : Time;
   Decode_Start : Time;
   Decode_End : Time;
begin
   Encode_Start := Clock;
   for I in 1 .. Iterations loop
      declare
         B : Protobuf.Message_Buffer;
      begin
         Protobuf.Add_Int32 (B, 1, Integer_32 (I));
         Protobuf.Add_UInt64 (B, 2, Unsigned_64 (I) * 17);
         Protobuf.Add_String (B, 3, "bench");
         Protobuf.Add_Packed_SInt32 (B, 4, (-3, -2, -1, 0, 1, 2, 3));
         declare
            Ignore : constant String := Protobuf.To_String (B);
         begin
            null;
         end;
      end;
   end loop;
   Encode_End := Clock;

   Decode_Start := Clock;
   for I in 1 .. Iterations loop
      declare
         Parsed : constant Protobuf.Parsed_Field_Vectors.Vector := Protobuf.Parse_From_String (Data);
         Ignore : constant Integer_32 := Protobuf.As_Int32 (Parsed (0));
      begin
         null;
      end;
   end loop;
   Decode_End := Clock;

   Ada.Text_IO.Put_Line ("iterations=" & Iterations'Image);
   Ada.Text_IO.Put_Line ("sample_size=" & Data'Length'Image & " bytes");
   Ada.Text_IO.Put_Line ("encode_seconds=" & Duration'Image (Elapsed_Seconds (Encode_Start, Encode_End)));
   Ada.Text_IO.Put_Line ("decode_seconds=" & Duration'Image (Elapsed_Seconds (Decode_Start, Decode_End)));
end Protobuf_Ada_Bench;
