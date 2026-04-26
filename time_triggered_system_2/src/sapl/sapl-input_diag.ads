with A0B.Callbacks.Generic_Parameterless;

package SAPL.Input_Diag is
   procedure Initialize;
   procedure Update;
   
   package On_Update is
     new A0B.Callbacks.Generic_Parameterless (Update);

   function Get_Input_State return Boolean;

end SAPL.Input_Diag;