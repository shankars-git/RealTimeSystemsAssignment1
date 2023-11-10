--Cyclic scheduler with a watchdog: 

with Ada.Calendar;
with Ada.Text_IO;

use Ada.Calendar;
use Ada.Text_IO;

-- add packages to use randam number generator


procedure cyclic_wd is
    Message: constant String := "Cyclic scheduler with watchdog";
        -- change/add your declarations here
        d: Duration := 1.0;
	Start_Time: Time := Clock;
        

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
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
		-- add a random delay here
	end f3;
	
	task Watchdog is
	       -- add your task entries for communication 	
	end Watchdog;

	task body Watchdog is
		begin
		loop
                 -- add your task code inside this loop    
		end loop;
	end Watchdog;

	begin

        loop
            -- change/add your code inside this loop     
              f1;
              f2;
              f3;        
        end loop;
end cyclic_wd;

