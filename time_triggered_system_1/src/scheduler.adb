with Processor;

package body Scheduler is

   tick_rate_s : Duration := 1.0;
   Task_List : array (Natural range 1 .. 10) of Scheduler_Task;
   Task_Count : Natural := 0;
   Tick_Count : Natural := 0;
   Max_Ticks : constant Natural := 1;

   procedure Initialize (tick_rate_s : Duration := 0.001) is
   begin
      Scheduler.tick_rate_s := tick_rate_s;
   end Initialize;

   procedure Start is
   begin
      A0B.Timer.Enqueue (Timer, On_Tick_Callbacks.Create_Callback, 0.001);
   end Start;

   procedure Dispatch_Tasks is
      Update_Required : Boolean := False;
   begin
      Processor.Disable_Interrupts;
      if Tick_Count > 0 then
         Update_Required := True;
      end if;
      Processor.Enable_Interrupts;

      while Update_Required loop
         for I in 1 .. Task_Count loop
            if Task_List (I).Delay_ticks > 0 then
               Task_List (I).Delay_ticks := Task_List (I).Delay_ticks - 1;
            end if;

            if Task_List (I).Delay_ticks = 0 then
               A0B.Callbacks.Emit (Task_List (I).Callback);
               if Task_List (I).Period_ticks > 0 then
                  Task_List (I).Delay_ticks := Task_List (I).Period_ticks;
               end if;
            end if;
         end loop;

         Processor.Disable_Interrupts;
         if Tick_Count > 0 then
            Tick_Count := Tick_Count - 1;
         else
            Update_Required := False;
         end if;
         Processor.Enable_Interrupts;
      end loop;

      --  Switch CPU into lower power mode.
      Processor.Wait_For_Interrupt;
   end Dispatch_Tasks;

   procedure On_Tick is
   begin
      Tick_Count := Tick_Count + 1;
      if Tick_Count > Max_Ticks then
         Processor.Fail_Safe;
      end if;
      A0B.Timer.Enqueue (Timer, On_Tick_Callbacks.Create_Callback, 0.001);
   end On_Tick;

   procedure Add_Task (Callback : A0B.Callbacks.Callback;
      Delay_ticks : Integer; Period_ticks : Integer) is
      new_task : Scheduler_Task;
   begin
      new_task.Callback := Callback;
      --  +1 to account for the current tick
      new_task.Delay_ticks := Delay_ticks + 1;
      new_task.Period_ticks := Period_ticks;

      Task_List (Task_Count + 1) := new_task;
      Task_Count := Task_Count + 1;
   end Add_Task;

end Scheduler;