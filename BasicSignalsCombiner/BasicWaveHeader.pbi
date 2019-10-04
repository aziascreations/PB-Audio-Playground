;{- Code Header
; ==- Basic Info -================================
;         Name: BasicWaveHeader.pbi
;      Version: 0.0.2
;       Author: Herwin Bozet
;  Create date: 16 May 2019, ‏‎01:11:04
; 
;  Description: ???
; 
; ==- Compatibility -=============================
;  Compiler version: PureBasic 5.60-5.62 (x64) (Other versions untested)
;  Operating system: Windows (Other platforms untested)
; 
; ==- Links & License -===========================
;      Github: https://github.com/aziascreations/PB-Wave-File-Format
;        Doc.: https://github.com/aziascreations/PB-Wave-File-Format/???
;     License: Apache V2
;
;  References: http://tiny.systems/software/soundProgrammer/WavFormatDocs.pdf
;              https://fr.wikipedia.org/wiki/Waveform_Audio_File_Format
; 
;}

; TODO: Add it to PB-Utils
XIncludeFile "./EndianUtils.pbi"

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
	*Data
EndStructure

Structure WAVFormat
	RIFF.RIFFChunk
	fmt.fmtChunk
	dat.dataChunk
EndStructure


;- Procedures

Procedure CreateStaticWaveStructure(AudioFormat.w, NumChannels.w, SampleRate.l, BitsPerSample.w, SampleCount.l)
	Protected *Wav.WAVFormat = AllocateMemory(SizeOf(WAVFormat))
	
	If *Wav
		*Wav\RIFF\ChunkID = EndianSwapL($52494646) ;"RIFF"
		*Wav\RIFF\ChunkSize = 0
		*Wav\RIFF\Format = EndianSwapL($57415645) ;"WAVE"
		
		*Wav\fmt\Subchunk1ID = EndianSwapL($666d7420) ;"fmt "
		*Wav\fmt\Subchunk1Size = 16
		*Wav\fmt\AudioFormat = AudioFormat ; See linked PDF for more info about this one.
		*Wav\fmt\NumChannels = NumChannels
		*Wav\fmt\SampleRate = SampleRate
		*Wav\fmt\ByteRate = SampleRate * NumChannels * (BitsPerSample / 8)
		*Wav\fmt\BlockAlign = NumChannels * (BitsPerSample / 8)
		*Wav\fmt\BitsPerSample = BitsPerSample
		
		*Wav\dat\Subchunk2ID = EndianSwapL($64617461) ;"data"
		*Wav\dat\Subchunk2Size = SampleCount * NumChannels * (BitsPerSample / 8)
		
		*Wav\dat\Data = AllocateMemory(*Wav\dat\Subchunk2Size)
		
		If Not *Wav\dat\Data
			FreeMemory(*Wav)
			*Wav = #Null
		Else
			*Wav\RIFF\ChunkSize = 36 + *Wav\dat\Subchunk2Size
		EndIf
	EndIf
	
	ProcedureReturn*Wav
EndProcedure

Procedure FreeWaveStructure(*Wav.WAVFormat)
	If *Wav
		If *Wav\dat\Data
			FreeMemory(*Wav\dat\Data)
		EndIf
		FreeMemory(*Wav)
	EndIf
EndProcedure

Procedure UpdateStructureFields()
	
	
EndProcedure

Procedure ReplaceBuffer(*NewBuffer, FreeOldBuffer.b = #True, UpdateStructure.b = #True)
	
	
EndProcedure

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 26
; FirstLine = 4
; Folding = -
; EnableXP