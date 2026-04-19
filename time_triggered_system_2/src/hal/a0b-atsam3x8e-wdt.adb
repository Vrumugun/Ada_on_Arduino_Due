--
--  Copyright (C) 2026, Simon Kraemer <simon.kraemer@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

package body A0B.ATSAM3X8E.WDT is

   Password : constant A0B.ATSAM3X8E.SVD.SYSC.CR_KEY_Field :=
      A0B.ATSAM3X8E.SVD.SYSC.PASSWD;

   procedure Configure (Self : in out WDT_Controller_Base'Class;
      Reload_Value : Reload_Value_Type) is
   begin
      Self.Peripheral.MR :=
         (WDDIS => False,
         WDV   => A0B.ATSAM3X8E.SVD.SYSC.WDT_MR_WDV_Field (Reload_Value),
         WDD   => A0B.ATSAM3X8E.SVD.SYSC.WDT_MR_WDV_Field (Reload_Value),
         others => <>);
      Self.Configured := True;
   end Configure;

   procedure Configure_Window (Self : in out WDT_Controller_Base'Class;
      Reload_Value : Reload_Value_Type; Delta_Value : Reload_Value_Type) is
   begin
      Self.Peripheral.MR :=
         (WDDIS => False,
         WDV   => A0B.ATSAM3X8E.SVD.SYSC.WDT_MR_WDV_Field (Reload_Value),
         WDD   => A0B.ATSAM3X8E.SVD.SYSC.WDT_MR_WDV_Field (Delta_Value),
         others => <>);
      Self.Configured := True;
   end Configure_Window;

   procedure Disable (Self : in out WDT_Controller_Base'Class) is
   begin
      Self.Peripheral.MR := (WDDIS => True, others => <>);
   end Disable;

   procedure Reload (Self : in out WDT_Controller_Base'Class) is
   begin
      Self.Peripheral.CR := (WDRSTT => True, KEY => Password, others => <>);
   end Reload;

end A0B.ATSAM3X8E.WDT;