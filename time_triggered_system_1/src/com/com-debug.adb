with A0B.ATSAM3X8E.UART;
with A0B.Types.SVD;
with A0B.ATSAM3X8E.SVD;
with A0B.ATSAM3X8E.SVD.PIO;
with A0B.ATSAM3X8E.SVD.PMC;

package body COM.Debug is
   Uart : A0B.ATSAM3X8E.UART.UART_Controller renames A0B.ATSAM3X8E.UART.UART1;

   use type A0B.Types.SVD.UInt32;

   --  Buffer_Size : constant Natural := 1024;

   Rx_Buffer : Circular_Buffer_Character;
   Tx_Buffer : Circular_Buffer_Character;

   UART_TX_PIN_MASK : constant A0B.Types.SVD.UInt32 := 2 ** 9;
   UART_RX_PIN_MASK : constant A0B.Types.SVD.UInt32 := 2 ** 8;
   UART_PINS_MASK   : constant A0B.Types.SVD.UInt32 :=
      UART_TX_PIN_MASK or UART_RX_PIN_MASK;

   procedure Initialize is
   begin
      --  Enable peripheral clocks for UART (PID8) and PIOA (PID11).
      A0B.ATSAM3X8E.SVD.PMC.PMC_Periph.PMC_PCER0 :=
         (Reserved_0_7 => 0,
         PID          => (As_Array => True,
         Arr      => (8 => True, 11 => True, others => False)));

      Configure_UART_Pins;
      Uart.Configure (9_600);
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
      Receive_Character;
      Transmit_Character;
   end Update;

   procedure Receive_Character is
      Received_Char : Character;
   begin
      if Uart.Is_Receive_Ready then
         Uart.Read_Char (Received_Char);
         if not Rx_Buffer.Is_Buffer_Full then
            Rx_Buffer.Put_Character (Received_Char);
         end if;
      end if;
   end Receive_Character;

   procedure Transmit_Character is
      Next_Char : Character;
   begin
      if Uart.Is_Transmit_Ready and then not Tx_Buffer.Is_Buffer_Empty then
         Next_Char := Tx_Buffer.Get_Character;
         Uart.Write_Char (Next_Char);
      end if;
   end Transmit_Character;

   procedure Put_Tx_Character (C : Character) is
   begin
      if not Tx_Buffer.Is_Buffer_Full then
         Tx_Buffer.Put_Character (C);
      end if;
   end Put_Tx_Character;

   procedure Put_Tx_String (S : String) is
   begin
      for C of S loop
         Put_Tx_Character (C);
      end loop;
   end Put_Tx_String;

   function Is_Rx_Character_Available return Boolean is
   begin
      return not Rx_Buffer.Is_Buffer_Empty;
   end Is_Rx_Character_Available;

   function Get_Next_Rx_Character return Character is
      Next_Character : Character;
   begin
      if Is_Rx_Character_Available then
         Next_Character := Rx_Buffer.Get_Character;
         return Next_Character;
      else
         raise Constraint_Error;
      end if;
   end Get_Next_Rx_Character;

   procedure Put_Character (Self : in out Circular_Buffer_Character;
      C : Character) is
   begin
      Self.Data (Self.Head) := C;
      Self.Head := Self.Head + 1;
      if Self.Head = Buffer_Size then
         Self.Head := 0;
      end if;
   end Put_Character;

   function Get_Character (Self : in out Circular_Buffer_Character)
      return Character is
      Next_Character : Character;
   begin
      if not Is_Buffer_Empty (Self) then
         Self.Tail := Self.Tail + 1;
         if Self.Tail = Buffer_Size then
            Self.Tail := Self.Tail - Buffer_Size;
         end if;

         Next_Character := Self.Data (Self.Tail);
         return Next_Character;
      else
         raise Constraint_Error;
      end if;
   end Get_Character;

   function Is_Buffer_Empty (Self : in out Circular_Buffer_Character)
      return Boolean is
      Temp : Natural;
   begin
      Temp := Self.Tail + 1;
      if Temp = Buffer_Size then
         Temp := Temp - Buffer_Size;
      end if;
      return Temp = Self.Head;
   end Is_Buffer_Empty;

   function Is_Buffer_Full (Self : in out Circular_Buffer_Character)
      return Boolean is
      Temp : Natural;
   begin
      Temp := Self.Head + 1;
      if Temp = Buffer_Size then
         Temp := Temp - Buffer_Size;
      end if;
      return Temp = Self.Tail;
   end Is_Buffer_Full;

end COM.Debug;