with A0B.ATSAM3X8E.WDT;
with COM.Debug;
with SAPL.Processor;

package body SAPL.Watchdog is
   WDT : A0B.ATSAM3X8E.WDT.WDT_Controller renames A0B.ATSAM3X8E.WDT.WDT;

   procedure Initialize (timeout_ms : Duration := 1000.0) is
      Slow_Clock_Frequency : constant Float := 32768.0;
      Max_Reload_Value : constant Integer := 2 ** 12;
      Max_Watchdog_Periode : constant Duration :=
         Duration ((1.0 / (Slow_Clock_Frequency / 128.0)) *
         Float (Max_Reload_Value) * 1000.0);
      Watchdog_Period : Integer := 0;
      Temp : Float;
   begin
      --  The watchdog is enabled by default on the SAM3X8E.
      --  If not reloaded or disabled, it will reset the board
      --  after ~16 seconds.
      --  Configure watchdog or call WDT.Disable instead
      if timeout_ms <= Max_Watchdog_Periode then
         Temp := Float (timeout_ms) / Float (Max_Watchdog_Periode);
         Watchdog_Period := Integer (Temp * Float (Max_Reload_Value) + 0.5);
         if Watchdog_Period >= 1 and then Watchdog_Period <= Max_Reload_Value then
            WDT.Configure (
               A0B.ATSAM3X8E.WDT.Reload_Value_Type (Watchdog_Period - 1)
               );
         else
            COM.Debug.Put_Tx_String ("Watchdog: Invalid reload value: " &
               Watchdog_Period'Image &
               Character'Val (13) & Character'Val (10));
            SAPL.Processor.Fail_Safe (SAPL.Unhandled_Exception);
         end if;
      else
         COM.Debug.Put_Tx_String ("Watchdog: Invalid timeout: " &
            Duration'Image (timeout_ms) &
            Character'Val (13) & Character'Val (10));
         SAPL.Processor.Fail_Safe (SAPL.Unhandled_Exception);
      end if;
   end Initialize;

   procedure Update is
   begin
      WDT.Reload;
   end Update;

end SAPL.Watchdog;