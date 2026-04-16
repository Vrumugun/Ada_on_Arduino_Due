with SAPL.Processor;
with SAPL.Scheduler;
with SAPL.Watchdog;
with SAPL.Heartbeat;
with SAPL.State_Machine;
with SAPL.Shell;
with COM.Debug;

procedure Time_Triggered_System_1 is
   Message : constant String := "Time triggered system 1!" &
      Character'Val (13) & Character'Val (10);
begin
   SAPL.Processor.Initialize;
   SAPL.Watchdog.Initialize;
   SAPL.Heartbeat.Initialize;
   SAPL.State_Machine.Initialize;
   COM.Debug.Initialize;
   SAPL.Scheduler.Initialize (1000);

   SAPL.Scheduler.Add_Task
      (Callback     => COM.Debug.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 2);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.State_Machine.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 10);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.Shell.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 100);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.Watchdog.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 1000);

   SAPL.Scheduler.Add_Task
      (Callback     => SAPL.Heartbeat.On_Update.Create_Callback,
      Delay_ticks  => 1,
      Period_ticks => 2000);

   COM.Debug.Put_Tx_String (Message);

   SAPL.Scheduler.Start;

   loop
      SAPL.Scheduler.Dispatch_Tasks;
   end loop;
end Time_Triggered_System_1;
