--
--  Copyright (C) 2026, Simon Kraemer <simon.kraemer@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with A0B.Types;
with A0B.Types.SVD;
with A0B.ATSAM3X8E.SVD.UART; use A0B.ATSAM3X8E.SVD.UART;

package body A0B.ATSAM3X8E.UART is

   procedure Configure (Self : in out UART_Controller_Base'Class;
      Baud_Rate : Integer) is
   begin
      Self.Peripheral.PTCR :=
         (RXTDIS => True,
         TXTDIS => True,
         others => <>);

      --  Configure UART0: 8N1, no parity, 115200 baud at 84 MHz master clock.
      Self.Peripheral.CR :=
         (RSTRX => True,
         RSTTX => True,
         RXDIS => True,
         TXDIS => True,
         RSTSTA => True,
         others => <>);

      Self.Peripheral.MR :=
         (PAR    => A0B.ATSAM3X8E.SVD.UART.NO,
         CHMODE => A0B.ATSAM3X8E.SVD.UART.NORMAL,
         others => <>);

      --  CD = MCK / (16 * Baud) ~= 84_000_000 / (16 * Baud_Rate)
      Self.Peripheral.BRGR :=
         (CD => UART_BRGR_CD_Field (84_000_000 / (16 * Baud_Rate)),
         others => <>);

      Self.Peripheral.CR :=
         (RXEN => True,
         TXEN => True,
         others => <>);
   end Configure;

   procedure Write_Char (Self : in out UART_Controller_Base'Class;
      C : Character) is
   begin
      while not Self.Peripheral.SR.TXRDY loop
         null;
      end loop;

      Self.Peripheral.THR :=
        (TXCHR => A0B.Types.SVD.Byte (Character'Pos (C)),
         others => <>);
   end Write_Char;

   procedure Read_Char (Self : in out UART_Controller_Base'Class;
      C : out Character) is
   begin
      while not Self.Peripheral.SR.RXRDY loop
         null;
      end loop;

      C := Character'Val (Self.Peripheral.RHR.RXCHR);
   end Read_Char;

   function Is_Transmit_Ready (Self : UART_Controller_Base'Class)
      return Boolean is
   begin
      return Self.Peripheral.SR.TXRDY;
   end Is_Transmit_Ready;

   function Is_Receive_Ready (Self : UART_Controller_Base'Class)
      return Boolean is
   begin
      return Self.Peripheral.SR.RXRDY;
   end Is_Receive_Ready;

end A0B.ATSAM3X8E.UART;