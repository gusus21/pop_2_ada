with Ada.Text_IO;
use Ada.Text_IO;

procedure Main is

   length : Integer := 1000000;
   arr : array(1..length) of Integer;
   thread_amount : constant Integer := 3;
   min_idx : Integer;

   procedure array_init is

   begin
      for i in 1..length loop
         arr(i) := i;
      end loop;
      arr(length/4) := -5;
   end array_init;

   function part_min(start_idx, end_idx: in Integer) return Integer is
      min : Integer := start_idx;
   begin
      for i in start_idx..end_idx loop
         if arr(i) < arr(min) then
            min := i;
           end if;
      end loop;

      return min;
   end part_min;

   task type working_thread is
      entry Start(start_idx, end_idx: in Integer);
   end working_thread;

   protected monitor is
      procedure set_part_min(min:in Integer);
      entry get_min(min : out Integer);
   private
      task_count : Integer := 0;
      current_minimum : Integer:=1;
   end monitor;

   protected body monitor is
      procedure set_part_min(min : in Integer) is
      begin
         if arr(current_minimum) > arr(min) then
            current_minimum := min;
         end if;
         task_count := task_count +1;
      end set_part_min;

      entry get_min(min : out Integer) when task_count = thread_amount is
      begin
         min := current_minimum;
         end get_min;
      end monitor;

   task body working_thread is
      min :Integer;
      start_idx, end_idx : Integer;
   begin
      accept Start (start_idx : in Integer; end_idx : in Integer) do
         working_thread.start_idx := start_idx;
         working_thread.end_idx := end_idx;
      end Start;
      min := part_min(start_idx, end_idx);
      monitor.set_part_min(min);
   end working_thread;

   function get_min_parallel return Integer is
      min : Integer;
      threads : array(1..thread_amount) of working_thread;
   begin
      for i in 1..thread_amount loop
         threads(i).Start(start_idx => (i-1)*length/thread_amount+1,
                          end_idx => i*length/thread_amount);
      end loop;

      monitor.get_min(min);
      return min;
      end get_min_parallel;

begin
   array_init;
   --Put_Line(arr(part_min(1, length))'img);
   min_idx := get_min_parallel;
   Put_Line("The minimal number "&arr(min_idx)'img&" in index"&min_idx'img);
end Main;
