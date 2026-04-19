with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOA;
with A0B.ATSAM3X8E.PIO.PIOB;
with A0B.ATSAM3X8E.PIO.PIOC;
with A0B.ATSAM3X8E.PIO.PIOD;
with A0B.ATSAM3X8E.SVD.PMC;
with A0B.ARMv7M;
with A0B.ARMv7M.Instructions;
with COM.Debug;

package body SAPL.Processor is
   Local_Cpu_Id : Cpu_Id := Cpu_Unknown;

   LED_TX   : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOA.PA21;
   CPU_ID_Pin : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOD.PD8;

   procedure Initialize is
   begin
      --  Enable peripheral clocks for:
      --  - UART (PID8)
      --  - USART0 (PID17)
      --  - PIOA (PID11)
      --  - PIOD (PID14)
      A0B.ATSAM3X8E.SVD.PMC.PMC_Periph.PMC_PCER0 :=
         (Reserved_0_7 => 0,
         PID          => (As_Array => True,
         Arr      => (8 => True, 11 => True, 14 => True, 17 => True, others => False)));

      Read_Cpu_Id;
      LED_TX.Configure_Output;
      LED_TX.Set (True);
   end Initialize;

   procedure Fail_Safe (Error_Code : Fail_Safe_Error_Codes) is
   begin
      Disable_Interrupts;
      LED_TX.Set (False);
      COM.Debug.Put_Tx_String ("Fail Safe!" & Error_Code'Image &
         Character'Val (13) & Character'Val (10));
      loop
         --  for debugging purposes, print the fail safe message.
         COM.Debug.Update;
      end loop;
   end Fail_Safe;

   procedure Disable_Interrupts is
   begin
      A0B.ARMv7M.Instructions.Disable_Interrupts;
   end Disable_Interrupts;

   procedure Enable_Interrupts is
   begin
      A0B.ARMv7M.Instructions.Enable_Interrupts;
   end Enable_Interrupts;

   procedure Wait_For_Interrupt is
   begin
      A0B.ARMv7M.Instructions.Wait_For_Interrupt;
   end Wait_For_Interrupt;

   function Get_Cpu_Id return Cpu_Id is
   begin
      return Local_Cpu_Id;
   end Get_Cpu_Id;

   procedure Read_Cpu_Id is
   begin
      CPU_ID_Pin.Configure_Input;
      if CPU_ID_Pin.Get = True then
         Local_Cpu_Id := Cpu_Top;
         COM.Debug.Put_Tx_String ("CPU TOP" & Character'Val (13) &
            Character'Val (10));
      else
         Local_Cpu_Id := Cpu_Bottom;
         COM.Debug.Put_Tx_String ("CPU BOTTOM" & Character'Val (13) &
            Character'Val (10));
      end if;
   end Read_Cpu_Id;

end SAPL.Processor;