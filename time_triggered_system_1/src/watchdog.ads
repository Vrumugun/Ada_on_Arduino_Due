with A0B.Callbacks.Generic_Parameterless;

package Watchdog is
   procedure Initialize (timeout_ms : Duration := 1000.0);
   procedure Update;
   package On_Update is
     new A0B.Callbacks.Generic_Parameterless (Update);
end Watchdog;