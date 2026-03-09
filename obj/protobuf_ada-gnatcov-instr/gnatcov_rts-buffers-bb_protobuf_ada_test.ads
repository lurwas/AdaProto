pragma Style_Checks (Off); pragma Warnings (Off);
package GNATcov_RTS.Buffers.BB_protobuf_ada_test is

   pragma Preelaborate;

   Statement_Buffer : Coverage_Buffer_Type (0 .. 7) := (others => False);
   Statement_Buffer_Address : constant System.Address := Statement_Buffer'Address;
   pragma Export (C, Statement_Buffer_Address, "xcov__buf_stmt__B_protobuf_ada_test");

   Decision_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   Decision_Buffer_Address : constant System.Address := Decision_Buffer'Address;
   pragma Export (C, Decision_Buffer_Address, "xcov__buf_dc__B_protobuf_ada_test");

   MCDC_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   MCDC_Buffer_Address : constant System.Address := MCDC_Buffer'Address;
   pragma Export (C, MCDC_Buffer_Address, "xcov__buf_mcdc__B_protobuf_ada_test");

   Buffers : aliased Unit_Coverage_Buffers :=
     (Unit_Name_Length => 17,
      Project_Name_Length => 0,
      Fingerprint => (209, 26, 121, 112, 89, 163, 136, 139, 93, 84, 121, 75, 238, 83, 225, 46, 145, 190, 65, 253),
      Language_Kind => Unit_Based_Language,
      Unit_Part     => Unit_Body,
      Unit_Name     => "protobuf_ada_test",
      Project_Name => "",
      Statement => Statement_Buffer'Address,
      Decision  => Decision_Buffer'Address,
      MCDC      => MCDC_Buffer'Address,
      Statement_Last_Bit => 7,
      Decision_Last_Bit => -1,
      MCDC_Last_Bit => -1);

end GNATcov_RTS.Buffers.BB_protobuf_ada_test;
