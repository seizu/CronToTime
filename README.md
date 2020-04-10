CronToTime
----------
Crontab expression parser for Autoit (UDF). Convert Cron expression to DateTime or Seconds

CronToTime is an Autoit UDF to convert Unix Cron expressions to DateTime or Seconds.
On Unix systems a Cron expression made of five fields separated by blanks/tabs followed by a shell command to execute.

```
Example: run a shell command 'reboot' every day at 12:45

45 12 * * * reboot

+------------- minute (0 - 59)
¦  +------------- hour (0 - 23)
¦  ¦  +------------- day of month (1 - 31)
¦  ¦  ¦ +------------- month (1 - 12)
¦  ¦  ¦ ¦ +------------- day of week (0 - 6) (Sunday to Saturday, 7 is also Sunday)
¦  ¦  ¦ ¦ ¦ +------------- some shell command
¦  ¦  ¦ ¦ ¦ ¦
¦  ¦  ¦ ¦ ¦ ¦
44 12 * * * reboot
```
(In this UDF the 6th field has no meaning and no influence on the result).

For more information see https://en.wikipedia.org/wiki/Cron

Description of Functions
------------------------
```
Func pce_CronExpToSecondsUTC($sCronExp, $bForwardSearch = True, $minutesOffset = 0)
=======================================================================================================================
 Description     Returns the number of seconds until the event occurs, starting from current UTC/GMT.

 Function Name   pce_CronExpToSecondsUTC( $sCronExp [, $bForwardSearch = True [, $minutesOffset = 0]]])

 Parameters

 $sCronExp       Unix Cron expression e.g. "15-30 2,3,4,5 29 2 Mo-Su" 
 $bForwardSearch [optional] Search direction. Default = True (Forward search), False (Backward search)
 $minutesOffset  [optional] The offset in minutes to adjust the GMT zone. 
                 This value may be positive or negative. Default = 0

 Return Value

 Success:        Returns the number of seconds until the event occurs. Events that occur at the 
                 current time (now) could result in a negative value, even if bFrowardSearch = True. 
                 Possible values are >= -59
                 if bFrowardSearch = False (events in the past) possible values are <= 0

 Failure:        False and sets the @error flag to non-zero

 @error          1 - Invalid Cron expression.
                 3 - Next interval not found
                 4 - Invalid Cron expression, @extended field number

 @extened        the number of the expression field (1 to 5) in which the error occured. 
                 0 = means one or more fields.




Func pce_CronExpToSeconds($sCronExp, $bForwardSearch = True,  $sDateTime = "", $minutesOffset = 0)
=======================================================================================================================
 Description     Returns the number of seconds until the event occurs. If $sDateTime is not set, 
                 local time will be used.

 Function Name   pce_CronExpToSeconds( $sCronExp [, $bForwardSearch = True [, $sDateTime = "" [, $minutesOffset = 0]]])

 Parameters

 $sCronExp       Unix Cron expression string e.g. "15-30 2,3,4,5 29 2 2-5"
 $bForwardSearch [optional] Search direction. Default = True (Forward search), False (Backward search)
 $sDateTime      [optional] DataTime string in the format YYYY/MM/DD HH:MM:SS. 
                 Default = "", means current local DateTime
 $minutesOffset  [optional] Offset in minutes to adjust the sDateTime parameter. 
                 This value may be positive or negative. Default = 0

 Return Value

 Success:        Returns the number of seconds until the event occurs. Events that occur at the 
                 current time (now) could result in a negative value, even if bFrowardSearch = True. 
                 Possible values are >= -59
                 if bFrowardSearch = False (events in the past) possible values are <= 0

 Failure:        False and sets the @error flag to non-zero

 @error          1 - Invalid Cron expression.
                 2 - Invalid sDateTime format
                 3 - Next interval not found
                 4 - Invalid Cron expression, @extended field number

 @extened        The number of the expression field (1 to 5) in which the error occured. 0 = one or more fields.




Func pce_CronExpToDateTimeUTC($sCronExp, $bForwardSearch = True, $minutesOffset = 0)
=======================================================================================================================
 Description     Finds the nearest DateTime of the specified Cron expression, starting from current UTC/GMT.

 Function Name   pce_CronExpToDateTimeUTC( $sCronExp [, $bForwardSearch = True [, $minutesOffset = 0]]])

 Parameters

 $sCronExp       Unix Cron expression e.g. "15-30 2,3,4,5 29 2 Mo-Su" 
 $bForwardSearch [optional] Search direction. Default = True (Forward search), False (Backward search)
 $minutesOffset  [optional] The offset in minutes to adjust the GMT zone. 
                 This value may be positive or negative. Default = 0

 Return Value

 Success:        A DateTime String in the format YYYY/MM/DD HH:MM:SS of the current or next event.
                 Previous events if $bForwardSearch = False

 Failure:        False and sets the @error flag to non-zero

 @error          1 - Invalid Cron expression.
                 3 - Next interval not found
                 4 - Invalid Cron expression, @extended field number

 @extened        the number of the expression field (1 to 5) in which the error occured. 0 = one or more fields.




Func pce_convertNames($sCronExp)
=======================================================================================================================
 Description    Convert names in usable Cron expression values. 
                E.g. "15-30 2,3,4,5 29 July-December Mo-Su" to "15-30 2,3,4,5 29 7-12 1-7"

 Function Name  pce_convertNames( $sCronExp )

 Parameters

 $sCronExp      Unix Cron expression with names e.g. "15-30 2,3,4,5 29 July-December Mo-Su"

 Return Value

 Success:       Number-based Cron expression string
```
