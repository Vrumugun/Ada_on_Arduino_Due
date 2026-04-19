with COM.Cross;
with SAPL.Processor;
with SAPL.Input;
with SAPL.Output;
with COM.Debug;
with A0B.Types.SVD;

package body SAPL.State_Machine is

   use type A0B.Types.SVD.UInt32;
   use type SAPL.Processor.Cpu_Id;

   Rx_Count : Natural := 0;
   Rx_Cross_Comm_Timer : Natural := 0;
   Rx_Cross_Comm_Timeout : constant Natural := 100;

   Input_Cross_Compare_Timer : Natural := 0;
   Input_Cross_Compare_Timeout : constant Natural := 100;

   Output_Cross_Compare_Timer : Natural := 0;
   Output_Cross_Compare_Timeout : constant Natural := 100;

   Cross_Comm_Message_Length : constant Natural := 5;

   Start_Header : constant Character := Character'Val (16#A5#);

   Peer_Cpu_Id : SAPL.Processor.Cpu_Id := SAPL.Processor.Cpu_Unknown;
   Peer_Input_State : Boolean := False;

   Output_Control : Boolean := False;
   Peer_Output_Control : Boolean := False;

   Rx_Message_Count : Natural := 0;
   Tx_Message_Count : Natural := 0;

   Last_Rx_Message : String (1 .. Cross_Comm_Message_Length);

   State : State_Type := State_Wait_For_Peer;

   Print_Messages: Boolean := False;

   procedure Initialize is
   begin
      --  Initialize state machine variables and states here
      null;
   end Initialize;

   procedure Update is
   begin
      Update_Cross_Comm;
      Cycle;
      Control_Output;
   end Update;

   procedure Cycle is
   begin
      --  Implement state machine logic here
      case State is
         when State_Wait_For_Peer =>
            if Peer_Cpu_Id /= SAPL.Processor.Cpu_Unknown then
               Set_State (State_Output_Off);
            end if;
         when State_Output_Off =>
            Output_Control := False;
            Check_Cross_Comm_Timeout;
            Cross_Compare_Inputs;
            Cross_Compare_Outputs;
            if Peer_Input_State and then SAPL.Input.Get_Input_State then
               Set_State (State_Output_On);
            end if;
         when State_Output_On =>
            Output_Control := True;
            Check_Cross_Comm_Timeout;
            Cross_Compare_Inputs;
            Cross_Compare_Outputs;
            if not Peer_Input_State or else not SAPL.Input.Get_Input_State then
               Set_State (State_Output_Off);
            end if;
         when State_Error =>
            null; --  Implement error handling logic here
            Output_Control := False;
      end case;
   end Cycle;

   procedure Set_State (New_State : State_Type) is
   begin
      if New_State /= State then
         if Check_Valid_State_Transition (State, New_State) then
            Exit_State (State);
            Enter_State (New_State);

            COM.Debug.Put_Tx_String ("" & State'Image & " -> " &
               New_State'Image & Character'Val (13) &
               Character'Val (10));

            State := New_State;
         end if;
      end if;
   end Set_State;

   procedure Enter_State (New_State : State_Type) is
   begin
      --  Implement actions to perform when entering a new state here
      null;
   end Enter_State;

   procedure Exit_State (Old_State : State_Type) is
   begin
      --  Implement actions to perform when exiting a state here
      null;
   end Exit_State;

   function Get_State return State_Type is
   begin
      return State;
   end Get_State;

   function Check_Valid_State_Transition
      (Current_State, New_State : State_Type) return Boolean is
   begin
      if Current_State = State_Error then
         return False;
      else
         return True;
      end if;
   end Check_Valid_State_Transition;

   function Calculate_Cross_Comm_CRC (Message : String; Init : Character) return Character is
      use type A0B.Types.SVD.UInt32;
      CRC : A0B.Types.SVD.UInt32 := Character'Pos (Init);
      V : A0B.Types.SVD.UInt32;
   begin
      for C of Message loop
         V := Character'Pos (C);
         CRC := CRC xor V;
      end loop;
      return Character'Val (CRC);
   end Calculate_Cross_Comm_CRC;

   procedure Update_Cross_Comm is
      Tx_Message : String (1 .. Cross_Comm_Message_Length);
      Rx_Message : String (1 .. Cross_Comm_Message_Length);
      C : Character;
   begin
      Tx_Message (1) := Start_Header;
      
      if SAPL.Processor.Get_Cpu_Id = SAPL.Processor.Cpu_Top then
         Tx_Message (2) := Character'Val (1);
      elsif SAPL.Processor.Get_Cpu_Id = SAPL.Processor.Cpu_Bottom then
         Tx_Message (2) := Character'Val (2);
      else
         Tx_Message (2) := Character'Val (0); -- CPU ID
      end if;

      if SAPL.Input.Get_Input_State then
         Tx_Message (3) := Character'Val (1);
      else
         Tx_Message (3) := Character'Val (0);
      end if;

      if Output_Control then
         Tx_Message (4) := Character'Val (1);
      else
         Tx_Message (4) := Character'Val (0);
      end if;

      Tx_Message (5) := Calculate_Cross_Comm_CRC (Tx_Message (1 .. 4), Character'Val (16#A5#)); -- CRC

      COM.Cross.Put_Tx_String (Tx_Message);
      Tx_Message_Count := Tx_Message_Count + 1;

      if Print_Messages then
         COM.Debug.Put_Tx_String ("Last Tx Message: ");
         for I in Tx_Message'Range loop
            COM.Debug.Put_Tx_String (Integer'Image (Character'Pos (Tx_Message (I))) & " ");
         end loop;
         COM.Debug.Put_Tx_String (Character'Val (13) & Character'Val (10)); -- New line for debugging purposes
      end if;

      COM.Cross.Put_Tx_Character (Character'Val (0)); --  Send a null character to indicate end of message for debugging purposes

      while COM.Cross.Is_Rx_Character_Available loop
         C := COM.Cross.Get_Next_Rx_Character;
         if C = Start_Header then
            Rx_Count := 1;
            Rx_Message_Count := Rx_Message_Count + 1;
            Last_Rx_Message := Rx_Message; -- Store the last received message for debugging
         end if;

         if Rx_Count > 0 and then Rx_Count <= Cross_Comm_Message_Length then
            Rx_Message (Rx_Count) := C;
            Rx_Count := Rx_Count + 1;
            if Rx_Count > Cross_Comm_Message_Length then
               --  Process the received message here
               if Print_Messages then
                  COM.Debug.Put_Tx_String ("Last Rx Message: ");
                  for I in Last_Rx_Message'Range loop
                     COM.Debug.Put_Tx_String (Integer'Image (Character'Pos (Last_Rx_Message (I))) & " ");
                  end loop;
                  COM.Debug.Put_Tx_String (Character'Val (13) & Character'Val (10)); -- New line for debugging purposes
               end if;

               Process_Rx_Cross_Comm_Message (Rx_Message);
               Rx_Count := 0;
            end if;
         end if;
      end loop;
   end Update_Cross_Comm;

   procedure Check_Cross_Comm_Timeout is
   begin
      if Rx_Cross_Comm_Timer >= Rx_Cross_Comm_Timeout then
         --  Handle cross-communication timeout here
         Peer_Cpu_Id := SAPL.Processor.Cpu_Unknown;
         Peer_Input_State := False;
         Rx_Cross_Comm_Timer := 0; --  Reset the timer after handling timeout
         SAPL.Processor.Fail_Safe (Cross_Comm_Error);
      else
         Rx_Cross_Comm_Timer := Rx_Cross_Comm_Timer + 1;
      end if;
   end Check_Cross_Comm_Timeout;

   procedure Process_Rx_Cross_Comm_Message (Message : String) is
   begin
      if Message'Length /= Cross_Comm_Message_Length then
         --  Invalid message length, ignore or handle error
         raise Constraint_Error with "Received message with invalid length: " &
            Integer'Image (Message'Length);
      end if;
      if Message'First /= 1 then
         --  Invalid message format, ignore or handle error
         raise Constraint_Error with "Received message with invalid format: " &
            Message;
      end if;
      --  Implement message processing logic here
      if Message (1) = Start_Header then
         --  Extract CPU ID, input state, and CRC from the message
         declare
            Rx_CPU_ID : constant Character := Message (2);
            Rx_Input_State : constant Character := Message (3);
            Rx_Output_Control : constant Character := Message (4);
            Rx_CRC : constant Character := Message (5);
         begin
            if Rx_CRC = Calculate_Cross_Comm_CRC (Message (1 .. 4), Character'Val (16#A5#)) then
               --  Validate CRC and update system state based on rx message
               if Rx_CPU_ID = Character'Val (1) then
                  Peer_Cpu_Id := SAPL.Processor.Cpu_Top;
               elsif Rx_CPU_ID = Character'Val (2) then
                  Peer_Cpu_Id := SAPL.Processor.Cpu_Bottom;
               else
                  Peer_Cpu_Id := SAPL.Processor.Cpu_Unknown;
               end if;

               if Rx_Input_State = Character'Val (1) then
                  Peer_Input_State := True;
               else
                  Peer_Input_State := False;
               end if;

               if Rx_Output_Control = Character'Val (1) then
                  Peer_Output_Control := True;
               else
                  Peer_Output_Control := False;
               end if;

               --  Reset the cross-communication timeout timer
               Rx_Cross_Comm_Timer := 0;
            end if;
         end;
      end if;
   end Process_Rx_Cross_Comm_Message;

   procedure Cross_Compare_Inputs is
   begin
      if Peer_Input_State /= SAPL.Input.Get_Input_State then
         Input_Cross_Compare_Timer := Input_Cross_Compare_Timer + 1;
         if Input_Cross_Compare_Timer >= Input_Cross_Compare_Timeout then
            --  Handle input mismatch timeout here
            COM.Debug.Put_Tx_String ("Input mismatch detected! Peer: " &
               Peer_Input_State'Image & " Local: " &
               SAPL.Input.Get_Input_State'Image & Character'Val (13) &
               Character'Val (10));
            Set_State (State_Error);
         end if;
      else
         --  Reset the timer on successful comparison
         Input_Cross_Compare_Timer := 0;
      end if;
   end Cross_Compare_Inputs;

   procedure Control_Output is
   begin
      if Output_Control then
         SAPL.Output.Set_Output_State (True);
      else
         SAPL.Output.Set_Output_State (False);
      end if;
   end Control_Output;

   procedure Cross_Compare_Outputs is
   begin
      if Peer_Output_Control /= Output_Control then
         Output_Cross_Compare_Timer := Output_Cross_Compare_Timer + 1;
         if Output_Cross_Compare_Timer >= Output_Cross_Compare_Timeout then
            --  Handle output mismatch timeout here
            COM.Debug.Put_Tx_String ("Output mismatch detected! Peer: " &
               Peer_Output_Control'Image & " Local: " &
               Output_Control'Image & Character'Val (13) &
               Character'Val (10));
            Set_State (State_Error);
         end if;
      else
         --  Reset the timer on successful comparison
         Output_Cross_Compare_Timer := 0;
      end if;
   end Cross_Compare_Outputs;

   function Get_Rx_Message_Count return Natural is
   begin
      return Rx_Message_Count;
   end Get_Rx_Message_Count;

   function Get_Tx_Message_Count return Natural is
   begin
      return Tx_Message_Count;
   end Get_Tx_Message_Count;

   function Get_Last_Rx_Message return String is
   begin
      return Last_Rx_Message;
   end Get_Last_Rx_Message;

end SAPL.State_Machine;