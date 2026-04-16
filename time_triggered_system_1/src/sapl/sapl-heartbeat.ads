with A0B.Callbacks.Generic_Parameterless;

package SAPL.Heartbeat is
   procedure Initialize;
   procedure Update;
   package On_Update is
     new A0B.Callbacks.Generic_Parameterless (Update);
end SAPL.Heartbeat;