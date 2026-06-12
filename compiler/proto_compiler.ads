--  Minimal proto3 -> Ada code generator (Phase 1a).
--
--  Parses a subset of the proto3 schema language and emits a typed Ada
--  package (<pkg>.ads/.adb) whose records map to the schema's messages, with
--  Serialize/Parse subprograms layered on the Protobuf wire runtime.
--
--  Supported in this phase: syntax/package declarations, top-level messages,
--  and singular scalar fields (int32/int64/uint32/uint64/sint32/sint64,
--  fixed32/64, sfixed32/64, float, double, bool, string, bytes). Repeated and
--  optional labels, nested messages, enums, oneof, and map raise Compile_Error
--  with a clear message; later phases extend coverage.
package Proto_Compiler is

   Compile_Error : exception;

   --  Parse the proto3 file at Proto_Path and write the generated Ada unit
   --  into Out_Dir. The generated unit name is derived from the proto package
   --  (or "Proto" when no package is declared).
   procedure Generate (Proto_Path : String; Out_Dir : String);

end Proto_Compiler;
