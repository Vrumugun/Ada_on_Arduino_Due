with A0B.ATSAM3X8E.PIO;
with A0B.ATSAM3X8E.PIO.PIOD;
with COM.Debug;
with A0B.Types;

package body SAPL.Input is

   use type A0B.Types.SVD.UInt32;

   Input_Pin : A0B.ATSAM3X8E.PIO.ATSAM3X8E_Pin
     renames A0B.ATSAM3X8E.PIO.PIOD.PD7;

   Input_State : Boolean := False;
   Input_Counter : A0B.Types.SVD.UInt32 := 0;
   Max_Input_Counter : constant A0B.Types.SVD.UInt32 := 100;

   procedure Initialize is
   begin
      --  Initialization code for input handling
      Input_Pin.Configure_Input;
   end Initialize;

   procedure Update is
   begin
      --  Update code for input handling
      Filter_Input;
   end Update;

   procedure Filter_Input is
   begin
      --  Code to filter input signals and update Input_State and Input_Counter
      --  Pico.GP4.Set;
      if Input_Pin.Get then
         if not Input_State then
            Input_Counter := Input_Counter + 1;
            if Input_Counter > Max_Input_Counter then
               Input_Counter := 0;
               Input_State := True;

               COM.Debug.Put_Tx_String ("HIGH!" & Character'Val (13) &
                  Character'Val (10));
            end if;
         else
            Input_Counter := 0;
         end if;
      else
         if Input_State then
            Input_Counter := Input_Counter + 1;
            if Input_Counter > Max_Input_Counter then
               Input_Counter := 0;
               Input_State := False;

               COM.Debug.Put_Tx_String ("LOW!" & Character'Val (13) &
                  Character'Val (10));
            end if;
         else
            Input_Counter := 0;
         end if;
      end if;
   end Filter_Input;

   function Get_Input_State return Boolean is
   begin
      return Input_State;
   end Get_Input_State;

end SAPL.Input;