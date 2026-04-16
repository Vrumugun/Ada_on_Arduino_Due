with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOA;
with A0B.ARMv7M;
with A0B.ARMv7M.SysTick_Clock_Timer;
with A0B.ARMv7M.Instructions;

package body SAPL.Processor is
   LED_TX   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOA.PA21;

   procedure Initialize is
   begin
      A0B.ARMv7M.SysTick_Clock_Timer.Initialize
        (Use_Processor_Clock => True,
         Clock_Frequency     => 84_000_000);
      LED_TX.Configure_Output;
      LED_TX.Set (True);
   end Initialize;

   procedure Fail_Safe is
   begin
      LED_TX.Set (False);
      loop
         null;
      end loop;
   end Fail_Safe;

   procedure Disable_Interrupts is
   begin
      A0B.ARMv7M.Instructions.Disable_Interrupts;
   end Disable_Interrupts;

   procedure Enable_Interrupts is
   begin
      A0B.ARMv7M.Instructions.Enable_Interrupts;
   end Enable_Interrupts;

   procedure Wait_For_Interrupt is
   begin
      A0B.ARMv7M.Instructions.Wait_For_Interrupt;
   end Wait_For_Interrupt;

end SAPL.Processor;