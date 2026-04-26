with A0B.Types.SVD;

package SAPL is

   type Fail_Safe_Error_Codes is
      (
         None,
         Watchdog_Expired,
         Invalid_Tick_Rate,
         Tick_Overflow,
         Data_Corruption,
         Output_Error,
         Unknown_Cpu,
         Cross_Comm_Error,
         Unhandled_Exception,
         Input_Error
      );

   function Verify_Duplicate_Variable
      (Value, Value_Duplicate : A0B.Types.SVD.UInt32) return Boolean;

end SAPL;