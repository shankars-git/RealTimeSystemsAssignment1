--Process commnication: Ada lab part 3

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Float_Random;
use Ada.Calendar;
use Ada.Text_IO;
use Ada.Numerics.Float_Random;

procedure comm1 is
    Message : constant String := "Process communication";
    RanGen  : Generator;

    task buffer is
        entry Enqueue (Int : Integer);
        entry Dequeue (Int : out Integer);
        entry Finish;
    end buffer;

    task producer is
        entry Finish;
    end producer;

    task consumer;

    task body buffer is
        Message            : constant String := "buffer executing";
        Data               : array (0 .. 20) of Integer;
        Front, Rear, Count : Natural         := 0;
        Finished           : Boolean         := False;
    begin
        Put_Line (Message);

        while not Finished loop

            select when Count < Data'Length =>
                accept Enqueue (Int : Integer) do
                    Data (Rear) := Int;
                    Rear        := (Rear mod Data'Length) + 1;
                    Count       := Count + 1;
                end Enqueue;

            or when Count > 0 =>
                accept Dequeue (Int : out Integer) do
                    Int   := Data (Front);
                    Front := (Front mod Data'Length) + 1;
                    Count := Count - 1;
                end Dequeue;

            or
                accept Finish do
                    Finished := True;
                end Finish;

            end select;

        end loop;
    end buffer;

    task body producer is
        Message   : constant String := "producer executing";
        Next      : Integer         := 0;
        Finished  : Boolean         := False;
        DelayTime : Duration;
    begin
        Put_Line (Message);
        Reset (RanGen);

        while Next <= 20 and not Finished loop
            DelayTime := Duration (Float (Random (RanGen)));
            select
                accept Finish do
                    Finished := True;
                end Finish;
            or
                delay until Clock + DelayTime;
            end select;

            buffer.Enqueue (Next);
            Put_Line ("producer queued:" & Integer'Image (Next));
            Next := Next + 1;
        end loop;
    end producer;

    task body consumer is
        Message   : constant String := "consumer executing";
        Sum       : Integer         := 0;
        Int       : Integer;
        DelayTime : Duration;
    begin
        Put_Line (Message);
        Reset (RanGen);

        Main_Cycle :
        while Sum <= 100 loop
            buffer.Dequeue (Int);
            Sum := Sum + Int;
            Put_Line
               ("consumer dequeued:" & Integer'Image (Int) & " Sum:" &
                Integer'Image (Sum));
            DelayTime := Duration (Float (Random (RanGen)));
            delay until Clock + DelayTime;
        end loop Main_Cycle;

        buffer.Finish;
        producer.Finish;

    exception
        when Tasking_Error =>
            Put_Line ("buffer finished before producer");
            Put_Line ("ending the consumer");
    end consumer;
begin
    Put_Line (Message);
end comm1;
