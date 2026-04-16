with Processor;
with Scheduler;
with Watchdog;
with Heartbeat;
with COM.Debug;

procedure Time_Triggered_System_1 is
   Message : constant String := "Time triggered system 1!" &
      Character'Val (13) & Character'Val (10);
begin
   Processor.Initialize;
   Watchdog.Initialize;
   Heartbeat.Initialize;
   COM.Debug.Initialize;
   Scheduler.Initialize;

   Scheduler.Add_Task
      (Callback     => Watchdog.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 1000);

   Scheduler.Add_Task
      (Callback     => Heartbeat.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 1000);

   Scheduler.Add_Task
      (Callback     => COM.Debug.On_Update.Create_Callback,
      Delay_ticks  => 0,
      Period_ticks => 2);

   COM.Debug.Put_Tx_String (Message);

   Scheduler.Start;

   loop
      Scheduler.Dispatch_Tasks;
   end loop;
end Time_Triggered_System_1;
