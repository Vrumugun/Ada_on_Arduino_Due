with COM.Cross;
with SAPL.Processor;
with SAPL.Input;
with SAPL.Output;
with COM.Debug;
with A0B.Types.SVD;

package body SAPL.State_Machine is

   use type A0B.Types.SVD.UInt32;
   use type SAPL.Processor.Cpu_Id;

   Rx_Cross_Comm_Timer : Natural := 0;
   Rx_Cross_Comm_Timeout : constant Natural := 5;

   Input_Cross_Compare_Timer : Natural := 0;
   Input_Cross_Compare_Timeout : constant Natural := 10;

   Output_Cross_Compare_Timer : Natural := 0;
   Output_Cross_Compare_Timeout : constant Natural := 10;

   Cross_Comm_Message_Length : constant Natural := 1;

   Peer_Cpu_Id : SAPL.Processor.Cpu_Id := SAPL.Processor.Cpu_Unknown;
   Peer_Input_State : Boolean := False;

   Output_Control : Boolean := False;
   Peer_Output_Control : Boolean := False;

   Rx_Message_Count : Natural := 0;
   Tx_Message_Count : Natural := 0;
   Tx_Toggle_Bit     : Boolean := False;

   Last_Rx_Message : String (1 .. Cross_Comm_Message_Length);

   State : State_Type := State_Wait_For_Peer;

   Print_Messages: constant Boolean := False;

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
      C          : Character;
      D          : A0B.Types.SVD.UInt32;
      Parity     : A0B.Types.SVD.UInt32;
   begin
      --  Byte layout:
      --  bit 0   : always 1 (sync marker)
      --  bit 1   : toggle bit (flips each message)
      --  bits 2-3: CPU ID (01=Top, 10=Bottom)
      --  bit 4   : input state
      --  bit 5   : output control
      --  bit 6   : reserved (0)
      --  bit 7   : even parity over bits 0-6
      D :=
         1
         or (if Tx_Toggle_Bit
             then A0B.Types.SVD.UInt32 (2) else A0B.Types.SVD.UInt32 (0))
         or (if SAPL.Processor.Get_Cpu_Id = SAPL.Processor.Cpu_Top
             then A0B.Types.SVD.UInt32 (4) else A0B.Types.SVD.UInt32 (8))
         or (if SAPL.Input.Get_Input_State
             then A0B.Types.SVD.UInt32 (16) else A0B.Types.SVD.UInt32 (0))
         or (if Output_Control
             then A0B.Types.SVD.UInt32 (32) else A0B.Types.SVD.UInt32 (0));

      --  Compute even parity over bits 0-6
      Parity := (D and 1) xor ((D / 2) and 1) xor ((D / 4) and 1)
                xor ((D / 8) and 1) xor ((D / 16) and 1)
                xor ((D / 32) and 1) xor ((D / 64) and 1);
      D := D or (Parity * 128);

      Tx_Toggle_Bit := not Tx_Toggle_Bit;
      Tx_Message (1) := Character'Val (D);

      COM.Cross.Put_Tx_String (Tx_Message);
      Tx_Message_Count := Tx_Message_Count + 1;

      if Print_Messages then
         COM.Debug.Put_Tx_String ("Last Tx Message: ");
         for I in Tx_Message'Range loop
            COM.Debug.Put_Tx_String
               (Integer'Image (Character'Pos (Tx_Message (I))) & " ");
         end loop;
         COM.Debug.Put_Tx_String (Character'Val (13) & Character'Val (10));
      end if;

      --  Receive: every byte with bit 0 = 1 is a complete message
      while COM.Cross.Is_Rx_Character_Available loop
         C := COM.Cross.Get_Next_Rx_Character;
         if (A0B.Types.SVD.UInt32 (Character'Pos (C)) and 1) = 1 then
            Last_Rx_Message (1) := C;
            Rx_Message_Count := Rx_Message_Count + 1;
            Process_Rx_Cross_Comm_Message (Last_Rx_Message);
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
      B      : constant A0B.Types.SVD.UInt32 :=
         A0B.Types.SVD.UInt32 (Character'Pos (Message (1)));
      Parity : A0B.Types.SVD.UInt32;
   begin
      --  Verify even parity over bits 0-6
      Parity := (B and 1) xor ((B / 2) and 1) xor ((B / 4) and 1)
                xor ((B / 8) and 1) xor ((B / 16) and 1)
                xor ((B / 32) and 1) xor ((B / 64) and 1);
      if Parity /= ((B / 128) and 1) then
         return;  --  Parity error: discard message
      end if;

      --  Decode fields
      declare
         Rx_Cpu_Bits : constant A0B.Types.SVD.UInt32 := (B / 4) and 3;
      begin
         if Rx_Cpu_Bits = 1 then
            Peer_Cpu_Id := SAPL.Processor.Cpu_Top;
         elsif Rx_Cpu_Bits = 2 then
            Peer_Cpu_Id := SAPL.Processor.Cpu_Bottom;
         else
            Peer_Cpu_Id := SAPL.Processor.Cpu_Unknown;
         end if;

         Peer_Input_State    := (B and 16) /= 0;
         Peer_Output_Control := (B and 32) /= 0;

         Rx_Cross_Comm_Timer := 0;  --  Reset timeout on valid message
      end;

      if Print_Messages then
         COM.Debug.Put_Tx_String ("Last Rx Message: ");
         COM.Debug.Put_Tx_String (Integer'Image (Character'Pos (Message (1))));
         COM.Debug.Put_Tx_String (Character'Val (13) & Character'Val (10));
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