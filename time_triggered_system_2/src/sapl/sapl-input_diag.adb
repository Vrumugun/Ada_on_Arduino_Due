with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOC;
with COM.Debug;
with SAPL.Processor;
with SAPL.Input;

package body SAPL.Input_Diag is

   use type A0B.Types.SVD.UInt32;

   Input_Diag_Pin : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOC.PC21;

   type Input_Diag_State_Type is (Idle, Waiting_For_Input_Low, Restore, Error);
   Input_Diag_State : Input_Diag_State_Type := Idle;
   Input_Diag_Timer : A0B.Types.SVD.UInt32 := 0;
   Input_State : Boolean := False;
   Input_Diag_Max_Timer : constant A0B.Types.SVD.UInt32 := 100;
   Input_Diag_Cycle_Time : constant A0B.Types.SVD.UInt32 := 500;

   procedure Initialize is
   begin
      Input_Diag_Pin.Configure_Output;
      Input_Diag_Pin.Set (True);
   end Initialize;

   procedure Update is
   begin
      case Input_Diag_State is
         when Idle =>
            Input_State := SAPL.Input.Get_Input_State;
            Input_Diag_Pin.Set (True);
            Input_Diag_Timer := Input_Diag_Timer + 1;
            if Input_Diag_Timer > Input_Diag_Cycle_Time then
               Input_Diag_Timer := 0;
               if Input_State then
                  COM.Debug.Put_Tx_String ("Input diag" &
                     Character'Val (13) & Character'Val (10));
                  Input_Diag_State := Waiting_For_Input_Low;
               end if;
            end if;
         when Waiting_For_Input_Low =>
            Input_Diag_Pin.Set (False);
            Input_Diag_Timer := Input_Diag_Timer + 1;
            --  read the physical input pin to check if diag was successful
            if not SAPL.Input.Get_Input_State then
               COM.Debug.Put_Tx_String ("Passed" &
                  Character'Val (13) & Character'Val (10));
               Input_Diag_Timer := 0;
               Input_Diag_State := Restore;
            elsif Input_Diag_Timer > Input_Diag_Max_Timer then
               COM.Debug.Put_Tx_String ("Failed" &
                  Character'Val (13) & Character'Val (10));
               Input_Diag_State := Error;
               Input_Diag_Timer := 0;
            end if;
         when Restore =>
            Input_Diag_Pin.Set (True);
            Input_Diag_Timer := Input_Diag_Timer + 1;
            if Input_Diag_Timer > Input_Diag_Max_Timer then
               Input_Diag_Timer := 0;
               Input_Diag_State := Idle;
            end if;
         when Error =>
            Input_State := False;
            Input_Diag_Pin.Set (False);
            --  Remain in error state until reset
            SAPL.Processor.Fail_Safe (SAPL.Input_Error);
      end case;
   end Update;

   function Get_Input_State return Boolean is
   begin
      return Input_State;
   end Get_Input_State;

end SAPL.Input_Diag;