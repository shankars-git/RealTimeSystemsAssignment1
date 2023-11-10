--Protected types: Ada lab part 4

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure comm2 is
    Message: constant String := "Protected Object";
    	type BufferArray is array (0 .. 9) of Integer;
        -- protected object declaration
	protected  buffer is
            -- add entries of protected object here 
	private
            -- add local declarations
	end buffer;

	task producer is
		-- add task entries
	end producer;

	task consumer is
                -- add task entries
	end consumer;

	protected body buffer is 
              -- add definitions of protected entries here 
	end buffer;

        task body producer is 
		Message: constant String := "producer executing";
                -- add local declrations of task here  
	begin
		Put_Line(Message);
		loop
                -- add your task code inside this loop     
		end loop;
	end producer;

	task body consumer is 
		Message: constant String := "consumer executing";
                -- add local declrations of task here 
	begin
		Put_Line(Message);
		Main_Cycle:
		loop 
                -- add your task code inside this loop   
		end loop Main_Cycle; 

                -- add your code to stop executions of other tasks     
		Put_Line("Ending the consumer");
	end consumer;

begin
Put_Line(Message);
end comm2;
