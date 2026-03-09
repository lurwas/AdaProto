pragma Style_Checks (Off); pragma Warnings (Off);
with GNATcov_RTS.Buffers.PS_fixture_loader;package Fixture_Loader is
   function Read_Fixture (Name : String) return String;
end Fixture_Loader;

