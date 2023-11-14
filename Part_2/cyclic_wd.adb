--Cyclic scheduler with a watchdog:

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Float_Random;

use Ada.Calendar;
use Ada.Text_IO;
use Ada.Numerics.Float_Random;

-- add packages to use randam number generator

procedure cyclic_wd is
    Message              : constant String := "Cyclic scheduler with watchdog";
    -- change/add your declarations here
    RanGen               : Generator;
    d                    : Duration          := 1.0;
    Start_Time           : Time              := Clock;
    Execution_Start_Time : Time;
    Half_Sec_Duration    : Duration          := 0.5;
    End_Time             : Time;
    F3TaskDeadline       : constant Duration := 0.5;
    Wdg_Start_Time       : Time;

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
        Random_Generated_Delay : Duration;
    begin
        Put (Message);
        Put_Line (Duration'Image (Clock - Start_Time));
        Reset (RanGen);
        Random_Generated_Delay := Duration (Float (Random (RanGen)));
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
                    Put_Line
                       ("Watchdog: f3 finished, in " &
                        Duration'Image (Clock - Wdg_Start_Time));
                end Stop_wdg;
            or
                delay until Clock + 0.5;
                Put_Line
                   ("Watchdog: Timeout for Procedure f3, it is exceeding the deadline");
                accept Stop_wdg do
                    Put_Line
                       ("Watchdog: f3 finished, in " &
                        Duration'Image (Clock - Wdg_Start_Time));
                end Stop_wdg;
            end select;
        end loop;
    end Watchdog;

begin
    Execution_Start_Time := Clock;
    -- intialize end time to start of theoretical end of last cycle so initial addition doesn't delay start by a second
    End_Time             := Execution_Start_Time;
    loop
        -- end of this cycle/start of next should be a frequncy of 1 second every iteration after Execution_Start_Time
        End_Time := End_Time + (2 * Half_Sec_Duration);
        f1;
        f2;
        -- as cycle is 1 second, .5 seconds after start is the same as .5 seconds before end
        delay until End_Time - Half_Sec_Duration;
        -- Start Watchdog
        Watchdog.Start_Wdg;
        f3;
        -- Stop watchdog
        Watchdog.Stop_wdg;
        -- if f3 has overrun the end time
        if Clock > End_Time then
            loop
                -- add seconds until the end time is after the current time
                End_Time := End_Time + (2 * Half_Sec_Duration);
                exit when Clock < End_Time;
            end loop;
        end if;
        delay until End_Time;

    end loop;
end cyclic_wd;
