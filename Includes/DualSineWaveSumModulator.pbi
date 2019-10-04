XIncludeFile "./Commons.pbi"

; This is just a test for the DTMF encoder based on waveform observations.

;- Macros

; DO NOT use this macro with non-explicitely typed variables otherwise you will get invalid results.
Macro _DualWaveSumModulator(Freq1, Freq2, Amp1, Amp2, TimeOffset)
	((_GenerateBasicSineWave(Freq1, Amp1, TimeOffset) + _GenerateBasicSineWave(Freq2, Amp2, TimeOffset)) / (Amp1 + Amp2))
EndMacro


;- Procedures

Procedure.d DualWaveSumModulator(Freq1.d, Freq2.d, Amp1.d, Amp2.d, TimeOffset.d)
	ProcedureReturn _DualWaveSumModulator(Freq1, Freq2, Amp1, Amp2, TimeOffset)
EndProcedure


;- Tests

CompilerIf #PB_Compiler_IsMainFile
	; DTMF keypad 1 csv test - Looks good.
	Debug "step;amplitude"
	
	For i.i=1 To 3000
		;Debug Str(i)+";"+StrD(BasicSineWave(10, 1, (0.001 * i) ))
		
		Debug Str(i)+";"+StrD(DualWaveSumModulator(697, 1209, 1.0, 1.0, (1/420/100)*i ))
	Next
CompilerEndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; Folding = -
; EnableXP