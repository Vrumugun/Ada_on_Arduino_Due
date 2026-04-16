with A0B.ATSAM3X8E.UART;
with A0B.Types.SVD;
with A0B.ATSAM3X8E.SVD;
with A0B.ATSAM3X8E.SVD.PIO;
with A0B.ATSAM3X8E.SVD.PMC;

package body COM.Debug is
   Uart : A0B.ATSAM3X8E.UART.UART_Controller renames A0B.ATSAM3X8E.UART.UART1;

   use type A0B.Types.SVD.UInt32;

   UART_TX_PIN_MASK : constant A0B.Types.SVD.UInt32 := 2 ** 9;
   UART_RX_PIN_MASK : constant A0B.Types.SVD.UInt32 := 2 ** 8;
   UART_PINS_MASK   : constant A0B.Types.SVD.UInt32 :=
      UART_TX_PIN_MASK or UART_RX_PIN_MASK;

   Message : constant String := "Hello from COM.Debug!" &
      Character'Val (13) & Character'Val (10);

   procedure Initialize is
   begin
      --  Enable peripheral clocks for UART (PID8) and PIOA (PID11).
      A0B.ATSAM3X8E.SVD.PMC.PMC_Periph.PMC_PCER0 :=
         (Reserved_0_7 => 0,
         PID          => (As_Array => True,
         Arr      => (8 => True, 11 => True, others => False)));

      Configure_UART_Pins;
      Uart.Configure (9_600);
      for C of Message loop
         Uart.Write_Char (C);
      end loop;
   end Initialize;

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

   procedure Update is
   begin
      null;
   end Update;

end COM.Debug;