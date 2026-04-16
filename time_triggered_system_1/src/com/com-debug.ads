with A0B.Callbacks.Generic_Parameterless;

package COM.Debug is
   procedure Initialize;
   procedure Update;
   procedure Configure_UART_Pins;
   package On_Update is
     new A0B.Callbacks.Generic_Parameterless (Update);
end COM.Debug;