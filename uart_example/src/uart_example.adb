with A0B.ARMv7M.SysTick_Clock_Timer;
with A0B.Types.SVD;
with A0B.ATSAM3X8E.SVD.PIO;
with A0B.ATSAM3X8E.SVD.PMC;
with A0B.ATSAM3X8E.SVD.UART;

with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOA;
with A0B.ATSAM3X8E.PIO.PIOB;

with A0B.ATSAM3X8E.SVD.SYSC;

procedure Uart_Example is
   LED   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOB.PB27;
   LED_TX   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOA.PA21;
   WDT : A0B.ATSAM3X8E.SVD.SYSC.WDT_Peripheral
      renames A0B.ATSAM3X8E.SVD.SYSC.WDT_Periph;

   type Delay_Counter is mod 2 ** 32;
   Busy_Delay : Delay_Counter := 0 with Volatile;

   use type A0B.Types.SVD.UInt32;

   UART_TX_PIN_MASK : constant A0B.Types.SVD.UInt32 := 2 ** 9;
   UART_RX_PIN_MASK : constant A0B.Types.SVD.UInt32 := 2 ** 8;
   UART_PINS_MASK   : constant A0B.Types.SVD.UInt32 :=
      UART_TX_PIN_MASK or UART_RX_PIN_MASK;

   Message : constant String := "Hello from Ada UART on Arduino Due!" &
      Character'Val (13) & Character'Val (10);

   procedure UART_Write_Char (C : Character);

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

   procedure UART_Initialize is
   begin
      A0B.ATSAM3X8E.SVD.UART.UART_Periph.PTCR :=
      (RXTDIS => True,
         TXTDIS => True,
         others => <>);

      --  Configure UART0: 8N1, no parity, 115200 baud at 84 MHz master clock.
      A0B.ATSAM3X8E.SVD.UART.UART_Periph.CR :=
      (RSTRX => True,
         RSTTX => True,
         RXDIS => True,
         TXDIS => True,
         RSTSTA => True,
         others => <>);

      A0B.ATSAM3X8E.SVD.UART.UART_Periph.MR :=
      (PAR    => A0B.ATSAM3X8E.SVD.UART.NO,
         CHMODE => A0B.ATSAM3X8E.SVD.UART.NORMAL,

         others => <>);

      --  CD = MCK / (16 * Baud) ~= 84_000_000 / (16 * 115_200) = 46
      --  A0B.ATSAM3X8E.SVD.UART.UART_Periph.BRGR := (CD => 46, others => <>);

      --  CD = MCK / (16 * Baud) ~= 84_000_000 / (16 * 9_600) = 546
      A0B.ATSAM3X8E.SVD.UART.UART_Periph.BRGR := (CD => 546, others => <>);

      A0B.ATSAM3X8E.SVD.UART.UART_Periph.CR :=
      (RXEN => True,
         TXEN => True,
         others => <>);
   end UART_Initialize;

   ---------------------
   -- UART_Write_Char --
   ---------------------

   procedure UART_Write_Char (C : Character) is
   begin
      while not A0B.ATSAM3X8E.SVD.UART.UART_Periph.SR.TXRDY loop
         null;
      end loop;

      A0B.ATSAM3X8E.SVD.UART.UART_Periph.THR :=
        (TXCHR => A0B.Types.SVD.Byte (Character'Pos (C)),
         others => <>);
   end UART_Write_Char;

begin
   A0B.ARMv7M.SysTick_Clock_Timer.Initialize
        (Use_Processor_Clock => True,
         Clock_Frequency     => 84_000_000);

   WDT.MR := (WDDIS => True, others => <>);

   LED.Configure_Output;
   LED_TX.Configure_Output;

   --  Enable peripheral clocks for UART (PID8) and PIOA (PID11).
   A0B.ATSAM3X8E.SVD.PMC.PMC_Periph.PMC_PCER0 :=
     (Reserved_0_7 => 0,
      PID          => (As_Array => True,
                       Arr      => (8 => True, 11 => True, others => False)));

   Configure_UART_Pins;

   UART_Initialize;

   loop
      LED_TX.Set (False);
      for C of Message loop
         UART_Write_Char (C);
      end loop;
      LED_TX.Set (True);

      --  Keep a side effect in the loop so optimization does not remove delay.
      for J in 1 .. 10_000_000 loop
         Busy_Delay := Busy_Delay + 1;
      end loop;
   end loop;
end Uart_Example;
