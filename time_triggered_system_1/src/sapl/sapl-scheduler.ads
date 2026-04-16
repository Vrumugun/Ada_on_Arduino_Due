--  with A0B.Time;
--  with A0B.Timer;
with A0B.Callbacks.Generic_Parameterless;

package SAPL.Scheduler is
   procedure Initialize (tick_rate_hz : A0B.Types.Unsigned_32 := 1000);
   procedure Start;
   procedure Dispatch_Tasks;

   procedure On_Tick;

   package On_Tick_Callbacks is
     new A0B.Callbacks.Generic_Parameterless (On_Tick);

   --  Timer : aliased A0B.Timer.Timeout_Control_Block;

   type Scheduler_Task is
   record
      --  Task-specific data and state would go here.
      Delay_ticks : Integer;
      Period_ticks : Integer;
      Callback : A0B.Callbacks.Callback;
   end record;

   procedure Add_Task (Callback : A0B.Callbacks.Callback;
      Delay_ticks : Integer; Period_ticks : Integer);

   function Get_Total_Tick_Count return Natural;

end SAPL.Scheduler;