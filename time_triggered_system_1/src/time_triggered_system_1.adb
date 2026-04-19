with SAPL.Processor;
with SAPL.Scheduler;
with SAPL.Watchdog;
with SAPL.Heartbeat;
with SAPL.Version;
with COM.Debug;

procedure Time_Triggered_System_1 is
   Message : constant String := "Time triggered system 1 - Version: " &
       SAPL.Version.Firmware_Version & Character'Val (13) & Character'Val (10);
begin
   SAPL.Processor.Initialize;
   COM.Debug.Initialize;
   SAPL.Watchdog.Initialize (1100.0);
   SAPL.Heartbeat.Initialize;
   SAPL.Scheduler.Initialize (1000);

   SAPL.Scheduler.Add_Task
      (Callback     => COM.Debug.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 2);

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
end Time_Triggered_System_1;
