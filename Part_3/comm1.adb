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

    type BufferArray is array (0 .. 9) of Integer;

    -- The buffer task is responsible for managing access to the FIFO queue.
    -- Accepts Enqueue and Dequeue for adding or removing integers from the
    -- buffer, and accepts Finish to end its execution loop.
    task buffer is
        entry Enqueue (Int : in Integer);
        entry Dequeue (Int : out Integer);
        entry Finish;
    end buffer;

    -- The producer task adds integers from 0 - 20 to the buffer with random
    -- pauses between.
    -- Accepts Finish to end its execution early.
    task producer is
        entry Finish;
    end producer;

    -- The consumer task will take integers from the buffer at irregular
    -- intervals and sum them. Once the sum is over 100, it will send finish
    -- signals to both the buffer and producer to terminate the program.
    task consumer;

    -- Will continously accept Enqueue or Dequeue until it receives a Finish
    -- signal.
    task body buffer is
        Message            : constant String := "buffer executing";
        Data               : BufferArray;
        Front, Rear, Count : Natural         := 0;
        Finished           : Boolean         := False;
    begin
        Put_Line (Message);

        while not Finished loop

            select when Count < Data'Length =>
                accept Enqueue (Int : in Integer) do
                    Data (Rear) := Int;
                    Rear        := (Rear + 1) mod Data'Length;
                    Count       := Count + 1;
                end Enqueue;

            or when Count > 0 =>
                accept Dequeue (Int : out Integer) do
                    Int   := Data (Front);
                    Front := (Front + 1) mod Data'Length;
                    Count := Count - 1;
                end Dequeue;

            or
                accept Finish do
                    Finished := True;
                end Finish;

            end select;

        end loop;
        Put_Line ("Buffer finished");
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
                -- This entry makes it possible to end the producer's
                -- execution early.
                accept Finish do
                    Finished := True;
                end Finish;
            or
                delay until Clock + DelayTime;
            end select;

            Put_Line ("producer queueing:" & Integer'Image (Next));

            buffer.Enqueue (Next);
            Next := Next + 1;

        end loop;
        Put_Line ("Producer finished");
    end producer;

    task body consumer is
        Message   : constant String := "consumer executing";
        Sum       : Integer         := 0;
        Int       : Integer;
        DelayTime : Duration;
    begin
        Put_Line (Message);
        Reset (RanGen);

        while Sum <= 100 loop
            buffer.Dequeue (Int);
            Sum := Sum + Int;

            Put_Line
               ("consumer dequeued:" & Integer'Image (Int) & " Sum:" &
                Integer'Image (Sum));

            DelayTime := Duration (Float (Random (RanGen)));
            delay until Clock + DelayTime;
        end loop;

        -- The consumer needs to send signals to the other processes to ensure
        -- that they end their execution too and the program can terminate.
        producer.Finish;
        buffer.Finish;

        Put_Line ("Consumer finished");

    exception
        when Tasking_Error =>
            Put_Line ("Tasking Error");
    end consumer;

begin
    Put_Line (Message);
end comm1;
