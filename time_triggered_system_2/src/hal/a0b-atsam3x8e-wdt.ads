--
--  Copyright (C) 2026, Simon Kraemer <simon.kraemer@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

pragma Ada_2022;

with A0B.ATSAM3X8E.SVD.SYSC;

package A0B.ATSAM3X8E.WDT
  with Preelaborate
is
   type Reload_Value_Type is range 0 .. 16#FFF#;

   type WDT_Controller_Base
     (Peripheral : not null access A0B.ATSAM3X8E.SVD.SYSC.WDT_Peripheral)
     is tagged limited
   record
      Configured        : Boolean := False with Volatile;
   end record;

   procedure Configure (Self : in out WDT_Controller_Base'Class;
      Reload_Value : Reload_Value_Type);

   procedure Configure_Window (Self : in out WDT_Controller_Base'Class;
      Reload_Value : Reload_Value_Type; Delta_Value : Reload_Value_Type);

   procedure Disable (Self : in out WDT_Controller_Base'Class);

   procedure Reload (Self : in out WDT_Controller_Base'Class);

   subtype WDT_Controller is
     WDT_Controller_Base
     (Peripheral   => A0B.ATSAM3X8E.SVD.SYSC.WDT_Periph'Access);

   WDT : aliased WDT_Controller;

end A0B.ATSAM3X8E.WDT;