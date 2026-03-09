pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__protobuf_ada_bench.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__protobuf_ada_bench.adb");
pragma Suppress (Overflow_Check);
with Ada.Exceptions;

package body ada_main is

   E072 : Short_Integer; pragma Import (Ada, E072, "system__os_lib_E");
   E008 : Short_Integer; pragma Import (Ada, E008, "ada__exceptions_E");
   E013 : Short_Integer; pragma Import (Ada, E013, "system__soft_links_E");
   E025 : Short_Integer; pragma Import (Ada, E025, "system__exception_table_E");
   E038 : Short_Integer; pragma Import (Ada, E038, "ada__containers_E");
   E067 : Short_Integer; pragma Import (Ada, E067, "ada__io_exceptions_E");
   E053 : Short_Integer; pragma Import (Ada, E053, "ada__strings_E");
   E055 : Short_Integer; pragma Import (Ada, E055, "ada__strings__maps_E");
   E059 : Short_Integer; pragma Import (Ada, E059, "ada__strings__maps__constants_E");
   E043 : Short_Integer; pragma Import (Ada, E043, "interfaces__c_E");
   E026 : Short_Integer; pragma Import (Ada, E026, "system__exceptions_E");
   E083 : Short_Integer; pragma Import (Ada, E083, "system__object_reader_E");
   E048 : Short_Integer; pragma Import (Ada, E048, "system__dwarf_lines_E");
   E021 : Short_Integer; pragma Import (Ada, E021, "system__soft_links__initialize_E");
   E037 : Short_Integer; pragma Import (Ada, E037, "system__traceback__symbolic_E");
   E188 : Short_Integer; pragma Import (Ada, E188, "ada__assertions_E");
   E216 : Short_Integer; pragma Import (Ada, E216, "ada__numerics_E");
   E103 : Short_Integer; pragma Import (Ada, E103, "ada__strings__utf_encoding_E");
   E109 : Short_Integer; pragma Import (Ada, E109, "ada__tags_E");
   E101 : Short_Integer; pragma Import (Ada, E101, "ada__strings__text_buffers_E");
   E158 : Short_Integer; pragma Import (Ada, E158, "gnat_E");
   E161 : Short_Integer; pragma Import (Ada, E161, "interfaces__c__strings_E");
   E117 : Short_Integer; pragma Import (Ada, E117, "ada__streams_E");
   E129 : Short_Integer; pragma Import (Ada, E129, "system__file_control_block_E");
   E128 : Short_Integer; pragma Import (Ada, E128, "system__finalization_root_E");
   E126 : Short_Integer; pragma Import (Ada, E126, "ada__finalization_E");
   E125 : Short_Integer; pragma Import (Ada, E125, "system__file_io_E");
   E192 : Short_Integer; pragma Import (Ada, E192, "system__storage_pools_E");
   E190 : Short_Integer; pragma Import (Ada, E190, "system__finalization_masters_E");
   E203 : Short_Integer; pragma Import (Ada, E203, "system__storage_pools__subpools_E");
   E170 : Short_Integer; pragma Import (Ada, E170, "ada__strings__unbounded_E");
   E006 : Short_Integer; pragma Import (Ada, E006, "ada__calendar_E");
   E115 : Short_Integer; pragma Import (Ada, E115, "ada__text_io_E");
   E208 : Short_Integer; pragma Import (Ada, E208, "system__pool_global_E");
   E164 : Short_Integer; pragma Import (Ada, E164, "protobuf_E");
   E146 : Short_Integer; pragma Import (Ada, E146, "gnatcov_rts__traces_E");
   E150 : Short_Integer; pragma Import (Ada, E150, "gnatcov_rts__traces__output_E");
   E157 : Short_Integer; pragma Import (Ada, E157, "gnatcov_rts__traces__output__bytes_io_E");
   E153 : Short_Integer; pragma Import (Ada, E153, "gnatcov_rts__traces__output__files_E");
   E134 : Short_Integer; pragma Import (Ada, E134, "gnatcov_rts__buffers__db_protobuf_ada_bench_E");

   Sec_Default_Sized_Stacks : array (1 .. 1) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure finalize_library is
   begin
      declare
         procedure F1;
         pragma Import (Ada, F1, "protobuf__finalize_body");
      begin
         E164 := E164 - 1;
         F1;
      end;
      declare
         procedure F2;
         pragma Import (Ada, F2, "protobuf__finalize_spec");
      begin
         F2;
      end;
      E208 := E208 - 1;
      declare
         procedure F3;
         pragma Import (Ada, F3, "system__pool_global__finalize_spec");
      begin
         F3;
      end;
      E115 := E115 - 1;
      declare
         procedure F4;
         pragma Import (Ada, F4, "ada__text_io__finalize_spec");
      begin
         F4;
      end;
      E170 := E170 - 1;
      declare
         procedure F5;
         pragma Import (Ada, F5, "ada__strings__unbounded__finalize_spec");
      begin
         F5;
      end;
      E203 := E203 - 1;
      declare
         procedure F6;
         pragma Import (Ada, F6, "system__storage_pools__subpools__finalize_spec");
      begin
         F6;
      end;
      E190 := E190 - 1;
      declare
         procedure F7;
         pragma Import (Ada, F7, "system__finalization_masters__finalize_spec");
      begin
         F7;
      end;
      declare
         procedure F8;
         pragma Import (Ada, F8, "system__file_io__finalize_body");
      begin
         E125 := E125 - 1;
         F8;
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
      E025 := E025 + 1;
      Ada.Containers'Elab_Spec;
      E038 := E038 + 1;
      Ada.Io_Exceptions'Elab_Spec;
      E067 := E067 + 1;
      Ada.Strings'Elab_Spec;
      E053 := E053 + 1;
      Ada.Strings.Maps'Elab_Spec;
      E055 := E055 + 1;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E059 := E059 + 1;
      Interfaces.C'Elab_Spec;
      E043 := E043 + 1;
      System.Exceptions'Elab_Spec;
      E026 := E026 + 1;
      System.Object_Reader'Elab_Spec;
      E083 := E083 + 1;
      System.Dwarf_Lines'Elab_Spec;
      E048 := E048 + 1;
      System.Os_Lib'Elab_Body;
      E072 := E072 + 1;
      System.Soft_Links.Initialize'Elab_Body;
      E021 := E021 + 1;
      E013 := E013 + 1;
      System.Traceback.Symbolic'Elab_Body;
      E037 := E037 + 1;
      E008 := E008 + 1;
      Ada.Assertions'Elab_Spec;
      E188 := E188 + 1;
      Ada.Numerics'Elab_Spec;
      E216 := E216 + 1;
      Ada.Strings.Utf_Encoding'Elab_Spec;
      E103 := E103 + 1;
      Ada.Tags'Elab_Spec;
      Ada.Tags'Elab_Body;
      E109 := E109 + 1;
      Ada.Strings.Text_Buffers'Elab_Spec;
      E101 := E101 + 1;
      Gnat'Elab_Spec;
      E158 := E158 + 1;
      Interfaces.C.Strings'Elab_Spec;
      E161 := E161 + 1;
      Ada.Streams'Elab_Spec;
      E117 := E117 + 1;
      System.File_Control_Block'Elab_Spec;
      E129 := E129 + 1;
      System.Finalization_Root'Elab_Spec;
      E128 := E128 + 1;
      Ada.Finalization'Elab_Spec;
      E126 := E126 + 1;
      System.File_Io'Elab_Body;
      E125 := E125 + 1;
      System.Storage_Pools'Elab_Spec;
      E192 := E192 + 1;
      System.Finalization_Masters'Elab_Spec;
      System.Finalization_Masters'Elab_Body;
      E190 := E190 + 1;
      System.Storage_Pools.Subpools'Elab_Spec;
      E203 := E203 + 1;
      Ada.Strings.Unbounded'Elab_Spec;
      E170 := E170 + 1;
      Ada.Calendar'Elab_Spec;
      Ada.Calendar'Elab_Body;
      E006 := E006 + 1;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E115 := E115 + 1;
      System.Pool_Global'Elab_Spec;
      E208 := E208 + 1;
      Protobuf'Elab_Spec;
      Protobuf'Elab_Body;
      E164 := E164 + 1;
      Gnatcov_Rts.Traces'Elab_Spec;
      E146 := E146 + 1;
      E150 := E150 + 1;
      GNATCOV_RTS.TRACES.OUTPUT.BYTES_IO'ELAB_SPEC;
      E157 := E157 + 1;
      E153 := E153 + 1;
      E134 := E134 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_protobuf_ada_bench");

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
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-pb_protobuf.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-pb_protobuf_ada_bench.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-ps_protobuf.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/protobuf.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/gnatcov_rts-buffers-db_protobuf_ada_bench.o
   --   /home/richard/src/Ada/protobuf-ada-best/obj/protobuf_ada_bench.o
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
