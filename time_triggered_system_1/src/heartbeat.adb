with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOB;

package body Heartbeat is
   LED   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
        renames A0B.ATSAM3X8E.PIO.PIOB.PB27;
   LED_State : Boolean := False;

   procedure Initialize is
   begin
      LED.Configure_Output;
   end Initialize;

   procedure Update is
   begin
      LED.Set (LED_State);
      LED_State := not LED_State;
   end Update;

end Heartbeat;