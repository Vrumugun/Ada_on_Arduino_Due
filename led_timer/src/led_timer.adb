with A0B.ARMv7M.SysTick_Clock_Timer;

package body Led_Timer is

   procedure Initialize is
   begin
      A0B.ARMv7M.SysTick_Clock_Timer.Initialize
        (Use_Processor_Clock => True,
         Clock_Frequency     => 84_000_000);

      LED.Configure_Output;
      LED_TX.Configure_Output;

      LED_TX.Set (False);

      A0B.Timer.Enqueue (Timer, On_Timer_Callbacks.Create_Callback, 1.0);
   end Initialize;

   procedure On_Timer is
   begin
      State := not State;
      LED.Set (State);

      A0B.Timer.Enqueue (Timer, On_Timer_Callbacks.Create_Callback, 1.0);
   end On_Timer;

end Led_Timer;
