--
--  Copyright (C) 2026, Simon Kraemer <simon.kraemer@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Ada_2022;

with System;
with A0B.Callbacks;
with A0B.ATSAM3X8E.SVD.UART;

package A0B.ATSAM3X8E.UART
  with Preelaborate
is
   type UART_Controller_Base
     (Peripheral : not null access A0B.ATSAM3X8E.SVD.UART.UART_Peripheral;
      Identifier : Peripheral_Identifier)
     is tagged limited
   record
      Busy              : Boolean := False with Volatile;
      --  XXX State of the controller must be protected from interrupt
      --  preemption and task switch.
      Transmit_Buffer   : System.Address;
      Receive_Buffer    : System.Address;
      Finished_Callback : A0B.Callbacks.Callback;
--        Selected_Device : access SPI_Slave_Device'Class;
      Reverse_Bits      : Boolean := False;
   end record;

   procedure Configure (Self : in out UART_Controller_Base'Class;
      Baud_Rate : Integer);
   procedure Write_Char (Self : in out UART_Controller_Base'Class;
      C : Character);

   subtype UART_Controller is
     UART_Controller_Base
     (Peripheral   => A0B.ATSAM3X8E.SVD.UART.UART_Periph'Access,
      Identifier   =>
        Universal_Synchronous_Asynchronous_Receiver_Transmitter_1);

   UART1 : aliased UART_Controller;

end A0B.ATSAM3X8E.UART;