with A0B.Callbacks.Generic_Parameterless;

package COM.Debug is
   procedure Initialize;
   procedure Update;
   procedure Configure_UART_Pins;

   function Is_Rx_Character_Available return Boolean;
   function Get_Next_Rx_Character return Character;
   procedure Put_Tx_Character (C : Character);
   procedure Put_Tx_String (S : String);

   package On_Update is
     new A0B.Callbacks.Generic_Parameterless (Update);

private
   procedure Receive_Character;
   procedure Transmit_Character;

   Buffer_Size : constant Natural := 1024;
   type Circular_Buffer_Array is array (0 .. Buffer_Size - 1) of Character;

   type Circular_Buffer_Character is tagged record
      Head : Natural := 0;
      Tail : Natural := Buffer_Size - 1;
      Data : Circular_Buffer_Array;
   end record;

   procedure Put_Character (Self : in out Circular_Buffer_Character;
      C : Character);
   function Get_Character (Self : in out Circular_Buffer_Character)
      return Character;
   function Is_Buffer_Empty (Self : in out Circular_Buffer_Character)
      return Boolean;
   function Is_Buffer_Full (Self : in out Circular_Buffer_Character)
      return Boolean;

end COM.Debug;