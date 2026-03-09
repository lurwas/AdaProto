pragma Style_Checks (Off); pragma Warnings (Off);
package GNATcov_RTS.Buffers.BB_protobuf_ada_bench is

   pragma Preelaborate;

   Statement_Buffer : Coverage_Buffer_Type (0 .. 32) := (others => False);
   Statement_Buffer_Address : constant System.Address := Statement_Buffer'Address;
   pragma Export (C, Statement_Buffer_Address, "xcov__buf_stmt__B_protobuf_ada_bench");

   Decision_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   Decision_Buffer_Address : constant System.Address := Decision_Buffer'Address;
   pragma Export (C, Decision_Buffer_Address, "xcov__buf_dc__B_protobuf_ada_bench");

   MCDC_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   MCDC_Buffer_Address : constant System.Address := MCDC_Buffer'Address;
   pragma Export (C, MCDC_Buffer_Address, "xcov__buf_mcdc__B_protobuf_ada_bench");

   Buffers : aliased Unit_Coverage_Buffers :=
     (Unit_Name_Length => 18,
      Project_Name_Length => 0,
      Fingerprint => (247, 68, 241, 158, 1, 80, 207, 147, 188, 128, 65, 163, 19, 173, 114, 116, 192, 25, 210, 168),
      Language_Kind => Unit_Based_Language,
      Unit_Part     => Unit_Body,
      Unit_Name     => "protobuf_ada_bench",
      Project_Name => "",
      Statement => Statement_Buffer'Address,
      Decision  => Decision_Buffer'Address,
      MCDC      => MCDC_Buffer'Address,
      Statement_Last_Bit => 32,
      Decision_Last_Bit => -1,
      MCDC_Last_Bit => -1);

end GNATcov_RTS.Buffers.BB_protobuf_ada_bench;
