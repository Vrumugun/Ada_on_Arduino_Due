with A0B.Timer;
with A0B.Callbacks.Generic_Parameterless;

package Scheduler is
   procedure Initialize (tick_rate_s : Duration := 0.001);
   procedure Start;
   procedure Dispatch_Tasks;

   procedure On_Tick;

   package On_Tick_Callbacks is
     new A0B.Callbacks.Generic_Parameterless (On_Tick);

   Timer : aliased A0B.Timer.Timeout_Control_Block;

   type Scheduler_Task is
   record
      --  Task-specific data and state would go here.
      Delay_ticks : Integer;
      Period_ticks : Integer;
      Callback : A0B.Callbacks.Callback;
   end record;

   procedure Add_Task (Callback : A0B.Callbacks.Callback;
      Delay_ticks : Integer; Period_ticks : Integer);

end Scheduler;