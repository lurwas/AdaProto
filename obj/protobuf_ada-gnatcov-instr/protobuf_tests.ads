pragma Style_Checks (Off); pragma Warnings (Off);
with AUnit.Test_Suites;

with GNATcov_RTS.Buffers.PS_protobuf_tests;package Protobuf_Tests is
   function Suite return AUnit.Test_Suites.Access_Test_Suite;
   procedure Cleanup;
end Protobuf_Tests;

