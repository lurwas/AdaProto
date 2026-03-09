pragma Style_Checks (Off); pragma Warnings (Off);
package GNATcov_RTS.Buffers.BB_protobuf_tests is

   pragma Preelaborate;

   Statement_Buffer : Coverage_Buffer_Type (0 .. 559) := (others => False);
   Statement_Buffer_Address : constant System.Address := Statement_Buffer'Address;
   pragma Export (C, Statement_Buffer_Address, "xcov__buf_stmt__B_protobuf_tests");

   Decision_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   Decision_Buffer_Address : constant System.Address := Decision_Buffer'Address;
   pragma Export (C, Decision_Buffer_Address, "xcov__buf_dc__B_protobuf_tests");

   MCDC_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   MCDC_Buffer_Address : constant System.Address := MCDC_Buffer'Address;
   pragma Export (C, MCDC_Buffer_Address, "xcov__buf_mcdc__B_protobuf_tests");

   Buffers : aliased Unit_Coverage_Buffers :=
     (Unit_Name_Length => 14,
      Project_Name_Length => 0,
      Fingerprint => (173, 196, 212, 74, 126, 9, 59, 158, 51, 146, 126, 35, 164, 74, 105, 254, 155, 247, 162, 129),
      Language_Kind => Unit_Based_Language,
      Unit_Part     => Unit_Body,
      Unit_Name     => "protobuf_tests",
      Project_Name => "",
      Statement => Statement_Buffer'Address,
      Decision  => Decision_Buffer'Address,
      MCDC      => MCDC_Buffer'Address,
      Statement_Last_Bit => 559,
      Decision_Last_Bit => -1,
      MCDC_Last_Bit => -1);

end GNATcov_RTS.Buffers.BB_protobuf_tests;
