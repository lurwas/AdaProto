pragma Style_Checks (Off); pragma Warnings (Off);
package GNATcov_RTS.Buffers.BS_protobuf is

   pragma Preelaborate;

   Statement_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   Statement_Buffer_Address : constant System.Address := Statement_Buffer'Address;
   pragma Export (C, Statement_Buffer_Address, "xcov__buf_stmt__S_protobuf");

   Decision_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   Decision_Buffer_Address : constant System.Address := Decision_Buffer'Address;
   pragma Export (C, Decision_Buffer_Address, "xcov__buf_dc__S_protobuf");

   MCDC_Buffer : Coverage_Buffer_Type (0 .. -1) := (others => False);
   MCDC_Buffer_Address : constant System.Address := MCDC_Buffer'Address;
   pragma Export (C, MCDC_Buffer_Address, "xcov__buf_mcdc__S_protobuf");

   Buffers : aliased Unit_Coverage_Buffers :=
     (Unit_Name_Length => 8,
      Project_Name_Length => 0,
      Fingerprint => (240, 58, 61, 67, 181, 179, 217, 179, 79, 129, 180, 0, 94, 151, 220, 177, 154, 4, 214, 14),
      Language_Kind => Unit_Based_Language,
      Unit_Part     => Unit_Spec,
      Unit_Name     => "protobuf",
      Project_Name => "",
      Statement => Statement_Buffer'Address,
      Decision  => Decision_Buffer'Address,
      MCDC      => MCDC_Buffer'Address,
      Statement_Last_Bit => -1,
      Decision_Last_Bit => -1,
      MCDC_Last_Bit => -1);

end GNATcov_RTS.Buffers.BS_protobuf;
