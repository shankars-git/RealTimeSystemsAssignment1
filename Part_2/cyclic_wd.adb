--Cyclic scheduler with a watchdog: 

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Float_Random;

use Ada.Calendar;
use Ada.Text_IO;
Use Ada.Numerics.Float_Random;

-- add packages to use randam number generator


procedure cyclic_wd is
    Message: constant String := "Cyclic scheduler with watchdog";
    -- change/add your declarations here
    RanGen : Generator;
    d: Duration := 1.0;
	IsF3: Boolean := False; -- Flag to control f3 execution
	Start_Time: Time;
	End_Time : Time;
	F3TaskDeadline: constant Duration := 0.5;
    Wdg_Start_Time: Time;

	procedure f1 is 
		Message: constant String := "f1 executing, time is now";
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
	end f1;

	procedure f2 is 
		Message: constant String := "f2 executing, time is now";
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
	end f2;

	procedure f3 is 
		Message: constant String := "f3 executing, time is now";
		Random_Generated_Delay: Duration;
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
		Reset (RanGen);
		Random_Generated_Delay := Duration(Float(Random(RanGen)));
        delay until Clock + Random_Generated_Delay;
	end f3;
	
	task Watchdog is
	    -- add your task entries for communication 	
        entry Start_Wdg;
		entry Stop_wdg;
	end Watchdog;

  task body Watchdog is
    begin
        loop
				accept Start_Wdg;
				Wdg_Start_Time := Clock;
				select
					accept Stop_wdg do
						Put_Line("Watchdog: f3 finished, in " & Duration'Image(Clock - Wdg_Start_Time));
					end Stop_wdg;
			or
				delay until Clock + 0.5;
				Put_Line("Watchdog: Timeout for Procedure f3, it is exceeding the deadline");
				accept Stop_wdg do
						Put_Line("Watchdog: f3 finished, in " & Duration'Image(Clock - Wdg_Start_Time));
				end Stop_wdg;
			end select;
        end loop;
    end Watchdog;

	begin
        loop
			Start_Time := Clock;
			End_Time := Clock +d;   
              f1;
              f2;
			  delay until Start_Time + 0.5;
			  -- Start Watchdog
			  if IsF3 then
			  		Watchdog.Start_Wdg;
					f3;
					Watchdog.Stop_wdg;
					IsF3 := False;
				else
					IsF3 := True;
				end if;        
			if Clock > End_Time then
						loop
							End_Time := End_Time + d;
							exit when CLock < End_Time;
						end loop;
					end if;
			delay until End_Time;       
		 end loop;
end cyclic_wd;

