with AUnit.Options;
with AUnit.Reporter.Text;
with AUnit.Run;
with AUnit.Test_Results;
with Protobuf_Tests;

procedure Protobuf_Ada_Test is
   procedure Runner is new AUnit.Run.Test_Runner_With_Results (Protobuf_Tests.Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
   Results : AUnit.Test_Results.Result;
   Options : AUnit.Options.AUnit_Options := AUnit.Options.Default_Options;
begin
   Options.Report_Successes := False;
   Runner (Reporter, Results, Options);
   AUnit.Test_Results.Clear (Results);
   Protobuf_Tests.Cleanup;
end Protobuf_Ada_Test;
