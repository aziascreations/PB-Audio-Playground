
;- Macros

; DO NOT use these macros with non-explicitely typed variables otherwise you will get invalid results.
Macro _GenerateBasicSineWave(Frequency, Amplitude, TimeOffset)
	(Amplitude * Sin(2 * #PI * Frequency * TimeOffset))
EndMacro

;Macro _GetStep
; Note: 1s/sampling rate - It's not that hard...


;- Procedures

Procedure.d GenerateBasicSineWave(Frequency.d, Amplitude.d, TimeOffset.d)
	ProcedureReturn _GenerateBasicSineWave(Frequency, Amplitude, TimeOffset)
EndProcedure

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 9
; Folding = -
; EnableXP