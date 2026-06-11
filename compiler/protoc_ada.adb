with Ada.Command_Line;  use Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO;       use Ada.Text_IO;
with Proto_Compiler;

--  protoc-ada <input.proto> <output-dir>
--
--  Generates a typed Ada package from a proto3 schema (Phase 1a subset).
procedure Protoc_Ada is
begin
   if Argument_Count /= 2 then
      Put_Line (Standard_Error, "usage: protoc-ada <input.proto> <output-dir>");
      Set_Exit_Status (Failure);
      return;
   end if;

   Proto_Compiler.Generate (Argument (1), Argument (2));
exception
   when E : Proto_Compiler.Compile_Error =>
      Put_Line (Standard_Error,
                "protoc-ada: " & Ada.Exceptions.Exception_Message (E));
      Set_Exit_Status (Failure);
end Protoc_Ada;
