--
--  Copyright (C) 2026, Simon Kraemer <simon.kraemer@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with A0B.ATSAM3X8E.SVD.USART; use A0B.ATSAM3X8E.SVD.USART;

package body A0B.ATSAM3X8E.USART is

   procedure Configure (Self : in out USART_Controller_Base'Class;
      Baud_Rate : Integer;
      Mode      : A0B.ATSAM3X8E.SVD.USART.MR_CHMODE_Field :=
        A0B.ATSAM3X8E.SVD.USART.NORMAL) is
   begin
      if Baud_Rate <= 0 then
         return;
      end if;

      Self.Peripheral.PTCR :=
         (RXTDIS => True,
         TXTDIS => True,
         others => <>);

      Self.Peripheral.CR :=
         (RSTRX => True,
         RSTTX => True,
         RXDIS => True,
         TXDIS => True,
         RSTSTA => True,
         others => <>);

      Self.Peripheral.MR :=
         (USART_MODE => A0B.ATSAM3X8E.SVD.USART.NORMAL,
         USCLKS     => A0B.ATSAM3X8E.SVD.USART.MCK,
         CHRL       => A0B.ATSAM3X8E.SVD.USART.Val_8_BIT,
         SYNC       => False,
         PAR        => A0B.ATSAM3X8E.SVD.USART.NO,
         NBSTOP     => A0B.ATSAM3X8E.SVD.USART.Val_1_BIT,
         CHMODE     => Mode,
         others     => <>);

      Self.Peripheral.BRGR :=
         (CD => USART0_BRGR_CD_Field (84_000_000 / (16 * Baud_Rate)),
         FP => 0,
         others => <>);

      Self.Peripheral.CR :=
         (RXEN => True,
         TXEN => True,
         others => <>);
   end Configure;

   procedure Write_Char (Self : in out USART_Controller_Base'Class;
      C : Character) is
   begin
      while not Self.Peripheral.CSR.TXRDY loop
         null;
      end loop;

      Self.Peripheral.THR :=
         (TXCHR => USART0_THR_TXCHR_Field (Character'Pos (C)),
         others => <>);
   end Write_Char;

   procedure Read_Char (Self : in out USART_Controller_Base'Class;
      C : out Character) is
   begin
      while not Self.Peripheral.CSR.RXRDY loop
         null;
      end loop;

      C := Character'Val (Self.Peripheral.RHR.RXCHR);
   end Read_Char;

   function Is_Transmit_Ready (Self : USART_Controller_Base'Class)
      return Boolean is
   begin
      return Self.Peripheral.CSR.TXRDY;
   end Is_Transmit_Ready;

   function Is_Receive_Ready (Self : USART_Controller_Base'Class)
      return Boolean is
   begin
      return Self.Peripheral.CSR.RXRDY;
   end Is_Receive_Ready;

end A0B.ATSAM3X8E.USART;