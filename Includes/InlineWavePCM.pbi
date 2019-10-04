
; Too lazy to make the header.
; Pretty much the same shit as BasicWaveHeader.pbi, but it keeps everything in
;  a contiguous buffer for easier loading into the PB sound engine.

; Still no idea on how to handle big buffers and shit.
; Might have to use strctsunions.

;  References: http://tiny.systems/software/soundProgrammer/WavFormatDocs.pdf
;              https://fr.wikipedia.org/wiki/Waveform_Audio_File_Format

; FIXME: DO NOT FREE THE *DATA POINTER !!!!!

EnableExplicit

; TODO: Add it to PB-Utils
XIncludeFile "./Endianness.pbi"

; TODO: Check how to add a 2nd data chunk and the max size of one !!!

;- Constants

#WAVE_RIFFCHUNK_CHUNKID = $52494646
#WAVE_RIFFCHUNK_FORMAT_WAVE = $57415645

#WAVE_FMTCHUNK_SUBCHUNKID = $666d7420

#WAVE_DATACHUNK_SUBCHUNKID = $64617461


;- Structures

Structure RIFFChunk
	ChunkID.l	;BE
	ChunkSize.l	;LE
	Format.l	;BE
EndStructure

Structure fmtChunk
	Subchunk1ID.l	;BE
	Subchunk1Size.l	;LE (For the rest of the sub-chunk)
	AudioFormat.w
	NumChannels.w
	SampleRate.l
	ByteRate.l
	BlockAlign.w
	BitsPerSample.w
EndStructure

Structure dataChunk
	Subchunk2ID.l	;BE
	Subchunk2Size.l	;LE (For the rest of the sub-chunk)
					;*Data
EndStructure

Structure WAVE
	RIFF.RIFFChunk
	fmt.fmtChunk
	dat.dataChunk
	
	; Easier to access here
	; Used to point inside the contiguous memory area to avoid using an additional operand to figure out the offset every peek/poke
	; FIXME: DO NOT FREE IT !!!!!
	*Data
EndStructure

; Size of the struct without the data chunk and pointer associated to it.
CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
	; x86
	#WAVE_BASE_SIZE = SizeOf(WAVE) - 4
CompilerElse
	; x64
	#WAVE_BASE_SIZE = SizeOf(WAVE) - 8
CompilerEndIf


;- Procedures

; Defaults: 2 channels @ 48kbps??? 48k samples per sec, 16 bit depth & 30 secs ()
; TODO: Fix the signed long bullshit.
Procedure.i CreateInlineWaveStructure(ChannelCount.w = 2, SampleRate.l = 48000, BitsPerSample.w = 16, SampleCount.l = 1440000)
	Protected *Wave.WAVE = AllocateMemory(#WAVE_BASE_SIZE + (SampleCount * ChannelCount * (BitsPerSample / 8)))
	
	If *Wave
		*Wave\RIFF\ChunkID = EndianSwapL($52494646) ;"RIFF"
		*Wave\RIFF\ChunkSize = 0
		*Wave\RIFF\Format = EndianSwapL($57415645) ;"WAVE"
		
		*Wave\fmt\Subchunk1ID = EndianSwapL($666d7420) ;"fmt "
		*Wave\fmt\Subchunk1Size = 16
		*Wave\fmt\AudioFormat = 1 ; See linked PDF for more info about this one. (+ examples from old projects)
		*Wave\fmt\NumChannels = ChannelCount
		*Wave\fmt\SampleRate = SampleRate
		*Wave\fmt\ByteRate = SampleRate * ChannelCount * (BitsPerSample / 8)
		*Wave\fmt\BlockAlign = ChannelCount * (BitsPerSample / 8)
		*Wave\fmt\BitsPerSample = BitsPerSample
		
		*Wave\dat\Subchunk2ID = EndianSwapL($64617461) ;"data"
		*Wave\dat\Subchunk2Size = SampleCount * ChannelCount * (BitsPerSample / 8)
		
		;*Wave\dat\Data = AllocateMemory(*Wave\dat\Subchunk2Size)
		
		*Wave\Data = *Wave + #WAVE_BASE_SIZE
		*Wave\RIFF\ChunkSize = 36 + *Wave\dat\Subchunk2Size
	EndIf
	
	ProcedureReturn *Wave
EndProcedure

Procedure FreeWaveStructure(*Wave.WAVE)
	If *Wave
		FreeMemory(*Wave)
	EndIf
EndProcedure

Procedure.q GetWaveSampleCount(*Wave.WAVE)
	If *Wave
		ProcedureReturn *Wave\dat\Subchunk2Size / *Wave\fmt\NumChannels / (*Wave\fmt\BitsPerSample / 8)
	EndIf
	
	ProcedureReturn #False
EndProcedure

; A .q is used for the arithmetic and all the signed bullshit.
; Returns the new sample count or false if ...
Procedure ChangeWaveLength(*Wave.WAVE, NewSampleCount.q, AllowBufferGrowth.b = #False)
	If *Wave
		
	EndIf
	
	ProcedureReturn #False
EndProcedure



; TODO: make a thread procedure to swap shit.

CompilerIf #PB_Compiler_IsMainFile
	Define *Wave.WAVE = CreateInlineWaveStructure(2, 48000, 16, 5 * 48000)
	
	If *Wave
		Define Size.q = MemorySize(*Wave)
		Debug Str(Size) + " B"
		Debug Str(Size / 1024) + " KiB"
		Debug Str(Size / 1024 / 1024) + " MiB"
		
		Debug Str(GetWaveSampleCount(*Wave)) + " samples in WAVE (deducted)"
		
		FreeWaveStructure(*Wave)
	Else
		Debug "FUCK !"
	EndIf
CompilerEndIf

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 146
; FirstLine = 110
; Folding = --
; EnableXP