with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOA;
with A0B.ATSAM3X8E.PIO.PIOB;
with A0B.ATSAM3X8E.UART;
with A0B.ATSAM3X8E.WDT;
with A0B.ARMv7M;
with A0B.ATSAM3X8E.SVD;
with A0B.ATSAM3X8E.SVD.PIO;
with A0B.ATSAM3X8E.SVD.PMC;
with A0B.ARMv7M.SysTick_Clock_Timer;
with A0B.Types.SVD;

procedure Uart_Echo is
   Uart : A0B.ATSAM3X8E.UART.UART_Controller renames A0B.ATSAM3X8E.UART.UART1;
   LED   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOB.PB27;
   LED_TX   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOA.PA21;
   WDT : A0B.ATSAM3X8E.WDT.WDT_Controller renames A0B.ATSAM3X8E.WDT.WDT;

   Header : constant String := "UART Echo: " &
      "Type a message!" &
      Character'Val (13) & Character'Val (10);

   type Delay_Counter is mod 2 ** 32;
   Busy_Delay : Delay_Counter := 0 with Volatile;
   State : Boolean := False with Volatile;

   use type A0B.Types.SVD.UInt32;

   UART_TX_PIN_MASK : constant A0B.Types.SVD.UInt32 := 2 ** 9;
   UART_RX_PIN_MASK : constant A0B.Types.SVD.UInt32 := 2 ** 8;
   UART_PINS_MASK   : constant A0B.Types.SVD.UInt32 :=
      UART_TX_PIN_MASK or UART_RX_PIN_MASK;

   procedure Configure_UART_Pins is
   begin
      --  Route PA8/PA9 to peripheral A (UART RX/TX) and disable PIO control.
      declare
         AB_Select : A0B.ATSAM3X8E.SVD.PIO.PIOA_ABSR_Register :=
         A0B.ATSAM3X8E.SVD.PIO.PIOA_Periph.ABSR;
      begin
         AB_Select.Val := AB_Select.Val and not UART_PINS_MASK;
         A0B.ATSAM3X8E.SVD.PIO.PIOA_Periph.ABSR := AB_Select;
      end;

      --  Enable pull-up resistors on RX pin and Tx pin.
      A0B.ATSAM3X8E.SVD.PIO.PIOA_Periph.PUER := (As_Array => False,
         Val => UART_PINS_MASK);

      --  Disable PIO control of the pins,
      --  so they are controlled by the peripheral.
      A0B.ATSAM3X8E.SVD.PIO.PIOA_Periph.PDR := (As_Array => False,
         Val => UART_PINS_MASK);
   end Configure_UART_Pins;

begin
   A0B.ARMv7M.SysTick_Clock_Timer.Initialize
        (Use_Processor_Clock => True,
         Clock_Frequency     => 84_000_000);

   --  The watchdog is enabled by default on the SAM3X8E.
   --  If not reloaded or disabled, it will reset the board after ~16 seconds.
   --  Configure watchdog or call WDT.Disable instead
   WDT.Configure (16#FFF#);

   LED.Configure_Output;
   LED_TX.Configure_Output;

   --  Enable peripheral clocks for UART (PID8) and PIOA (PID11).
   A0B.ATSAM3X8E.SVD.PMC.PMC_Periph.PMC_PCER0 :=
     (Reserved_0_7 => 0,
      PID          => (As_Array => True,
                       Arr      => (8 => True, 11 => True, others => False)));

   Configure_UART_Pins;

   Uart.Configure (9_600);

   for C of Header loop
         Uart.Write_Char (C);
   end loop;

   LED_TX.Set (False);

   loop

      if Uart.Is_Receive_Ready then
         declare
            Received_Char : Character;
         begin
            Uart.Read_Char (Received_Char);
            if Received_Char = Character'Val (13) then
               --  If the received character is a carriage return, send a newline as well.
               Uart.Write_Char (Character'Val (10));
            end if;
            Uart.Write_Char (Received_Char);
         end;
      end if;

      --  Toggle LED every ~5 million iterations to show
      --  that the program is alive and not stuck in the UART routines.
      Busy_Delay := Busy_Delay + 1;
      if Busy_Delay > 1_000_000 then
         LED.Set (State);
         State := not State;
         Busy_Delay := 0;
      end if;

      WDT.Reload;
   end loop;
end Uart_Echo;
