with SAPL.Processor;
with SAPL.Scheduler;
with SAPL.Watchdog;
with SAPL.Heartbeat;
with SAPL.State_Machine;
with SAPL.Shell;
with SAPL.Input;
with SAPL.Input_Diag;
with SAPL.Version;
with COM.Debug;
with COM.Cross;
with SAPL.Output;

procedure Time_Triggered_System_2 is
   Message : constant String := "Time triggered system 2 - Version: " &
       SAPL.Version.Firmware_Version & Character'Val (13) & Character'Val (10);
begin
   SAPL.Processor.Initialize;
   COM.Debug.Initialize;
   COM.Cross.Initialize;
   SAPL.Watchdog.Initialize (1100.0);
   SAPL.Heartbeat.Initialize;
   SAPL.Input.Initialize;
   SAPL.Input_Diag.Initialize;
   SAPL.State_Machine.Initialize;
   SAPL.Shell.Initialize;
   SAPL.Output.Initialize;
   SAPL.Scheduler.Initialize (1000);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.Input.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 1);

   SAPL.Scheduler.Add_Task
      (Callback     => COM.Cross.On_Update_Rx.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 10);

   SAPL.Scheduler.Add_Task
      (Callback     => COM.Debug.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 2);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.Output.On_Update.Create_Callback,
      Delay_ticks  => 2,
      Period_ticks => 4);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.Input_Diag.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 10);

   SAPL.Scheduler.Add_Task
      (Callback     => COM.Cross.On_Update_Tx.Create_Callback,
      Delay_ticks  => 1,
      Period_ticks => 200);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.State_Machine.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 1000);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.Shell.On_Update.Create_Callback,
      Delay_ticks  => 100,
      Period_ticks => 200);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.Heartbeat.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 1000);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.Watchdog.On_Update.Create_Callback,
      Delay_ticks  => 1,
      Period_ticks => 1000);

   COM.Debug.Put_Tx_String (Message);

   SAPL.Scheduler.Start;

   loop
      SAPL.Scheduler.Dispatch_Tasks;
   end loop;
end Time_Triggered_System_2;
