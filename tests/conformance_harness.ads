with Conformance;

--  The testee side of the protobuf conformance protocol: turn one
--  ConformanceRequest into one ConformanceResponse. Kept separate from the I/O
--  loop (conformance_runner.adb) so it can be unit-tested directly.
package Conformance_Harness is

   function Handle (Req : Conformance.ConformanceRequest)
                    return Conformance.ConformanceResponse;

end Conformance_Harness;
