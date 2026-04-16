with A0B.ATSAM3X8E.WDT;

package body Watchdog is
   WDT : A0B.ATSAM3X8E.WDT.WDT_Controller renames A0B.ATSAM3X8E.WDT.WDT;

   procedure Initialize (timeout_ms : Duration := 1000.0) is
   begin
      --  The watchdog is enabled by default on the SAM3X8E.
      --  If not reloaded or disabled, it will reset the board
      --  after ~16 seconds.
      --  Configure watchdog or call WDT.Disable instead
      WDT.Configure (16#FFF#);
   end Initialize;

   procedure Update is
   begin
      WDT.Reload;
   end Update;

end Watchdog;