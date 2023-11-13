with Ada.Calendar;
with Ada.Text_IO;
use Ada.Calendar;
use Ada.Text_IO;

procedure cyclic is
    Message        : constant String   := "Cyclic scheduler";
    -- change/add your declarations here
    Half_Second    : constant Duration := 0.5;
    Start_Time     : Time              := Clock;
    Cycle_End_Time : Time;

    procedure f1 is
        Message : constant String := "f1 executing, time is now";
    begin
        Put (Message);
        Put_Line (Duration'Image (Clock - Start_Time));
    end f1;

    procedure f2 is
        Message : constant String := "f2 executing, time is now";
    begin
        Put (Message);
        Put_Line (Duration'Image (Clock - Start_Time));
    end f2;

    procedure f3 is
        Message : constant String := "f3 executing, time is now";
    begin
        Put (Message);
        Put_Line (Duration'Image (Clock - Start_Time));
    end f3;

begin
    Cycle_End_Time := Clock;
    loop
        -- add one second from previous cycle end/start to get next cycle end/start
        Cycle_End_Time := Cycle_End_Time + (2 * Half_Second);
        f1;
        f2;
        -- half a second from beginning of cycle is the same as half a second to the end as the cycle is 1 sec
        delay until Cycle_End_Time - Half_Second;
        f3;
        -- delay until one second from the end of the previous cycle
        delay until Cycle_End_Time;
    end loop;
end cyclic;
