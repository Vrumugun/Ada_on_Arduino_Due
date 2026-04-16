package body SAPL is
   use type A0B.Types.SVD.UInt32;

   function Verify_Duplicate_Variable
      (Value, Value_Duplicate : A0B.Types.SVD.UInt32) return Boolean is
      Temp : A0B.Types.SVD.UInt32 := Value_Duplicate xor (2 ** 32 - 1);
   begin
      return Value = Temp;
   end Verify_Duplicate_Variable;

end SAPL;