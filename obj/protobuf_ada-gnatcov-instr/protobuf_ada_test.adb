pragma Style_Checks (Off); pragma Warnings (Off);
with AUnit.Options;
with AUnit.Reporter.Text;
with AUnit.Run;
with AUnit.Test_Results;
with Protobuf_Tests;

with GNATcov_RTS.Buffers.PB_protobuf_ada_test;with GNATcov_RTS.Buffers.DB_protobuf_ada_test;with GNATcov_RTS;pragma Compile_Time_Error(GNATcov_RTS.Version/=4,"Incompatible GNATcov_RTS version, please use the GNATcov_RTS project provided with your GNATcoverage distribution.");procedure Protobuf_Ada_Test is
   begin
   GNATcov_Original_Main:declare Discard_UNIT_BODY0:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_test.Statement_Buffer,0);procedure Runner is new AUnit.Run.Test_Runner_With_Results (Protobuf_Tests.Suite);
   Discard_UNIT_BODY1:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_test.Statement_Buffer,1);Reporter : AUnit.Reporter.Text.Text_Reporter;
   Discard_UNIT_BODY2:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_test.Statement_Buffer,2);Results : AUnit.Test_Results.Result;
   Discard_UNIT_BODY3:GNATcov_RTS.Buffers.Witness_Dummy_Type:=GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_test.Statement_Buffer,3);Options : AUnit.Options.AUnit_Options := AUnit.Options.Default_Options;
begin GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_test.Statement_Buffer,4);Options.Report_Successes := False;
   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_test.Statement_Buffer,5);Runner (Reporter, Results, Options);
   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_test.Statement_Buffer,6);AUnit.Test_Results.Clear (Results);
   GNATcov_RTS.Buffers.Witness(GNATcov_RTS.Buffers.PB_protobuf_ada_test.Statement_Buffer,7);Protobuf_Tests.Cleanup;
end GNATcov_Original_Main;GNATcov_RTS.Buffers.DB_protobuf_ada_test.Dump_Buffers;end Protobuf_Ada_Test;

