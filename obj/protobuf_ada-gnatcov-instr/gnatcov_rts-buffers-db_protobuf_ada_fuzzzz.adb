pragma Style_Checks (Off); pragma Warnings (Off);
with GNATcov_RTS.Traces.Output.Files;
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
package body GNATcov_RTS.Buffers.DB_protobuf_ada_fuzzzz is

   procedure Dump_Buffers is
   begin
      GNATcov_RTS.Traces.Output.Files.Write_Trace_File
        ((1 => GNATcov_RTS.Buffers.BB_fixture_loader.Buffers'Access,
          2 => GNATcov_RTS.Buffers.BB_protobuf.Buffers'Access,
          3 => GNATcov_RTS.Buffers.BB_protobuf_ada_bench.Buffers'Access,
          4 => GNATcov_RTS.Buffers.BB_protobuf_ada_fuzzzz.Buffers'Access,
          5 => GNATcov_RTS.Buffers.BB_protobuf_ada_junit.Buffers'Access,
          6 => GNATcov_RTS.Buffers.BB_protobuf_ada_test.Buffers'Access,
          7 => GNATcov_RTS.Buffers.BB_protobuf_tests.Buffers'Access,
          8 => GNATcov_RTS.Buffers.BS_fixture_loader.Buffers'Access,
          9 => GNATcov_RTS.Buffers.BS_protobuf.Buffers'Access,
          10 => GNATcov_RTS.Buffers.BS_protobuf_tests.Buffers'Access),
         Filename => GNATcov_RTS.Traces.Output.Files.Default_Trace_Filename
           (Prefix => "protobuf-ada-fuzz",
            Env_Var => GNATcov_RTS.Traces.Output.Files.Default_Trace_Filename_Env_Var,
            Tag => "69af0238",
            Simple => True));
   end Dump_Buffers;

end GNATcov_RTS.Buffers.DB_protobuf_ada_fuzzzz;
