--Protected types: Ada lab part 4

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Float_Random;
use Ada.Calendar;
use Ada.Text_IO;
use Ada.Numerics.Float_Random;

procedure comm2 is
    Message : constant String := "Protected Object";
    RanGen  : Generator;

    type BufferArray is array (0 .. 9) of Integer;

    -- A simple FIFO buffer (queue) that only implements Enqueue and Dequeue.
    protected buffer is
        entry Enqueue (Int : in Integer);
        entry Dequeue (Int : out Integer);
    private
        Data               : BufferArray;
        Front, Rear, Count : Natural := 0;
    end buffer;

    -- The producer task adds integers from 0 - 20 to the buffer with random
    -- pauses between.
    -- Accepts Finish to end its execution early.--
    task producer is
        entry Finish;
    end producer;

    -- The consumer task will take integers from the buffer at irregular
    -- intervals and sum them. Once the sum is over 100, it will send finish
    -- signals to both the buffer and producer to terminate the program.
    task consumer;

    protected body buffer is
        entry Enqueue (Int : in Integer) when Count < Data'Length is
        begin
            Data (Rear) := Int;
            Rear        := (Rear + 1) mod Data'Length;
            Count       := Count + 1;
        end Enqueue;

        entry Dequeue (Int : out Integer) when Count > 0 is
        begin
            Int   := Data (Front);
            Front := (Front + 1) mod Data'Length;
            Count := Count - 1;
        end Dequeue;

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

        Put_Line ("Consumer finished");

        -- The consumer needs to send a signal to the producer to end its
        -- execution so that the program terminates.
        producer.Finish;

    end consumer;

begin
    Put_Line (Message);
end comm2;
