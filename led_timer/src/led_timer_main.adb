with Led_Timer;
with A0B.ARMv7M.Instructions;
with A0B.ATSAM3X8E.SVD.SYSC;

procedure Led_Timer_Main is
   WDT : A0B.ATSAM3X8E.SVD.SYSC.WDT_Peripheral
      renames A0B.ATSAM3X8E.SVD.SYSC.WDT_Periph;
begin
   WDT.MR := (WDDIS => True, others => <>);
   Led_Timer.Initialize;
   A0B.ARMv7M.Instructions.Enable_Interrupts;
   loop
      --  Switch CPU into lower power mode.
      A0B.ARMv7M.Instructions.Wait_For_Interrupt;
   end loop;
end Led_Timer_Main;
