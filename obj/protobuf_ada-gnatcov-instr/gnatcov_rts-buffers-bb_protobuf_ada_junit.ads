pragma Style_Checks (Off); pragma Warnings (Off);
package GNATcov_RTS.Buffers.BB_protobuf_ada_junit is

   pragma Preelaborate;

   Statement_Buffer : Coverage_Buffer_Type (0 .. 7) := (others => False);
   Statement_Buffer_Address : constant System.Address := Statement_Buffer'Address;
   pragma Export (C, Statement_Buffer_Address, "xcov__buf_stmt__B_protobuf_ada_junit");

   Decision_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   Decision_Buffer_Address : constant System.Address := Decision_Buffer'Address;
   pragma Export (C, Decision_Buffer_Address, "xcov__buf_dc__B_protobuf_ada_junit");

   MCDC_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   MCDC_Buffer_Address : constant System.Address := MCDC_Buffer'Address;
   pragma Export (C, MCDC_Buffer_Address, "xcov__buf_mcdc__B_protobuf_ada_junit");

   Buffers : aliased Unit_Coverage_Buffers :=
     (Unit_Name_Length => 18,
      Project_Name_Length => 0,
      Fingerprint => (104, 20, 170, 65, 116, 253, 80, 105, 74, 221, 213, 213, 27, 211, 246, 44, 205, 83, 194, 245),
      Language_Kind => Unit_Based_Language,
      Unit_Part     => Unit_Body,
      Unit_Name     => "protobuf_ada_junit",
      Project_Name => "",
      Statement => Statement_Buffer'Address,
      Decision  => Decision_Buffer'Address,
      MCDC      => MCDC_Buffer'Address,
      Statement_Last_Bit => 7,
      Decision_Last_Bit => -1,
      MCDC_Last_Bit => -1);

end GNATcov_RTS.Buffers.BB_protobuf_ada_junit;
