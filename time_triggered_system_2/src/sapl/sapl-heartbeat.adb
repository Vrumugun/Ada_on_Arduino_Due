with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOB;
with COM.Debug;
with COM.Cross;
with A0B.Types.SVD;
with SAPL.Processor;

package body SAPL.Heartbeat is
   LED   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
        renames A0B.ATSAM3X8E.PIO.PIOB.PB27;
   LED_State : Boolean := False;

   Tx_Test_Message : constant String := "Hello, World!" &
      Character'Val (13) & Character'Val (10);
   Rx_Test_Message : String (1 .. 14);
   Tx_Index : Integer := Tx_Test_Message'First;
   Rx_Index : Integer := Rx_Test_Message'First;
   Send_Test_Message : constant Boolean := False;

   use type A0B.Types.SVD.UInt32;

   Counter : A0B.Types.SVD.UInt32 := 0;
   Counter_Duplicate : A0B.Types.SVD.UInt32 := (2 ** 32 - 1);

   procedure Initialize is
   begin
      LED.Configure_Output;
   end Initialize;

   procedure Update is
      Rx_C : Character;
   begin
      if Send_Test_Message then
         if Tx_Index <= Tx_Test_Message'Last then
            COM.Debug.Put_Tx_String ("Transmitting: " & Tx_Test_Message (Tx_Index)'Image &
               Character'Val (13) & Character'Val (10));
            COM.Cross.Put_Tx_Character (Tx_Test_Message (Tx_Index));
            Tx_Index := Tx_Index + 1;
         else
            Tx_Index := Tx_Test_Message'First;
         end if;

         if COM.Cross.Is_Rx_Character_Available then
            Rx_C := COM.Cross.Get_Next_Rx_Character;
            COM.Debug .Put_Tx_String ("Received: " & Rx_C'Image &
               Character'Val (13) & Character'Val (10));
            Rx_Test_Message (Rx_Index) := Rx_C;
            Rx_Index := Rx_Index + 1;
            if Rx_Index > Rx_Test_Message'Last then
               Rx_Index := Rx_Test_Message'First;
            end if;
         end if;
      end if;

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