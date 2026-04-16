with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOB;
with COM.Debug;

package body Heartbeat is
   LED   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
        renames A0B.ATSAM3X8E.PIO.PIOB.PB27;
   LED_State : Boolean := False;
   Counter : Natural := 0;

   procedure Initialize is
   begin
      LED.Configure_Output;
   end Initialize;

   procedure Update is
   begin
      LED.Set (LED_State);
      LED_State := not LED_State;
      Counter := Counter + 1;
      if Counter mod 10 = 0 then
         COM.Debug.Put_Tx_String ("Heartbeat! " & Counter'Image &
            Character'Val (13) & Character'Val (10));
      end if;
   end Update;

end Heartbeat;