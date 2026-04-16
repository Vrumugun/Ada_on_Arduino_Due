with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOB;
with COM.Debug;
with A0B.Types.SVD;
with SAPL.Processor;

package body SAPL.Heartbeat is
   LED   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
        renames A0B.ATSAM3X8E.PIO.PIOB.PB27;
   LED_State : Boolean := False;

   use type A0B.Types.SVD.UInt32;

   Counter : A0B.Types.SVD.UInt32 := 0;
   Counter_Duplicate : A0B.Types.SVD.UInt32 := (2 ** 32 - 1);

   procedure Initialize is
   begin
      LED.Configure_Output;
   end Initialize;

   procedure Update is
   begin
      if SAPL.Verify_Duplicate_Variable (Counter, Counter_Duplicate) then
         LED.Set (LED_State);
         LED_State := not LED_State;
         Counter := Counter + 1;
         Counter_Duplicate := Counter xor (2 ** 32 - 1);
         if Counter mod 10 = 0 then
            COM.Debug.Put_Tx_String ("Heartbeat! " & Counter'Image &
               Character'Val (13) & Character'Val (10));
         end if;
      else
         SAPL.Processor.Fail_Safe (SAPL.Data_Corruption);
      end if;
   end Update;

end SAPL.Heartbeat;