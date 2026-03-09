pragma Style_Checks (Off); pragma Warnings (Off);
with System;
with GNATcov_RTS;
pragma Compile_Time_Error (GNATcov_RTS.Version /= 4,"Incompatible GNATcov_RTS version, please use the GNATcov_RTS project provided with your GNATcoverage distribution.");

package GNATcov_RTS.Buffers.PB_protobuf_ada_junit is

   pragma Pure;

   Statement_Buffer : constant System.Address;
   pragma Import (C, Statement_Buffer, "xcov__buf_stmt__B_protobuf_ada_junit");

   Decision_Buffer : constant System.Address;
   pragma Import (C, Decision_Buffer, "xcov__buf_dc__B_protobuf_ada_junit");

   MCDC_Buffer : constant System.Address;
   pragma Import (C, MCDC_Buffer, "xcov__buf_mcdc__B_protobuf_ada_junit");

end GNATcov_RTS.Buffers.PB_protobuf_ada_junit;
