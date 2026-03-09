pragma Style_Checks (Off); pragma Warnings (Off);
package GNATcov_RTS.Buffers.DB_protobuf_ada_bench is

   procedure Dump_Buffers;
   pragma Export (C, Dump_Buffers, "gnatcov_rts_B_protobuf_ada_bench_dump_buffers");

end GNATcov_RTS.Buffers.DB_protobuf_ada_bench;
