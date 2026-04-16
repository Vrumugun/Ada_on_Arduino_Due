with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOA;
with A0B.ATSAM3X8E.PIO.PIOB;
with A0B.Timer;
with A0B.Callbacks.Generic_Parameterless;

package Led_Timer is
   LED   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOB.PB27;
   LED_TX   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOA.PA21;
   State : Boolean := False;

   procedure On_Timer;

   package On_Timer_Callbacks is
     new A0B.Callbacks.Generic_Parameterless (On_Timer);

   Timer : aliased A0B.Timer.Timeout_Control_Block;

   type Delay_Counter is mod 2 ** 32;
   Busy_Delay : Delay_Counter := 0 with Volatile;

   procedure Initialize;

end Led_Timer;