with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with Protobuf_test_messages_Proto3;
with JSON;
with Protobuf;
with Proto_JSON;

package body Conformance_Harness is

   use Conformance;
   use type WireFormat;

   package TM renames Protobuf_test_messages_Proto3;

   --  The message type this testee understands: Google's canonical proto3
   --  conformance message. Other types (proto2, editions) are skipped.
   Known_Type : constant String :=
     "protobuf_test_messages.proto3.TestAllTypesProto3";

   function Handle (Req : Conformance.ConformanceRequest)
                    return Conformance.ConformanceResponse
   is
      Resp : ConformanceResponse;

      procedure Skip (Why : String) is
      begin
         Resp.Result := (Which   => ConformanceResponse_Result_Skipped,
                         Skipped => To_Unbounded_String (Why));
      end Skip;
   begin
      if To_String (Req.Message_type) /= Known_Type then
         Skip ("unsupported message type");
         return Resp;
      end if;

      declare
         Msg : TM.TestAllTypesProto3;
      begin
         --  Parse the input payload into the test message.
         case Req.Payload.Which is
            when ConformanceRequest_Payload_Protobuf_payload =>
               Msg := TM.Parse_TestAllTypesProto3
                        (To_String (Req.Payload.Protobuf_payload));
            when ConformanceRequest_Payload_Json_payload =>
               Msg := TM.From_JSON
                        (JSON.Parse (To_String (Req.Payload.Json_payload)));
            when others =>
               Skip ("unsupported input payload");
               return Resp;
         end case;

         --  Re-serialize in the requested output format.
         if Req.Requested_output_format = WireFormat_PROTOBUF then
            Resp.Result :=
              (Which            => ConformanceResponse_Result_Protobuf_payload,
               Protobuf_payload =>
                 To_Unbounded_String (TM.Serialize (Msg)));
         elsif Req.Requested_output_format = WireFormat_JSON then
            Resp.Result :=
              (Which        => ConformanceResponse_Result_Json_payload,
               Json_payload => To_Unbounded_String
                 (JSON.Serialize (TM.To_JSON (Msg))));
         else
            Skip ("unsupported output format");
         end if;
      exception
         when JSON.Parse_Error | Protobuf.Parse_Error | Proto_JSON.Decode_Error =>
            Resp.Result := (Which       => ConformanceResponse_Result_Parse_error,
                           Parse_error => To_Unbounded_String ("parse error"));
         when others =>
            Resp.Result :=
              (Which         => ConformanceResponse_Result_Runtime_error,
               Runtime_error => To_Unbounded_String ("runtime error"));
      end;
      return Resp;
   end Handle;

end Conformance_Harness;
