with A0B.Callbacks.Generic_Parameterless;

package SAPL.State_Machine is

   type State_Type is (State_Wait_For_Peer, State_Output_On,
      State_Output_Off, State_Error);

   procedure Initialize;
   procedure Update;
   procedure Cycle;
   procedure Set_State (New_State : State_Type);
   procedure Enter_State (New_State : State_Type);
   procedure Exit_State (Old_State : State_Type);
   function Get_State return State_Type;
   function Check_Valid_State_Transition
      (Current_State, New_State : State_Type) return Boolean;

   procedure Update_Cross_Comm;
   procedure Process_Rx_Cross_Comm_Message (Message : String);

   procedure Check_Cross_Comm_Timeout;
   procedure Cross_Compare_Inputs;
   procedure Control_Output;
   procedure Cross_Compare_Outputs;

   function Get_Rx_Message_Count return Natural;
   function Get_Tx_Message_Count return Natural;
   function Get_Last_Rx_Message return String;

   package On_Update is
     new A0B.Callbacks.Generic_Parameterless (Update);

end SAPL.State_Machine;