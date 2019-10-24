------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                               O U T P U T                                --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 1992-2019, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  This package contains low level output routines used by the compiler for
--  writing error messages and informational output. It is also used by the
--  debug source file output routines (see Sprint.Print_Debug_Line).

with Hostparm;
with Types;    use Types;

pragma Warnings (Off);
--  This package is used also by gnatcoll
with System.OS_Lib; use System.OS_Lib;
pragma Warnings (On);

package Output is
   pragma Elaborate_Body;

   type Output_Proc is access procedure (S : String);
   --  This type is used for the Set_Special_Output procedure. If Output_Proc
   --  is called, then instead of lines being written to standard error or
   --  standard output, a call is made to the given procedure for each line,
   --  passing the line with an end of line character (which is a single
   --  ASCII.LF character, even in systems which normally use CR/LF or some
   --  other sequence for line end).

   -----------------
   -- Subprograms --
   -----------------

   procedure Set_Special_Output (P : Output_Proc);
   --  Sets subsequent output to call procedure P. If P is null, then the call
   --  cancels the effect of a previous call, reverting the output to standard
   --  error or standard output depending on the mode at the time of previous
   --  call. Any exception generated by calls to P is simply propagated to
   --  the caller of the routine causing the write operation.

   procedure Cancel_Special_Output;
   --  Cancels the effect of a call to Set_Special_Output, if any. The output
   --  is then directed to standard error or standard output depending on the
   --  last call to Set_Standard_Error or Set_Standard_Output. It is never an
   --  error to call Cancel_Special_Output. It has the same effect as calling
   --  Set_Special_Output (null).

   procedure Ignore_Output (S : String);
   --  Does nothing. To disable output, pass Ignore_Output'Access to
   --  Set_Special_Output.

   procedure Set_Standard_Error;
   --  Sets subsequent output to appear on the standard error file (whatever
   --  that might mean for the host operating system, if anything) when
   --  no special output is in effect. When a special output is in effect,
   --  the output will appear on standard error only after special output
   --  has been cancelled.

   procedure Set_Standard_Output;
   --  Sets subsequent output to appear on the standard output file (whatever
   --  that might mean for the host operating system, if anything) when no
   --  special output is in effect. When a special output is in effect, the
   --  output will appear on standard output only after special output has been
   --  cancelled. Output to standard output is the default mode before any call
   --  to either of the Set procedures.

   procedure Set_Output (FD : File_Descriptor);
   --  Sets subsequent output to appear on the given file descriptor when no
   --  special output is in effect. When a special output is in effect, the
   --  output will appear on the given file descriptor only after special
   --  output has been cancelled.

   procedure Indent;
   --  Increases the current indentation level. Whenever a line is written
   --  (triggered by Eol), an appropriate amount of whitespace is added to the
   --  beginning of the line, wrapping around if it gets too long.

   procedure Outdent;
   --  Decreases the current indentation level

   procedure Write_Char (C : Character);
   --  Write one character to the standard output file. If the character is LF,
   --  this is equivalent to Write_Eol.

   procedure Write_Erase_Char (C : Character);
   --  If last character in buffer matches C, erase it, otherwise no effect

   procedure Write_Eol;
   --  Write an end of line (whatever is required by the system in use, e.g.
   --  CR/LF for DOS, or LF for Unix) to the standard output file. This routine
   --  also empties the line buffer, actually writing it to the file. Note that
   --  Write_Eol is the only routine that causes any actual output to be
   --  written. Trailing spaces are removed.

   procedure Write_Eol_Keep_Blanks;
   --  Similar as Write_Eol, except that trailing spaces are not removed

   procedure Write_Int (Val : Int);
   --  Write an integer value with no leading blanks or zeroes. Negative values
   --  are preceded by a minus sign).

   procedure Write_Spaces (N : Nat);
   --  Write N spaces

   procedure Write_Str (S : String);
   --  Write a string of characters to the standard output file. Note that
   --  end of line is normally handled separately using WRITE_EOL, but it is
   --  allowable for the string to contain LF (but not CR) characters, which
   --  are properly interpreted as end of line characters. The string may also
   --  contain horizontal tab characters.

   procedure Write_Line (S : String);
   --  Equivalent to Write_Str (S) followed by Write_Eol;

   function Last_Char return Character;
   --  Returns last character written on the current line, or null if the
   --  current line is (so far) empty.

   procedure Delete_Last_Char;
   --  Deletes last character written on the current line, no effect if the
   --  current line is (so far) empty.

   function Column return Pos;
   pragma Inline (Column);
   --  Returns the number of the column about to be written (e.g. a value of 1
   --  means the current line is empty).

   -------------------------
   -- Buffer Save/Restore --
   -------------------------

   --  This facility allows the current line buffer to be saved and restored

   type Saved_Output_Buffer is private;
   --  Type used for Save/Restore_Buffer

   Buffer_Max : constant := Hostparm.Max_Line_Length;
   --  Maximal size of a buffered output line

   function Save_Output_Buffer return Saved_Output_Buffer;
   --  Save current line buffer and reset line buffer to empty

   procedure Restore_Output_Buffer (S : Saved_Output_Buffer);
   --  Restore previously saved output buffer. The value in S is not affected
   --  so it is legitimate to restore a buffer more than once.

   --------------------------
   -- Debugging Procedures --
   --------------------------

   --  The following procedures are intended only for debugging purposes,
   --  for temporary insertion into the text in environments where a debugger
   --  is not available. They all have non-standard very short lower case
   --  names, precisely to make sure that they are only used for debugging.

   procedure w (C : Character);
   --  Dump quote, character, quote, followed by line return

   procedure w (S : String);
   --  Dump string followed by line return

   procedure w (V : Int);
   --  Dump integer followed by line return

   procedure w (B : Boolean);
   --  Dump Boolean followed by line return

   procedure w (L : String; C : Character);
   --  Dump contents of string followed by blank, quote, character, quote

   procedure w (L : String; S : String);
   --  Dump two strings separated by blanks, followed by line return

   procedure w (L : String; V : Int);
   --  Dump contents of string followed by blank, integer, line return

   procedure w (L : String; B : Boolean);
   --  Dump contents of string followed by blank, Boolean, line return

private

   type Saved_Output_Buffer is record
      Buffer          : String (1 .. Buffer_Max + 1);
      Next_Col        : Positive;
      Cur_Indentation : Natural;
   end record;

end Output;
