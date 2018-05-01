' SplitFile - by Michael Rideout, written in FreeBASIC
' ----------------------------------------------------
' Splits an input file into one or more output files,
' where each output file may be 1K, 2K, or 4K, and the
' last file is however many bytes remain.
' Intended purpose of SplitFile is to divide ROMs for
' bankswitched Atari 2600 games into their individual
' banks, so each bank can then be disassembled using
' the Distella disassembler (which cannot disassemble
' Atari 2600 game ROMs larger than 4K).
'
filename$ = COMMAND$(1)
IF filename$ = "" THEN
   PRINT "Nothing to do!"
   PRINT "Usage: SPLITFILE [<path>]<filename> [<size>]"
   PRINT "Where: [<path>] is optional path (e.g., C:\Atari\2600\ROMs\)"
   PRINT "       <filename> is name of file to split (required)"
   PRINT "       [<size>] is optional size of output files (e.g., 4K)"
   PRINT "Notes: <size> may be 1K, 2K, or 4K (case insensitive)"
   PRINT "       1K may be typed as 1, 1K, 1KB, 1024, or 1024B"
   PRINT "       2K may be typed as 2, 2K, 2KB, 2048, or 2048B"
   PRINT "       Anything else (including no size) will be read as 4096"
   PRINT "Output files will be named file_#.ext"
   PRINT "       where 'file' is original filename,
   PRINT "       '#' is number of output file,"
   PRINT "       and '.ext' is original extension"
   PRINT "If path or filename contains spaces,"
   PRINT "       '\path\filename' must be in quotes"
ELSE
   last.backslash% = 0
   backslash% = -1
   WHILE backslash% <> 0
      backslash% = INSTR(last.backslash% + 1, filename$, "\")
      IF backslash% > 0 THEN
         last.backslash% = backslash%
      END IF
   WEND
   IF last.backslash% > 0 THEN
      path$ = LEFT$(filename$, last.backslash%)
      filename$ = MID$(filename$, last.backslash% + 1)
   ELSE
      path$ = ""
   END IF
   last.period% = 0
   period% = -1
   WHILE period% <> 0
      period% = INSTR(last.period% + 1, filename$, ".")
      IF period% > 0 THEN
         last.period% = period%
      END IF
   WEND
   IF last.period% > 1 THEN
      extension$ = MID$(filename$, last.period%)
      filename$ = LEFT$(filename$, last.period% - 1)
   ELSE
      extension$ = ""
   END IF
   size$ = UCASE$(COMMAND$(2))
   IF size$ = "1" OR size$ = "1K" OR size$ = "1KB" OR size$ = "1024" OR size$ = "1024B" THEN
      size% = 1024
   ELSEIF size$ = "2" OR size$ = "2K" OR size$ = "2KB" OR size$ = "2048" OR size$ = "2048B" THEN
      size% = 2048
   ELSE
      size% = 4096
   END IF
   record$ = STRING$(size%, " ")
   input.file$ = path$ + filename$ + extension$
   OPEN input.file$ FOR BINARY AS #1 LEN = size%
   bytes.remaining% = LOF(1)
   PRINT "Reading"; bytes.remaining%; " bytes in "; input.file$
   current.slice% = 1
   WHILE bytes.remaining% > 0
      IF bytes.remaining% < size% THEN
         size% = bytes.remaining%
         record$ = STRING$(size%, " ")
      END IF
      slice$ = "_" + STR(current.slice%)
      output.file$ = path$ + filename$ + slice$ + extension$
      OPEN output.file$ FOR BINARY AS #2 LEN = size%
      PRINT "Writing"; size%; " bytes to "; output.file$
      GET #1, , record$
      PUT #2, , record$
      CLOSE #2
      bytes.remaining% = bytes.remaining% - size%
      current.slice% = current.slice% + 1
   WEND
   CLOSE #1
   PRINT "All done!"
END IF
