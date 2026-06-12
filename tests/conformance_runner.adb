with Ada.Streams;
with Ada.Text_IO;
with Ada.Text_IO.Text_Streams;
with Conformance;
with Conformance_Harness;

--  Speaks the protobuf conformance-test-runner protocol over stdin/stdout:
--  read a 4-byte little-endian length, then that many bytes of a
--  ConformanceRequest; write a ConformanceResponse the same way; loop until
--  stdin closes. The actual work is in Conformance_Harness.Handle.
procedure Conformance_Runner is

   use Ada.Streams;

   In_Stream  : constant Ada.Text_IO.Text_Streams.Stream_Access :=
     Ada.Text_IO.Text_Streams.Stream (Ada.Text_IO.Standard_Input);
   Out_Stream : constant Ada.Text_IO.Text_Streams.Stream_Access :=
     Ada.Text_IO.Text_Streams.Stream (Ada.Text_IO.Standard_Output);

   End_Of_Input : exception;

   function Read_Bytes (N : Natural) return String is
      Buf  : Stream_Element_Array (1 .. Stream_Element_Offset (Integer'Max (1, N)));
      Last : Stream_Element_Offset := 0;
      Pos  : Stream_Element_Offset := 1;
   begin
      if N = 0 then
         return "";
      end if;
      while Pos <= Stream_Element_Offset (N) loop
         Ada.Streams.Read (In_Stream.all, Buf (Pos .. Stream_Element_Offset (N)), Last);
         if Last < Pos then
            raise End_Of_Input;
         end if;
         Pos := Last + 1;
      end loop;
      return R : String (1 .. N) do
         for I in R'Range loop
            R (I) := Character'Val (Buf (Stream_Element_Offset (I)));
         end loop;
      end return;
   end Read_Bytes;

   function Read_Length return Natural is
      B : constant String := Read_Bytes (4);
   begin
      return Character'Pos (B (1))
           + Character'Pos (B (2)) * 256
           + Character'Pos (B (3)) * 65536
           + Character'Pos (B (4)) * 16777216;
   end Read_Length;

   procedure Write_Message (Data : String) is
      Len : constant Natural := Data'Length;
      Hdr : Stream_Element_Array (1 .. 4);
      Buf : Stream_Element_Array (1 .. Stream_Element_Offset (Integer'Max (1, Len)));
   begin
      Hdr (1) := Stream_Element (Len mod 256);
      Hdr (2) := Stream_Element ((Len / 256) mod 256);
      Hdr (3) := Stream_Element ((Len / 65536) mod 256);
      Hdr (4) := Stream_Element ((Len / 16777216) mod 256);
      Ada.Streams.Write (Out_Stream.all, Hdr);
      if Len > 0 then
         for I in Data'Range loop
            Buf (Stream_Element_Offset (I - Data'First + 1)) :=
              Stream_Element (Character'Pos (Data (I)));
         end loop;
         Ada.Streams.Write (Out_Stream.all, Buf (1 .. Stream_Element_Offset (Len)));
      end if;
   end Write_Message;

begin
   loop
      declare
         Len : constant Natural := Read_Length;
         Req : constant Conformance.ConformanceRequest :=
           Conformance.Parse_ConformanceRequest (Read_Bytes (Len));
      begin
         Write_Message
           (Conformance.Serialize (Conformance_Harness.Handle (Req)));
      end;
   end loop;
exception
   when End_Of_Input =>
      null;
end Conformance_Runner;
