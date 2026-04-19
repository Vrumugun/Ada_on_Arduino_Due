with A0B.Callbacks.Generic_Parameterless;

package SAPL.Input is

   procedure Initialize;
   procedure Update;

   function Get_Input_State return Boolean;

   package On_Update is
     new A0B.Callbacks.Generic_Parameterless (Update);

private
   procedure Filter_Input;

end SAPL.Input;