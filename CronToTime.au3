;====================================================================================================================================================================
; Title ..........: CronToTime AutoIt UDF
; AutoIt Version..: 3.6.6
; Description ....: Cron expression to DateTime or Seconds
; Author .........: Erich Pribitzer
; Version ........: 1.1
;====================================================================================================================================================================

#include-once

#include <Array.au3>
#include <Date.au3>

Global Const $_pce_Min = 0
Global Const $_pce_Hou = 1
Global Const $_pce_Day = 2
Global Const $_pce_Mon = 3
Global Const $_pce_DoW = 4
Global Const $_pce_Yea = 5

Global Const $_pce_Range[5][2] = [[0, 59], [0, 23], [1, 31], [1, 12], [0, 7]]


Local $_pce_Replacements[26][2] = [['(january|jan)',          '1'], _
                                   ['(february|feb)',         '2'], _
                                   ['(march|mar)',            '3'], _
                                   ['(april|apr)',            '4'], _
                                   ['(may)',                  '5'], _
                                   ['(june|jun)',             '6'], _
                                   ['(july|jul)',             '7'], _
                                   ['(august|aug)',           '8'], _
                                   ['(september|sep)',        '9'], _
                                   ['(october|oct)',          '10'], _
                                   ['(november|nov)',         '11'], _
                                   ['(december|dec)',         '12'], _
                                   ['(-sunday|-sun|-su)',     '-7'], _
                                   ['(sunday|sun|su)',        '0'], _
                                   ['(monday|mon|mo)',        '1'], _
                                   ['(tuesday|tue|tu)',       '2'], _
                                   ['(wednesdays|wed|we)',    '3'], _
                                   ['(thursday|thu|th)',      '4'], _
                                   ['(friday|fri|fr)',        '5'], _
                                   ['(saturday|sat|sa)',      '6'], _
                                   ['(@yearly|@annualy)',     '0 0 1 1 *'], _
                                   ['(@monthly)',             '0 0 1 * *'], _
                                   ['(@weekly)',              '0 0 * * 0'], _
                                   ['(@daily|@midnight)',     '0 0 * * *'], _
                                   ['(@hourly)',              '0 * * * *'], _
                                   ['(@every_minute)',        '*/1 * * * *']]

