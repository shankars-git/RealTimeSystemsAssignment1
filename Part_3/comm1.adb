--Process commnication: Ada lab part 3

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure comm1 is
    Message: constant String := "Process communication";
	task buffer is
            -- add your task entries for communication 
	end buffer;

	task producer is
            -- add your task entries for communication  
	end producer;

	task consumer is
            -- add your task entries for communication 
	end consumer;

	task body buffer is 
		Message: constant String := "buffer executing";
                -- change/add your local declarations here   
	begin
		Put_Line(Message);
		loop
                -- add your task code inside this loop    
		end loop;
	end buffer;

	task body producer is 
		Message: constant String := "producer executing";
                -- change/add your local declarations here
	begin
		Put_Line(Message);
		loop
                -- add your task code inside this loop  
		end loop;
	end producer;

	task body consumer is 
		Message: constant String := "consumer executing";
                -- change/add your local declarations here
	begin
		Put_Line(Message);
		Main_Cycle:
		loop 
                -- add your task code inside this loop 
		end loop Main_Cycle; 

                -- add your code to stop executions of other tasks     
		exception
			  when TASKING_ERROR =>
				  Put_Line("Buffer finished before producer");
		Put_Line("Ending the consumer");
	end consumer;
begin
	Put_Line(Message);
end comm1;
