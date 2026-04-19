--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  Implementation of the Monotonic Time Clock and Timer on top of SysTick.
--
--  This package exports SysTick_Handler symbol to install exception handler.

with A0B.Time;
with A0B.Types;
with A0B.Callbacks;

package HAL.SysTick_Clock_Timer is

   use type A0B.Types.Unsigned_32;

   procedure Initialize
     (Use_Processor_Clock : Boolean;
      Clock_Frequency     : A0B.Types.Unsigned_32;
      Tick_Frequency      : A0B.Types.Unsigned_32 := 1_000)
      with Pre =>
        Clock_Frequency mod 1_000_000 = 0
          and then Clock_Frequency <= 2**20 * 1_000;
   --  Initialize SysTick timer

   function Clock return A0B.Time.Monotonic_Time;
   --  Return current monotonic time

   procedure Set_Tick_Callback (Callback : A0B.Callbacks.Callback);

end HAL.SysTick_Clock_Timer;