;====================================================================================================================================================================
;
; Description          Returns the number of seconds until the event occurs, starting from current UTC/GMT.
;
; Function Name        pce_CronExpToSecondsUTC( $sCronExp [, $bForwardSearch = True [, $minutesOffset = 0]]])
;
; Parameters
;
; $sCronExp            Unix Cron expression e.g. "15-30 2,3,4,5 29 2 Mo-Su" (more information https://en.wikipedia.org/wiki/Cron)
; $bForwardSearch      [optional] Search direction. Default = True (Forward search), False (Backward search)
; $minutesOffset       [optional] The offset in minutes to adjust the GMT zone. This value may be positive or negative. Default = 0
;
; Return Value
;
; Success:             Returns the number of seconds until the event occurs. Any event occurring in the current minute (Now) could result in a negative value,
;                      even if bFrowardSearch = True. Possible values are >= -59
;                      if bFrowardSearch = False (events in the past) possible values are <= 0
;
; Failure:             False and sets the @error flag to non-zero
;
; @error               1 - Invalid Cron expression.
;                      3 - Next interval not found
;                      4 - Invalid Cron expression, @extended field number
;
; @extened             the number of the expression field (1 to 5) in which the error occured. 0 = one or more fields.
;
;====================================================================================================================================================================

Func pce_CronExpToSecondsUTC($sCronExp, $bForwardSearch = True, $minutesOffset = 0)
   Local $systemTime = _Date_Time_GetSystemTime()
   Local $sDateTime = _Date_Time_SystemTimeToDateTimeStr($systemTime, 1)
   $sDateTime = _DateAdd('n', $minutesOffset, $sDateTime)
   Local $tf = pce_CronExpToDateTime($sCronExp, $bForwardSearch, $sDateTime)
   ;ConsoleWrite("Diff: " & $tf & " - " & $sDateTime & @CRLF)
   if @error = 0 Then
      $tf = _DateDiff('s', $sDateTime, $tf )
   EndIF

   Return SetError(@error, @extended, $tf)
EndFunc


;====================================================================================================================================================================
;
; Description          Returns the number of seconds until the event occurs. If $sDateTime is not set, local time will be used.
;
; Function Name        pce_CronExpToSeconds( $sCronExp [, $bForwardSearch = True [, $sDateTime = "" [, $minutesOffset = 0]]])
;
; Parameters
;
; $sCronExp            Unix Cron expression string e.g. "15-30 2,3,4,5 29 2 2-5" (More information https://en.wikipedia.org/wiki/Cron)
; $bForwardSearch      [optional] Search direction. Default = True (Forward search), False (Backward search)
; $sDateTime           [optional] DataTime string in the format YYYY/MM/DD HH:MM:SS. Default = "" means current local DateTime
; $minutesOffset       [optional] Offset in minutes to adjust the sDateTime parameter. This value may be positive or negative. Default = 0
;
; Return Value
;
; Success:             Returns the number of seconds until the event occurs. Any event occurring in the current minute (Now) could result in a negative value,
;                      even if bFrowardSearch = True. Possible values are >= -59
;                      if bFrowardSearch = False (events in the past) possible values are <= 0
;
; Failure:             False and sets the @error flag to non-zero
;
; @error               1 - Invalid Cron expression.
;                      2 - Invalid sDateTime format
;                      3 - Next interval not found
;                      4 - Invalid Cron expression, @extended field number
;
; @extened             The number of the expression field (1 to 5) in which the error occured. 0 = one or more fields.
;
;====================================================================================================================================================================

Func pce_CronExpToSeconds($sCronExp, $bForwardSearch = True,  $sDateTime = "", $minutesOffset = 0)

   If $sDateTime = "" Then $sDateTime = _NowCalc()
   $sDateTime = _DateAdd('n', $minutesOffset, $sDateTime)

   Local $tf = pce_CronExpToDateTime($sCronExp, $bForwardSearch, $sDateTime)

   if @error = 0 Then
      $tf = _DateDiff('s', $sDateTime, $tf )
   EndIF
   Return SetError(@error, @extended, $tf)
EndFunc


;====================================================================================================================================================================
;
; Description          Finds the nearest DateTime of the specified Cron expression, starting from current UTC/GMT.
;
; Function Name        pce_CronExpToDateTimeUTC( $sCronExp [, $bForwardSearch = True [, $minutesOffset = 0]]])
;
; Parameters
;
; $sCronExp            Unix Cron expression e.g. "15-30 2,3,4,5 29 2 Mo-Su" (more information https://en.wikipedia.org/wiki/Cron)
; $bForwardSearch      [optional] Search direction. Default = True (Forward search), False (Backward search)
; $minutesOffset       [optional] The offset in minutes to adjust the GMT zone. This value may be positive or negative. Default = 0
;
; Return Value
;
; Success:             A DateTime String in the format YYYY/MM/DD HH:MM:SS of the current or next event.
;                      Previous events if $bForwardSearch = False
;
; Failure:             False and sets the @error flag to non-zero
;
; @error               1 - Invalid Cron expression.
;                      3 - Next interval not found
;                      4 - Invalid Cron expression, @extended field number
;
; @extened             the number of the expression field (1 to 5) in which the error occured. 0 = one or more fields.
;
;=====================================================================================================================================================================

Func pce_CronExpToDateTimeUTC($sCronExp, $bForwardSearch = True, $minutesOffset = 0)
   Local $systemTime = _Date_Time_GetSystemTime()
   Local $sDateTime = _Date_Time_SystemTimeToDateTimeStr($systemTime, 1)
   $sDateTime = _DateAdd('n', $minutesOffset, $sDateTime)
   Local $tf = pce_CronExpToDateTime($sCronExp, $bForwardSearch, $sDateTime)
   Return SetError(@error, @extended, $tf)
EndFunc


;====================================================================================================================================================================
;
; Description          Finds the nearest DateTime of the specified Cron expression. If $sDateTime is not set, local time will be used.
;
; Function Name        pce_CronExpToDateTime( $sCronExp [, $bForwardSearch = True [, $sDateTime = "" [, $minutesOffset = 0]]])
;
; Parameters
;
; $sCronExp            Unix Cron expression string e.g. "15-30 2,3,4,5 29 2 Mo-Su" (More information https://en.wikipedia.org/wiki/Cron)
; $bForwardSearch      [optional] Search direction. Default = True (Forward search), False (Backward search)
; $sDateTime           [optional] DataTime string in the format YYYY/MM/DD HH:MM:SS. Default = "" means current local DateTime
; $minutesOffset       [optional] Offset in minutes to adjust the sDateTime parameter. This value may be positive or negative. Default = 0
;
; Return Value
;
; Success:             A DateTime String in the format YYYY/MM/DD HH:MM:SS of the current or next event.
;                      Previous events if $bForwardSearch = False
;
; Failure:             False and sets the @error flag to non-zero
;
; @error               1 - Invalid Cron expression.
;                      2 - Invalid sDateTime format
;                      3 - Next interval not found
;                      4 - Invalid Cron expression, @extended field number
;
; @extened             The number of the expression field (1 to 5) in which the error occured. 0 = one or more fields.
;
;====================================================================================================================================================================

Func pce_CronExpToDateTime($sCronExp, $bForwardSearch = True,  $sDateTime = "", $minutesOffset = 0)

   Local $fb = ($bForwardSearch) ? 1 : -1
   Local $hou, $min
   Local $calc = True
   Dim $aDateTime[6]
   Dim $aCronTab[5]

   If $sDateTime = "" Then $sDateTime = _NowCalc()
   $sDateTime = _DateAdd('n', $minutesOffset, $sDateTime)
   If _pce_dateTimeStrToDateTime($aDateTime, $sDateTime) = False Or Not _DateIsValid($sDateTime) Then Return SetError(2, 0, False)
   Local $sYear = $aDateTime[$_pce_Yea]
   Local $subElem = StringRegExp($sCronExp, '([0-9*,-/]+)[\t ]+([0-9*,-/]+)[\t ]+([0-9*,-/]+)[\t ]+([0-9*,-/]+)[\t ]+([0-9*,-/]+)', 1)
   If @error Then Return SetError(1, 0, False)

   For $i = 0 To 4
      If _pce_buildArray($aCronTab, $subElem[$i], $i, $bForwardSearch) = False Then Return SetError(@error, $i + 1, False)
   Next

   Local $dix = _ArraySearch($aCronTab[$_pce_Day], $aDateTime[$_pce_Day])
   Local $moix = _ArraySearch($aCronTab[$_pce_Mon], $aDateTime[$_pce_Mon])
   Local $dwix = _ArraySearch($aCronTab[$_pce_DoW], $aDateTime[$_pce_DoW])
   If $dwix = -1 Or $dix = -1 Or $moix = -1 Then
      $aDateTime[$_pce_Min] = ($aCronTab[$_pce_Min])[0]
      $aDateTime[$_pce_Hou] = ($aCronTab[$_pce_Hou])[0]
   Else
      $hou = _pce_findVal($aDateTime[$_pce_Hou], $aCronTab[$_pce_Hou], $bForwardSearch)
      If Not IsInt($hou) Then
         $aDateTime[$_pce_Min] = ($aCronTab[$_pce_Min])[0]
         $aDateTime[$_pce_Hou] = ($aCronTab[$_pce_Hou])[0]
         _pce_dateTimeStrToDateTime($aDateTime, _DateAdd('D', $fb, $aDateTime[$_pce_Yea] & "/" & $aDateTime[$_pce_Mon] & "/" & $aDateTime[$_pce_Day] & " " & $aDateTime[$_pce_Hou] & ":" & $aDateTime[$_pce_Min]))
      Else
         $min = _pce_findVal($aDateTime[$_pce_Min], $aCronTab[$_pce_Min], $bForwardSearch)
         If Not IsInt($min) Then
            $hou = _pce_findVal($aDateTime[$_pce_Hou] + $fb, $aCronTab[$_pce_Hou], $bForwardSearch)
            If Not IsInt($hou) Then
               $min = ($aCronTab[$_pce_Min])[0]
               $hou = ($aCronTab[$_pce_Hou])[0]
               _pce_dateTimeStrToDateTime($aDateTime, _DateAdd('D', $fb, $aDateTime[$_pce_Yea] & "/" & $aDateTime[$_pce_Mon] & "/" & $aDateTime[$_pce_Day] & " " & $hou & ":" & $min))
            Else
               Local $end = UBound($aCronTab[$_pce_Min]) - 1
               $aDateTime[$_pce_Min] = ($bForwardSearch) ? ($aCronTab[$_pce_Min])[0] : ($aCronTab[$_pce_Min])[$end]
               $aDateTime[$_pce_Hou] = $hou
               $calc = False
            EndIf
         Else
            If $hou <> $aDateTime[$_pce_Hou] Then $min = ($aCronTab[$_pce_Min])[0]
            $aDateTime[$_pce_Min] = $min
            $aDateTime[$_pce_Hou] = $hou
            $calc = False
         EndIf
      EndIf
   EndIf

   If $calc Then
      $dix = _ArraySearch($aCronTab[$_pce_Day], $aDateTime[$_pce_Day])
      $moix = _ArraySearch($aCronTab[$_pce_Mon], $aDateTime[$_pce_Mon])
      $dwix = _ArraySearch($aCronTab[$_pce_DoW], $aDateTime[$_pce_DoW])

      Local $mosz = UBound($aCronTab[$_pce_Mon])
      Local $dosz = UBound($aCronTab[$_pce_Day])

      if $sYear <> $aDateTime[$_pce_Yea] Then
		  $dix =0
		  $moix = 0
      EndIf

      $moix = ($moix = -1) ? 0 : $moix
      $dix = ($dix = -1) ? 0 : $dix

      Local $ndate
      Local $udate = '1970/01/01'
      Local $cdate = _DateDiff('s', $udate, $aDateTime[$_pce_Yea] & "/" & $aDateTime[$_pce_Mon] & "/" & $aDateTime[$_pce_Day])
      For $year = $aDateTime[$_pce_Yea] To $aDateTime[$_pce_Yea] + (30 * $fb) Step $fb
         While $moix < $mosz
            While $dix < $dosz
			   ;ConsoleWrite($year & "/" & ($aCronTab[$_pce_Mon])[$moix] & "/" & ($aCronTab[$_pce_Day])[$dix] & @CRLF)
               If _DateIsValid($year & "/" & ($aCronTab[$_pce_Mon])[$moix] & "/" & ($aCronTab[$_pce_Day])[$dix]) Then
                  $ndate = _DateDiff('s', $udate, $year & "/" & ($aCronTab[$_pce_Mon])[$moix] & "/" & ($aCronTab[$_pce_Day])[$dix] & " " & "00:00:01")
                  If ($bForwardSearch And $ndate >= $cdate) Or ($bForwardSearch = False And $ndate <= $cdate) Then
                     Local $dw = _DateToDayOfWeekISO($year, ($aCronTab[$_pce_Mon])[$moix], ($aCronTab[$_pce_Day])[$dix])
                     If _ArraySearch($aCronTab[$_pce_DoW], $dw) >= 0 Then
                        Return SetError(0, 0, _
                              StringFormat("%d/%.2d/%.2d %.2d:%.2d:00", $year, ($aCronTab[$_pce_Mon])[$moix], ($aCronTab[$_pce_Day])[$dix], $aDateTime[$_pce_Hou], $aDateTime[$_pce_Min]))
                     EndIf
                  EndIf
               EndIf
               $dix += 1
            WEnd
            $dix = 0
            $moix += 1
         WEnd
         $moix = 0
      Next
      Return SetError(3, 0, False)
   EndIf

   Return SetError(0, 0, _
         StringFormat("%d/%.2d/%.2d %.2d:%.2d:00", $aDateTime[$_pce_Yea], $aDateTime[$_pce_Mon], $aDateTime[$_pce_Day], $aDateTime[$_pce_Hou], $aDateTime[$_pce_Min]))
EndFunc


;====================================================================================================================================================================
;
; Description          Convert names in usable Cron expression values. E.g. "15-30 2,3,4,5 29 July-December Mo-Su" to "15-30 2,3,4,5 29 7-12 1-7"
;
; Function Name        pce_convertNames( $sCronExp )
;
; Parameters
;
; $sCronExp            Unix Cron expression with names e.g. "15-30 2,3,4,5 29 July-December Mo-Su" (More information https://en.wikipedia.org/wiki/Cron)
;
; Return Value
;
; Success:             Number-based Cron expression string
;
;====================================================================================================================================================================

Func pce_convertNames($sCronExp)
   if StringRegExp($sCronExp,'(?i)[a-zäöü]+') = True Then
      For $t = 0 to UBound($_pce_Replacements)-1
         $sCronExp = StringRegExpReplace( $sCronExp,'(?i)' & $_pce_Replacements[$t][0],$_pce_Replacements[$t][1])
      Next
   EndIf
   Return $sCronExp
EndFunc


Func _pce_findVal($val, ByRef $cron, $bForwardSearch)

   If _ArraySearch($cron, $val) >= 0 Then Return $val
   Local $end = UBound($cron) - 1

   If ($bForwardSearch And $val <= $cron[$end]) Or ($bForwardSearch = False And $val >= $cron[$end]) Then
      For $rval In $cron
         If ($bForwardSearch And $val <= $rval) Or ($bForwardSearch = False And $rval <= $val) Then Return $rval
      Next
   EndIf

   Return False
EndFunc


Func _pce_buildArray(ByRef $aCronTab, $sSubElem, $iSubInx, $bForwardSearch)
   Dim $_itemsArray[($_pce_Range[$iSubInx][1]) + 1]
   Local $sub, $sz
   For $it In StringSplit($sSubElem, ",", 2)
      Local $step = 1, $a = $_pce_Range[$iSubInx][0], $b = $_pce_Range[$iSubInx][1]
      $sub = StringRegExp($it, '^(?|([0-9]{1,2})-([0-9]{1,2})(?:/([0-9]{1,2}))?|([*]{1})(?:/([0-9]{1,2}))?|([0-9]{1,2}))$', 1)
      If @error > 0 Then Return SetError(4, $iSubInx, False)
      $sz = UBound($sub)
      If $sz = 3 Then $step = $sub[2]
      If $sub[0] <> '*' Then
         $a = $sub[0]
         $b = $a
         If $sz > 1 Then $b = $sub[1]
      ElseIf $sz = 2 Then
         $step = $sub[1]
      EndIf
      If int($a) < int($_pce_Range[$iSubInx][0]) Or int($b) > int($_pce_Range[$iSubInx][1]) Or int($b) < int($a) Then
         Return SetError(4, $iSubInx + 1, False)
      EndIf
      For $i = $a To $b Step $step
         $_itemsArray[$i] = Int($i)
      Next
      If $a = $_pce_Range[$iSubInx][0] And $b = $_pce_Range[$iSubInx][1] And $step = 1 Then ExitLoop
   Next
   If $iSubInx = $_pce_DoW And IsInt($_itemsArray[0]) And $_itemsArray[0] = $_pce_Range[$iSubInx][0] Then
      $_itemsArray[0] = Null
      $_itemsArray[7] = 7
   EndIf

   ; purge array
   $sz = 0
   For $i = 0 To UBound($_itemsArray) - 1
      If IsInt($_itemsArray[$i]) Then
         $_itemsArray[$sz] = $_itemsArray[$i]
         $sz += 1
      EndIf
   Next
   ReDim $_itemsArray[$sz]

   If $bForwardSearch = False Then _ArrayReverse($_itemsArray)
   $aCronTab[$iSubInx] = $_itemsArray

   Return True
EndFunc

Func _pce_dateTimeStrToDateTime(ByRef $aDateTime, $sDateTime)

   Local $dt = StringRegExp($sDateTime, '([0-9]{4})/([0-9]{1,2})/([0-9]{1,2}) ([0-9]{1,2}):([0-9]{1,2})', 1)
   If @error > 0 Then Return False

   $aDateTime[$_pce_Min] = Int($dt[4]) ; minute
   $aDateTime[$_pce_Hou] = Int($dt[3]) ; hour
   $aDateTime[$_pce_Day] = Int($dt[2]) ; day
   $aDateTime[$_pce_Mon] = Int($dt[1]) ; month
   $aDateTime[$_pce_Yea] = Int($dt[0]) ; year
   $aDateTime[$_pce_DoW] = Int(_DateToDayOfWeekISO($aDateTime[$_pce_Yea], $aDateTime[$_pce_Mon], $aDateTime[$_pce_Day])) ; day of week
   Return True
EndFunc

