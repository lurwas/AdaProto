pragma Style_Checks (Off); pragma Warnings (Off);
with GNATcov_RTS.Buffers.BB_fixture_loader;
with GNATcov_RTS.Buffers.BB_protobuf;
with GNATcov_RTS.Buffers.BB_protobuf_ada_bench;
with GNATcov_RTS.Buffers.BB_protobuf_ada_fuzzzz;
with GNATcov_RTS.Buffers.BB_protobuf_ada_junit;
with GNATcov_RTS.Buffers.BB_protobuf_ada_test;
with GNATcov_RTS.Buffers.BB_protobuf_tests;
with GNATcov_RTS.Buffers.BS_fixture_loader;
with GNATcov_RTS.Buffers.BS_protobuf;
with GNATcov_RTS.Buffers.BS_protobuf_tests;

package GNATcov_RTS.Buffers.Lists.protobuf_ada is

   List : constant Unit_Coverage_Buffers_Array :=
     (GNATcov_RTS.Buffers.BB_fixture_loader.Buffers'Access,
      GNATcov_RTS.Buffers.BB_protobuf.Buffers'Access,
      GNATcov_RTS.Buffers.BB_protobuf_ada_bench.Buffers'Access,
      GNATcov_RTS.Buffers.BB_protobuf_ada_fuzzzz.Buffers'Access,
      GNATcov_RTS.Buffers.BB_protobuf_ada_junit.Buffers'Access,
      GNATcov_RTS.Buffers.BB_protobuf_ada_test.Buffers'Access,
      GNATcov_RTS.Buffers.BB_protobuf_tests.Buffers'Access,
      GNATcov_RTS.Buffers.BS_fixture_loader.Buffers'Access,
      GNATcov_RTS.Buffers.BS_protobuf.Buffers'Access,
      GNATcov_RTS.Buffers.BS_protobuf_tests.Buffers'Access);

end GNATcov_RTS.Buffers.Lists.protobuf_ada;
