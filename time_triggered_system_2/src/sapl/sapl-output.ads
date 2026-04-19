with A0B.Callbacks.Generic_Parameterless;

package SAPL.Output is

   procedure Initialize;
   procedure Update;
   procedure Set_Output_State (State : Boolean);
   function Get_Output_State return Boolean;

   package On_Update is
     new A0B.Callbacks.Generic_Parameterless (Update);

private
   procedure Control_Output;
   procedure Verify_Output_State;

end SAPL.Output;