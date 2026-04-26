with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOA;

package body SAPL.Output is
   Output_Pin : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOA.PA28;

   Output_State : Boolean := False;

   procedure Initialize is
   begin
      Output_Pin.Configure_Output;
      Output_Pin.Set (False);
   end Initialize;

   procedure Update is
   begin
      Control_Output;
      Verify_Output_State;
   end Update;

   procedure Set_Output_State (State : Boolean) is
   begin
      Output_State := State;
   end Set_Output_State;

   function Get_Output_State return Boolean is
   begin
      return Output_State;
   end Get_Output_State;

   procedure Control_Output is
   begin
      if Output_State then
         Output_Pin.Set (True);
      else
         Output_Pin.Set (False); 
      end if;
   end Control_Output;

   procedure Verify_Output_State is
   begin
      --  Code to verify that output pin is in expected state and handle errors
      null;
   end Verify_Output_State;

end SAPL.Output;