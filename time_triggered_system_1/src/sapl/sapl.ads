with A0B.Types.SVD;

package SAPL is

   type Fail_Safe_Error_Codes is
      (
         None,
         Watchdog_Expired,
         Tick_Overflow,
         Data_Corruption
      );

   function Verify_Duplicate_Variable
      (Value, Value_Duplicate : A0B.Types.SVD.UInt32) return Boolean;

end SAPL;