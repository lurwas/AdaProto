pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__protobuf_ada_test.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__protobuf_ada_test.adb");
pragma Suppress (Overflow_Check);
with Ada.Exceptions;

package body ada_main is

   E068 : Short_Integer; pragma Import (Ada, E068, "system__os_lib_E");
   E016 : Short_Integer; pragma Import (Ada, E016, "ada__exceptions_E");
   E012 : Short_Integer; pragma Import (Ada, E012, "system__soft_links_E");
   E010 : Short_Integer; pragma Import (Ada, E010, "system__exception_table_E");
   E033 : Short_Integer; pragma Import (Ada, E033, "ada__containers_E");
   E063 : Short_Integer; pragma Import (Ada, E063, "ada__io_exceptions_E");
   E007 : Short_Integer; pragma Import (Ada, E007, "ada__strings_E");
   E051 : Short_Integer; pragma Import (Ada, E051, "ada__strings__maps_E");
   E055 : Short_Integer; pragma Import (Ada, E055, "ada__strings__maps__constants_E");
   E038 : Short_Integer; pragma Import (Ada, E038, "interfaces__c_E");
   E019 : Short_Integer; pragma Import (Ada, E019, "system__exceptions_E");
   E079 : Short_Integer; pragma Import (Ada, E079, "system__object_reader_E");
   E045 : Short_Integer; pragma Import (Ada, E045, "system__dwarf_lines_E");
   E095 : Short_Integer; pragma Import (Ada, E095, "system__soft_links__initialize_E");
   E032 : Short_Integer; pragma Import (Ada, E032, "system__traceback__symbolic_E");
   E274 : Short_Integer; pragma Import (Ada, E274, "ada__assertions_E");
   E198 : Short_Integer; pragma Import (Ada, E198, "ada__numerics_E");
   E099 : Short_Integer; pragma Import (Ada, E099, "ada__strings__utf_encoding_E");
   E105 : Short_Integer; pragma Import (Ada, E105, "ada__tags_E");
   E005 : Short_Integer; pragma Import (Ada, E005, "ada__strings__text_buffers_E");
   E180 : Short_Integer; pragma Import (Ada, E180, "gnat_E");
   E235 : Short_Integer; pragma Import (Ada, E235, "interfaces__c__strings_E");
   E144 : Short_Integer; pragma Import (Ada, E144, "ada__streams_E");
   E156 : Short_Integer; pragma Import (Ada, E156, "system__file_control_block_E");
   E155 : Short_Integer; pragma Import (Ada, E155, "system__finalization_root_E");
   E153 : Short_Integer; pragma Import (Ada, E153, "ada__finalization_E");
   E152 : Short_Integer; pragma Import (Ada, E152, "system__file_io_E");
   E260 : Short_Integer; pragma Import (Ada, E260, "ada__streams__stream_io_E");
   E175 : Short_Integer; pragma Import (Ada, E175, "system__storage_pools_E");
   E173 : Short_Integer; pragma Import (Ada, E173, "system__finalization_masters_E");
   E285 : Short_Integer; pragma Import (Ada, E285, "system__storage_pools__subpools_E");
   E250 : Short_Integer; pragma Import (Ada, E250, "ada__strings__unbounded_E");
   E135 : Short_Integer; pragma Import (Ada, E135, "ada__calendar_E");
   E142 : Short_Integer; pragma Import (Ada, E142, "ada__text_io_E");
   E177 : Short_Integer; pragma Import (Ada, E177, "system__pool_global_E");
   E258 : Short_Integer; pragma Import (Ada, E258, "system__regexp_E");
   E240 : Short_Integer; pragma Import (Ada, E240, "ada__directories_E");
   E269 : Short_Integer; pragma Import (Ada, E269, "protobuf_E");
   E111 : Short_Integer; pragma Import (Ada, E111, "aunit_E");
   E113 : Short_Integer; pragma Import (Ada, E113, "aunit__memory_E");
   E125 : Short_Integer; pragma Import (Ada, E125, "aunit__memory__utils_E");
   E122 : Short_Integer; pragma Import (Ada, E122, "ada_containers__aunit_lists_E");
   E171 : Short_Integer; pragma Import (Ada, E171, "aunit__tests_E");
   E129 : Short_Integer; pragma Import (Ada, E129, "aunit__time_measure_E");
   E127 : Short_Integer; pragma Import (Ada, E127, "aunit__test_results_E");
   E120 : Short_Integer; pragma Import (Ada, E120, "aunit__assertions_E");
   E116 : Short_Integer; pragma Import (Ada, E116, "aunit__test_filters_E");
   E118 : Short_Integer; pragma Import (Ada, E118, "aunit__simple_test_cases_E");
   E186 : Short_Integer; pragma Import (Ada, E186, "aunit__reporter_E");
   E195 : Short_Integer; pragma Import (Ada, E195, "aunit__reporter__text_E");
   E204 : Short_Integer; pragma Import (Ada, E204, "aunit__test_suites_E");
   E202 : Short_Integer; pragma Import (Ada, E202, "aunit__run_E");
   E264 : Short_Integer; pragma Import (Ada, E264, "fixture_loader_E");
   E221 : Short_Integer; pragma Import (Ada, E221, "gnatcov_rts__traces_E");
   E225 : Short_Integer; pragma Import (Ada, E225, "gnatcov_rts__traces__output_E");
   E232 : Short_Integer; pragma Import (Ada, E232, "gnatcov_rts__traces__output__bytes_io_E");
   E228 : Short_Integer; pragma Import (Ada, E228, "gnatcov_rts__traces__output__files_E");
   E209 : Short_Integer; pragma Import (Ada, E209, "gnatcov_rts__buffers__db_protobuf_ada_test_E");
   E238 : Short_Integer; pragma Import (Ada, E238, "protobuf_tests_E");

   Sec_Default_Sized_Stacks : array (1 .. 1) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure finalize_library is
   begin
      declare
         procedure F1;
         pragma Import (Ada, F1, "protobuf_tests__finalize_body");
      begin
         E238 := E238 - 1;
         F1;
      end;
      E204 := E204 - 1;
      declare
         procedure F2;
         pragma Import (Ada, F2, "aunit__test_suites__finalize_spec");
      begin
         F2;
      end;
      E195 := E195 - 1;
      declare
         procedure F3;
         pragma Import (Ada, F3, "aunit__reporter__text__finalize_spec");
      begin
         F3;
      end;
      E116 := E116 - 1;
      E118 := E118 - 1;
      declare
         procedure F4;
         pragma Import (Ada, F4, "aunit__simple_test_cases__finalize_spec");
      begin
         F4;
      end;
      declare
         procedure F5;
         pragma Import (Ada, F5, "aunit__test_filters__finalize_spec");
      begin
         F5;
      end;
      E120 := E120 - 1;
      declare
         procedure F6;
         pragma Import (Ada, F6, "aunit__assertions__finalize_spec");
      begin
         F6;
      end;
      E127 := E127 - 1;
      declare
         procedure F7;
         pragma Import (Ada, F7, "aunit__test_results__finalize_spec");
      begin
         F7;
      end;
      declare
         procedure F8;
         pragma Import (Ada, F8, "aunit__tests__finalize_spec");
      begin
         E171 := E171 - 1;
         F8;
      end;
      declare
         procedure F9;
         pragma Import (Ada, F9, "protobuf__finalize_body");
      begin
         E269 := E269 - 1;
         F9;
      end;
      declare
         procedure F10;
         pragma Import (Ada, F10, "protobuf__finalize_spec");
      begin
         F10;
      end;
      declare
         procedure F11;
         pragma Import (Ada, F11, "ada__directories__finalize_body");
      begin
         E240 := E240 - 1;
         F11;
      end;
      declare
         procedure F12;
         pragma Import (Ada, F12, "ada__directories__finalize_spec");
      begin
         F12;
      end;
      E258 := E258 - 1;
      declare
         procedure F13;
         pragma Import (Ada, F13, "system__regexp__finalize_spec");
      begin
         F13;
      end;
      E177 := E177 - 1;
      declare
         procedure F14;
         pragma Import (Ada, F14, "system__pool_global__finalize_spec");
      begin
         F14;
      end;
      E142 := E142 - 1;
      declare
         procedure F15;
         pragma Import (Ada, F15, "ada__text_io__finalize_spec");
      begin
         F15;
      end;
      E250 := E250 - 1;
      declare
         procedure F16;
         pragma Import (Ada, F16, "ada__strings__unbounded__finalize_spec");
      begin
         F16;
      end;
      E285 := E285 - 1;
      declare
         procedure F17;
         pragma Import (Ada, F17, "system__storage_pools__subpools__finalize_spec");
      begin
         F17;
      end;
      E173 := E173 - 1;
      declare
         procedure F18;
         pragma Import (Ada, F18, "system__finalization_masters__finalize_spec");
      begin
         F18;
      end;
      E260 := E260 - 1;
      declare
         procedure F19;
         pragma Import (Ada, F19, "ada__streams__stream_io__finalize_spec");
      begin
         F19;
      end;
      declare
         procedure F20;
         pragma Import (Ada, F20, "system__file_io__finalize_body");
      begin
         E152 := E152 - 1;
         F20;
      end;
      declare
         procedure Reraise_Library_Exception_If_Any;
            pragma Import (Ada, Reraise_Library_Exception_If_Any, "__gnat_reraise_library_exception_if_any");
      begin
         Reraise_Library_Exception_If_Any;
      end;
   end finalize_library;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (Ada, s_stalib_adafinal, "system__standard_library__adafinal");

      procedure Runtime_Finalize;
      pragma Import (C, Runtime_Finalize, "__gnat_runtime_finalize");

   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      Runtime_Finalize;
      s_stalib_adafinal;
   end adafinal;

   type No_Param_Proc is access procedure;
   pragma Favor_Top_Level (No_Param_Proc);

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Default_Secondary_Stack_Size : System.Parameters.Size_Type;
      pragma Import (C, Default_Secondary_Stack_Size, "__gnat_default_ss_size");
      Bind_Env_Addr : System.Address;
      pragma Import (C, Bind_Env_Addr, "__gl_bind_env_addr");

      procedure Runtime_Initialize (Install_Handler : Integer);
      pragma Import (C, Runtime_Initialize, "__gnat_runtime_initialize");

      Finalize_Library_Objects : No_Param_Proc;
      pragma Import (C, Finalize_Library_Objects, "__gnat_finalize_library_objects");
      Binder_Sec_Stacks_Count : Natural;
      pragma Import (Ada, Binder_Sec_Stacks_Count, "__gnat_binder_ss_count");
      Default_Sized_SS_Pool : System.Address;
      pragma Import (Ada, Default_Sized_SS_Pool, "__gnat_default_ss_pool");

   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := -1;
      WC_Encoding := 'b';
      Locking_Policy := ' ';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := ' ';
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Detect_Blocking := 0;
      Default_Stack_Size := -1;

      ada_main'Elab_Body;
      Default_Secondary_Stack_Size := System.Parameters.Runtime_Default_Sec_Stack_Size;
      Binder_Sec_Stacks_Count := 1;
      Default_Sized_SS_Pool := Sec_Default_Sized_Stacks'Address;

      Runtime_Initialize (1);

      Finalize_Library_Objects := finalize_library'access;

      Ada.Exceptions'Elab_Spec;
      System.Soft_Links'Elab_Spec;
      System.Exception_Table'Elab_Body;
      E010 := E010 + 1;
      Ada.Containers'Elab_Spec;
      E033 := E033 + 1;
      Ada.Io_Exceptions'Elab_Spec;
      E063 := E063 + 1;
      Ada.Strings'Elab_Spec;
      E007 := E007 + 1;
      Ada.Strings.Maps'Elab_Spec;
      E051 := E051 + 1;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E055 := E055 + 1;
      Interfaces.C'Elab_Spec;
      E038 := E038 + 1;
      System.Exceptions'Elab_Spec;
      E019 := E019 + 1;
      System.Object_Reader'Elab_Spec;
      E079 := E079 + 1;
      System.Dwarf_Lines'Elab_Spec;
      E045 := E045 + 1;
      System.Os_Lib'Elab_Body;
      E068 := E068 + 1;
      System.Soft_Links.Initialize'Elab_Body;
      E095 := E095 + 1;
      E012 := E012 + 1;
      System.Traceback.Symbolic'Elab_Body;
      E032 := E032 + 1;
      E016 := E016 + 1;
      Ada.Assertions'Elab_Spec;
      E274 := E274 + 1;
      Ada.Numerics'Elab_Spec;
      E198 := E198 + 1;
      Ada.Strings.Utf_Encoding'Elab_Spec;
      E099 := E099 + 1;
      Ada.Tags'Elab_Spec;
      Ada.Tags'Elab_Body;
      E105 := E105 + 1;
      Ada.Strings.Text_Buffers'Elab_Spec;
      E005 := E005 + 1;
      Gnat'Elab_Spec;
      E180 := E180 + 1;
      Interfaces.C.Strings'Elab_Spec;
      E235 := E235 + 1;
      Ada.Streams'Elab_Spec;
      E144 := E144 + 1;
      System.File_Control_Block'Elab_Spec;
      E156 := E156 + 1;
      System.Finalization_Root'Elab_Spec;
      E155 := E155 + 1;
      Ada.Finalization'Elab_Spec;
      E153 := E153 + 1;
      System.File_Io'Elab_Body;
      E152 := E152 + 1;
      Ada.Streams.Stream_Io'Elab_Spec;
      E260 := E260 + 1;
      System.Storage_Pools'Elab_Spec;
      E175 := E175 + 1;
      System.Finalization_Masters'Elab_Spec;
      System.Finalization_Masters'Elab_Body;
      E173 := E173 + 1;
      System.Storage_Pools.Subpools'Elab_Spec;
      E285 := E285 + 1;
      Ada.Strings.Unbounded'Elab_Spec;
      E250 := E250 + 1;
      Ada.Calendar'Elab_Spec;
      Ada.Calendar'Elab_Body;
      E135 := E135 + 1;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E142 := E142 + 1;
      System.Pool_Global'Elab_Spec;
      E177 := E177 + 1;
      System.Regexp'Elab_Spec;
      E258 := E258 + 1;
      Ada.Directories'Elab_Spec;
      Ada.Directories'Elab_Body;
      E240 := E240 + 1;
      Protobuf'Elab_Spec;
      Protobuf'Elab_Body;
      E269 := E269 + 1;
      E113 := E113 + 1;
      E111 := E111 + 1;
      E125 := E125 + 1;
      E122 := E122 + 1;
      Aunit.Tests'Elab_Spec;
      E171 := E171 + 1;
      Aunit.Time_Measure'Elab_Spec;
      E129 := E129 + 1;
      Aunit.Test_Results'Elab_Spec;
      E127 := E127 + 1;
      Aunit.Assertions'Elab_Spec;
      Aunit.Assertions'Elab_Body;
      E120 := E120 + 1;
      Aunit.Test_Filters'Elab_Spec;
      Aunit.Simple_Test_Cases'Elab_Spec;
      E118 := E118 + 1;
      E116 := E116 + 1;
      Aunit.Reporter'Elab_Spec;
      E186 := E186 + 1;
      Aunit.Reporter.Text'Elab_Spec;
      E195 := E195 + 1;
      Aunit.Test_Suites'Elab_Spec;
      E204 := E204 + 1;
      E202 := E202 + 1;
      E264 := E264 + 1;
      Gnatcov_Rts.Traces'Elab_Spec;
      E221 := E221 + 1;
      E225 := E225 + 1;
      GNATCOV_RTS.TRACES.OUTPUT.BYTES_IO'ELAB_SPEC;
      E232 := E232 + 1;
      E228 := E228 + 1;
      E209 := E209 + 1;
      Protobuf_Tests'Elab_Body;
      E238 := E238 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_protobuf_ada_test");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer
   is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      if gnat_argc = 0 then
         gnat_argc := argc;
         gnat_argv := argv;
      end if;
      gnat_envp := envp;

      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
      return (gnat_exit_status);
   end;

--  BEGIN Object file/option list
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-bb_fixture_loader.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-bb_protobuf.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-bb_protobuf_ada_bench.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-bb_protobuf_ada_fuzzzz.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-bb_protobuf_ada_junit.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-bb_protobuf_ada_test.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-bb_protobuf_tests.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-bs_fixture_loader.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-bs_protobuf.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-bs_protobuf_tests.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-pb_fixture_loader.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-pb_protobuf.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-pb_protobuf_ada_test.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-pb_protobuf_tests.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-ps_fixture_loader.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-ps_protobuf.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-ps_protobuf_tests.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/protobuf.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/fixture_loader.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-db_protobuf_ada_test.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/protobuf_tests.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/protobuf_ada_test.o
   --   -L/home/richard/src/Ada/protobuf-ada-best/obj/
   --   -L/home/richard/src/Ada/protobuf-ada-best/obj/
   --   -L/usr/lib/aunit/
   --   -L/home/richard/.local/share/gnatcoverage/gnatcov_rts/lib-gnatcov_rts_full.static/
   --   -L/usr/lib/gcc/x86_64-linux-gnu/12/adalib/
   --   -shared
   --   -lgnat-12
   --   -ldl
--  END Object file/option list   

end ada_main;
