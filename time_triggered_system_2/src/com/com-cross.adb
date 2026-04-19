with A0B.ATSAM3X8E.USART;
with A0B.Types.SVD;
with A0B.ATSAM3X8E.SVD;
with A0B.ATSAM3X8E.SVD.PIO;
with A0B.ATSAM3X8E.SVD.USART;

package body COM.Cross is
   Usart0 : A0B.ATSAM3X8E.USART.USART_Controller
      renames A0B.ATSAM3X8E.USART.USART0;

   use type A0B.Types.SVD.UInt32;

   Rx_Buffer : Circular_Buffer_Character;
   Tx_Buffer : Circular_Buffer_Character;

   Tx_Counter : Natural := 0;
   Rx_Counter : Natural := 0;

   USART0_TX_PIN_MASK : constant A0B.Types.SVD.UInt32 := 2 ** 11;
   USART0_RX_PIN_MASK : constant A0B.Types.SVD.UInt32 := 2 ** 10;
   USART0_PINS_MASK   : constant A0B.Types.SVD.UInt32 :=
      USART0_TX_PIN_MASK or USART0_RX_PIN_MASK;

   procedure Initialize is
   begin
      Configure_USART_Pins;
      Usart0.Configure (9_600,
         --  A0B.ATSAM3X8E.SVD.USART.LOCAL_LOOPBACK);
         A0B.ATSAM3X8E.SVD.USART.NORMAL);
   end Initialize;

   procedure Configure_USART_Pins is
   begin
      --  Route PA8/PA9 to peripheral A (UART RX/TX) and disable PIO control.
      declare
         AB_Select : A0B.ATSAM3X8E.SVD.PIO.PIOA_ABSR_Register :=
         A0B.ATSAM3X8E.SVD.PIO.PIOA_Periph.ABSR;
      begin
         AB_Select.Val := AB_Select.Val and not USART0_PINS_MASK;
         A0B.ATSAM3X8E.SVD.PIO.PIOA_Periph.ABSR := AB_Select;
      end;

      --  Enable pull-up resistors on RX pin and Tx pin.
      A0B.ATSAM3X8E.SVD.PIO.PIOA_Periph.PUER := (As_Array => False,
         Val => USART0_PINS_MASK);

      --  Disable PIO control of the pins,
      --  so they are controlled by the peripheral.
      A0B.ATSAM3X8E.SVD.PIO.PIOA_Periph.PDR := (As_Array => False,
         Val => USART0_PINS_MASK);
   end Configure_USART_Pins;

   procedure Update_Tx is
   begin
      Transmit_Character;
   end Update_Tx;

   procedure Update_Rx is
   begin
      Receive_Character;
   end Update_Rx;

   procedure Receive_Character is
      C : Character;
   begin
      if Usart0.Is_Receive_Ready then
         Usart0.Read_Char (C);
         if not Rx_Buffer.Is_Buffer_Full then
            Rx_Buffer.Put_Character (C);
            Rx_Counter := Rx_Counter + 1;
         end if;
      end if;
   end Receive_Character;

   procedure Transmit_Character is
      Next_Char : Character;
   begin
      if Usart0.Is_Transmit_Ready and then not Tx_Buffer.Is_Buffer_Empty then
         Next_Char := Tx_Buffer.Get_Character;
         Usart0.Write_Char (Next_Char);
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

   function Get_Rx_Counter return Natural is
   begin
      return Rx_Counter;
   end Get_Rx_Counter;

   function Get_Tx_Counter return Natural is
   begin
      return Tx_Counter;
   end Get_Tx_Counter;

end COM.Cross;