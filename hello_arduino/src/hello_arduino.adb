with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOA;
with A0B.ATSAM3X8E.PIO.PIOB;
with A0B.ARMv7M.SysTick_Clock_Timer;
with A0B.ATSAM3X8E.SVD.SYSC;

procedure Hello_Arduino is
   LED   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOB.PB27;
   LED_TX   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOA.PA21;
   WDT : A0B.ATSAM3X8E.SVD.SYSC.WDT_Peripheral
      renames A0B.ATSAM3X8E.SVD.SYSC.WDT_Periph;
   State : Boolean := False;

   type Delay_Counter is mod 2 ** 32;
   Busy_Delay : Delay_Counter := 0 with Volatile;

   procedure Initialize is
   begin
      A0B.ARMv7M.SysTick_Clock_Timer.Initialize
        (Use_Processor_Clock => True,
         Clock_Frequency     => 84_000_000);

      LED.Configure_Output;
      LED_TX.Configure_Output;
   end Initialize;
begin
   Initialize;
   LED_TX.Set (False);
   WDT.MR := (WDDIS => True, others => <>);

   loop
      LED.Set (State);
      State := not State;

      --  Keep a side effect in the loop so optimization does not remove delay.
      for J in 1 .. 10_000_000 loop
         Busy_Delay := Busy_Delay + 1;
      end loop;
   end loop;
end Hello_Arduino;
