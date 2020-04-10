
;====================================================================================================================================================================
; Title ..........: CronToTime_Examples.au3
; Description ....: CronToTime UDF Examples
;====================================================================================================================================================================

#include "CronToTime.au3"

ConsoleWrite('====================== Example #1=======================' & @CRLF)
Local $cronExp = "38 12 * * *"
ConsoleWrite("Current event example (now)" & @CRLF)
$rt = pce_CronExpToSeconds($cronExp, True, "2010/01/01 12:38:00")
ConsoleWrite('pce_CronExpToSeconds("' & $cronExp & '", True, "2010/01/01 12:38:00")' & @CRLF)
ConsoleWrite("Result: " & $rt & @CRLF & @CRLF)

ConsoleWrite('====================== Example #2=======================' & @CRLF)
$cronExp = "38 12 * * *"
ConsoleWrite("Current event example (now)" & @CRLF)
$rt = pce_CronExpToSeconds($cronExp, True, "2010/01/01 12:38:45")
ConsoleWrite('pce_CronExpToSeconds("' & $cronExp & '", True, "2010/01/01 12:38:45")' & @CRLF)
ConsoleWrite("Result: " & $rt & @CRLF & @CRLF)

ConsoleWrite('====================== Example #3=======================' & @CRLF)
$cronExp = "0 10 * * *"
ConsoleWrite("Previous event example" & @CRLF)
$rt = pce_CronExpToSeconds($cronExp, False, "2010/01/01 12:00:00")
ConsoleWrite('pce_CronExpToSeconds("' & $cronExp & '", False, "2010/01/01 12:00:00")' & @CRLF)
ConsoleWrite("Result: " & $rt & @CRLF & @CRLF)

ConsoleWrite('====================== Example #4=======================' & @CRLF)
$cronExp = "0 0 29 Feb *"
ConsoleWrite("The next 5 events starting from '2010/01/01 00:00:00'. Cron expression = '" & $cronExp & "'" & @CRLF)
$cronExp = pce_convertNames($cronExp)
printEvents($cronExp , "2010/01/01 00:00:00", 5, 0)
ConsoleWrite(@CRLF)

ConsoleWrite('====================== Example #5=======================' & @CRLF)
ConsoleWrite("The previous 5 events starting from '2010/01/01 00:00:00'. Cron expression = '" & $cronExp & "'" & @CRLF)
printEvents($cronExp , "2010/01/01 00:00:00", 5, 0, False)
ConsoleWrite(@CRLF)

ConsoleWrite('====================== Example #6=======================' & @CRLF)
$cronExp = "18-20 0 28 2 7"
ConsoleWrite("The next 5 events starting from local time. Cron expression = '" & $cronExp & "'" & @CRLF)
printEvents($cronExp , "", 5, 0)
ConsoleWrite(@CRLF)

ConsoleWrite('====================== Example #7=======================' & @CRLF)
$cronExp = "*/2 * * Jan-Dec Mo-Su"
ConsoleWrite("The next event from GMT +1 Hour. Cron expression = '" & $cronExp & "'" & @CRLF)
ConsoleWrite('$cronExp = pce_convertNames("' & $cronExp & '")' & @CRLF)
$cronExp = pce_convertNames($cronExp)
ConsoleWrite("Result:" & $cronExp & @CRLF)
ConsoleWrite('pce_CronExpToDateTimeUTC("' & $cronExp & '", True, 60)' & @CRLF)
Local $rt = pce_CronExpToDateTimeUTC($cronExp, True, 60)                                    ;Europe Paris UTC/GTM +1 Hour (60 Minutes, daylight saving time not considered)
ConsoleWrite("Result:" & $rt & @CRLF & @CRLF)

ConsoleWrite('====================== Example #8=======================' & @CRLF)
$cronExp = "12 12 * * *"
ConsoleWrite("The next event from local time. Cron expression = '" & $cronExp & "'" & @CRLF)
ConsoleWrite('pce_CronExpToDateTimeUTC("' & $cronExp & '", True, 60)' & @CRLF)
Local $rt = pce_CronExpToDateTimeUTC($cronExp, True, 60)                                    ;Europe Paris UTC/GTM +1 Hour (60 Minutes, daylight saving time not considered)
ConsoleWrite("Result:" & $rt & @CRLF & @CRLF)

ConsoleWrite('====================== Example #9=======================' & @CRLF)
$cronExp = '@yearly'
ConsoleWrite('pce_convertNames(' & $cronExp & ')' & @CRLF)
$cronExp = pce_convertNames($cronExp)
$rt = pce_CronExpToDateTimeUTC($cronExp, True, 60)
ConsoleWrite("Result:" & $rt & @CRLF)


Func printEvents($exp, $rt, $iterations, $minutes = 0, $bForward = true)
   $rt = pce_CronExpToDateTime($exp, $bForward, $rt, $minutes)
   if @error > 0 Or $iterations = 0 Then Return
   ConsoleWrite("Result:" & $rt & @CRLF)
   $iterations -=1
   printEvents($exp, $rt,$iterations,($bForward) ? 1 : -1, $bForward)
EndFunc



