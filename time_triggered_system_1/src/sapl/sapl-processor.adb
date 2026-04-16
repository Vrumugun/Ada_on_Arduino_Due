with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOA;
with A0B.ARMv7M;
with A0B.ARMv7M.SysTick_Clock_Timer;
with A0B.ARMv7M.Instructions;
with COM.Debug;

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

   procedure Fail_Safe (Error_Code : Fail_Safe_Error_Codes) is
   begin
      Disable_Interrupts;
      LED_TX.Set (False);
      COM.Debug.Put_Tx_String ("Fail Safe!" & Error_Code'Image & Character'Val (13) & Character'Val (10));
      loop
         --  for debugging purposes, print the fail safe message.
         COM.Debug.Update;
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