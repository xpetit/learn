with Ada.Text_IO, Ada.Exceptions, Ada.Tags, Ada.Numerics.Discrete_Random, Ada.Calendar.Formatting;
use  Ada.Text_IO;

procedure Main is
   pragma Assertion_Policy (Check);
begin
   Im_Out : declare
      procedure Proc_Out    (I :    out Integer) is begin null; end; -- If we use "is null", I is not overwritten
      procedure Proc_In_Out (I : in out Integer) is begin null; end;
   begin
      declare
         I : Integer := 5;
      begin
         Proc_Out (I);
         pragma Assert (I /= 5, "I is overwritten by a value that is most likely not 5");
      end;
      declare
         I : Integer := 5;
      begin
         Proc_In_Out (I);
         pragma Assert (I = 5, "I is not overwritten");
      end;
   end Im_Out; -- Moral of the story: always initialize "out only" parameters with a value


   Test_Access : declare
      procedure First (A : aliased Integer) is
         B : constant not null access constant Integer := A'Access;
      begin
         pragma Assert (B.all = 5);
      end;
      procedure Second (A : not null access constant Integer) is
         B : constant not null access constant Integer := A;
      begin
         pragma Assert (B.all = 5);
      end;

      I : aliased Integer := 5;
   begin
      First  (I);
      Second (I'Access);
   end Test_Access;


   Test_Attributes_1 : declare
   begin
      pragma Assert (Integer'Min (Integer'First, Integer'Last) = Integer'First);
      pragma Assert (Integer'Max (Integer'First, Integer'Last) = Integer'Last);

      pragma Assert (Integer'Width = 11);            -- Length of "-2147483648"
      pragma Assert (Integer'Value ("   8   ") = 8); -- "Value" attribute trims spaces
   end Test_Attributes_1;


   Test_Attributes_2 : declare
      A : constant Integer := Integer'First;
      B : constant Integer := Integer'Value (Integer'First'Image);
   begin
      pragma Assert (A = B);
      pragma Assert (Integer'Succ (Integer'Pred (A)) = A);
    --pragma Assert (Integer'Succ (Integer'Pred (B)) = B); -- Crashes (despite the fact that A = B)
   end Test_Attributes_2;


   Test_Attributes_3 : declare
      type T is range 1 .. 0;
   begin
      pragma Assert (T'     Last'Image = " 0");
      pragma Assert (T'Base'Last'Image = " 127");
   end Test_Attributes_3;


   Test_Attributes_4 : declare
      type T is new Character range 'A' .. 'D' with Static_Predicate => T in 'C' | 'B';
   begin
      pragma Assert (T'First_Valid = 'B'); -- "First" attribute is not allowed because the type has a predicate
   end Test_Attributes_4;


   Null_Record : declare
      type R is tagged null record;
      type T1 is not null access constant R'Class;
      type T2 is not null access all      R'Class;

      A1 : aliased constant R := (null record);
      A2 : aliased          R := (null record);
      B1 : constant T1 := A1'Access;
      B2 : constant T2 := A2'Access; -- works because T2 has "all"
      C1 : constant T1 := new R'(null record);
      C2 : constant T2 := new R'(null record);
      use type Ada.Tags.Tag;
   begin
      pragma Assert (B1.all = C2.all and B2.all = C1.all);
      pragma Assert (B1'Tag = C2'Tag and B2'Tag = C1'Tag);
   end Null_Record;


   Sorted_List : declare
      type T is array (Character range 'B' .. 'E') of Integer;
      List : constant T := (1, 2, 2, 3);
   begin
      pragma Assert ((for all I in List'First .. Character'Pred (List'Last) => List (I) <= List (Character'Succ (I))), "The list is sorted");
      declare
         List_2 : T := List;
      begin
         for Item of List_2 loop
            Item := Item * 2;
         end loop;
         pragma Assert ((for all I in List'Range => List (I) * 2 = List_2 (I)), "List_2 is List * 2");
      end;
   end Sorted_List;


   Unicode : declare
      Heart : constant String := "❤️";
      pragma Assert (Heart'Length = 6);
      pragma Assert (Heart'Size   = 6 * 8);
   begin
      Put_Line (Heart);
   end Unicode;


   No_Return : declare
      procedure Never_Ending with No_Return is
      begin
         loop
            null;
         end loop;
      end;
      procedure Do_Nothing is null;
   begin
      Do_Nothing;
   end No_Return;


   Generic_Renaming : declare
      package P is
         function Random return Integer;
      end;
      package body P is
         generic package Discrete_Random renames Ada.Numerics.Discrete_Random;
         package Random_Positive is new Discrete_Random (Positive);
         use     Random_Positive;
         G : Generator;
         function Random return Integer is (Random (G));
      begin
         Reset (G);
      end;
   begin
      pragma Assert (P.Random > 0);
   end Generic_Renaming;


   Errors : declare
      Error   : exception;
      Message : constant String := "oh no";
   begin
      raise Error with Message;
   exception
      when E : Error =>
         pragma Assert (Ada.Exceptions.Exception_Message (E) = Message);
         pragma Assert (Ada.Exceptions.Exception_Name    (E) = "MAIN.ERRORS.ERROR");
      when others =>
         Put_Line ("unreachable");
         raise;
   end Errors;
end Main;
