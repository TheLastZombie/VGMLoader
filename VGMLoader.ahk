; Prompt for VGM album URL
InputBox, VGMSITE, VGMLoader v1.8.1, Please enter an album URL., , 500, 125, , , , , https://downloads.khinsider.com/game-soundtracks/album/

; If not cancelled
If !ErrorLevel {

	; If URL is valid
	If RegExMatch(VGMSITE, "downloads\.khinsider\.com\/game-soundtracks\/album\/[^/]+", VGMSITE) {
		Progress, 0, Preparing..., Please wait..., VGMLoader v1.8.1

		; Get site from URL
		VGMSITE = https://%VGMSITE%
		UrlDownloadToFile, %VGMSITE%, VGMLoader.html
		FileRead, VGMSITE, VGMLoader.html
		FileDelete, VGMLoader.html

		; Get album title
		RegExMatch(VGMSITE, "<h2>.+</h2>", VGMALBUM)
		StringTrimLeft, VGMALBUM, VGMALBUM, 4
		StringTrimRight, VGMALBUM, VGMALBUM, 5

		; If album not found
		IfEqual, VGMALBUM, Ooops!
		Goto, VGMINVALID

		; Ask for audio codec
		Progress, OFF
		Gui, Add, Text, , Please choose your preferred audio codec.
		Gui, Add, Radio, vVGM1AUDIO gVGMDCODEC, MP3
		If RegExMatch(VGMSITE, "click to download&nbsp;\(.*FLAC.*\)")
			Gui, Add, Radio, vVGM2AUDIO gVGMDCODEC, FLAC
		If RegExMatch(VGMSITE, "click to download&nbsp;\(.*OGG.*\)")
			Gui, Add, Radio, vVGM3AUDIO gVGMDCODEC, OGG
		If RegExMatch(VGMSITE, "click to download&nbsp;\(.*M4A.*\)")
			Gui, Add, Radio, vVGM4AUDIO gVGMDCODEC, M4A
		If RegExMatch(VGMSITE, "click to download&nbsp;\(.*WAV.*\)")
			Gui, Add, Radio, vVGM5AUDIO gVGMDCODEC, WAV
		Gui, Show, , VGMLoader v1.8.1
		Return
		VGMDCODEC:
			Gui, Submit
			Gui, Destroy
		Progress, 0, Preparing..., Please wait..., VGMLoader v1.8.1
		If VGM1AUDIO
			VGMFORMAT = MP3
		If VGM2AUDIO
			VGMFORMAT = FLAC
		If VGM3AUDIO
			VGMFORMAT = OGG
		If VGM4AUDIO
			VGMFORMAT = M4A
		If VGM5AUDIO
			VGMFORMAT = WAV

		; Prompt for output directory
		Progress, OFF
		FileSelectFolder, VGMDIR, *%A_WorkingDir%, , Please select the destination folder.

		; If not cancelled
		If !Errorlevel {

			; Switch to output directory
			SetWorkingDir, %VGMDIR%

			; Prompt for album subfolder
			MsgBox, 3, VGMLoader v1.8.1, Create a new subfolder with the album's title (%VGMALBUM%)?

			; Create album subfolder on demand
			IfMsgBox, Yes
				FileCreateDir, %VGMALBUM%
				SetWorkingDir, %VGMALBUM%

			; Exit on demand
			IfMsgBox, Cancel
				ExitApp, 0

			; Prompt for download method
			Progress, 0, Preparing..., Please wait..., VGMLoader v1.8.1
			Gui, Add, Text, , VGMLoader found the following supported tools.`rPlease choose your preferred download program.
			VGM1PATH := ComObjCreate("WScript.Shell").Exec("cmd.exe /c where aria2c.exe").StdOut.ReadAll()
			VGM3PATH := ComObjCreate("WScript.Shell").Exec("cmd.exe /c where curl.exe").StdOut.ReadAll()
			VGM4PATH := ComObjCreate("WScript.Shell").Exec("cmd.exe /c where http.exe").StdOut.ReadAll()
			VGM5PATH := ComObjCreate("WScript.Shell").Exec("cmd.exe /c where httrack.exe").StdOut.ReadAll()
			VGM9PATH := ComObjCreate("WScript.Shell").Exec("cmd.exe /c where pwsh.exe").StdOut.ReadAll()
			VGM7PATH := ComObjCreate("WScript.Shell").Exec("cmd.exe /c where wget.exe").StdOut.ReadAll()
			VGM6PATH := ComObjCreate("WScript.Shell").Exec("cmd.exe /c where powershell.exe").StdOut.ReadAll()
			If VGM1PATH
				Gui, Add, Radio, vVGM1CHOICE gVGMDLOAD, aria2
			Gui, Add, Radio, vVGM2CHOICE gVGMDLOAD, AutoHotkey
			If VGM3PATH
				Gui, Add, Radio, vVGM3CHOICE gVGMDLOAD, cURL
			If VGM4PATH
				Gui, Add, Radio, vVGM4CHOICE gVGMDLOAD, HTTPie
			If VGM5PATH
				Gui, Add, Radio, vVGM5CHOICE gVGMDLOAD, HTTrack
			If VGM9PATH
				Gui, Add, Radio, vVGM9CHOICE gVGMDLOAD, PowerShell
			If VGM7PATH
				Gui, Add, Radio, vVGM7CHOICE gVGMDLOAD, Wget
			If VGM6PATH
				Gui, Add, Radio, vVGM6CHOICE gVGMDLOAD, Windows PowerShell
			Gui, Add, Text, , Or configure special download behaviour.
			Gui, Add, Radio, vVGM8CHOICE gVGMDLOAD, Write links to file
			Progress, OFF
			Gui, Show, , VGMLoader v1.8.1
			Return
			VGMDLOAD:
				Gui, Submit
				Gui, Destroy

			; Get number of files
			Progress, 0, Preparing..., Please wait..., VGMLoader v1.8.1
			RegExMatch(VGMSITE, "Number of Files: <b>.+<\/b><br>", VGMAMOUNT)
			StringTrimLeft, VGMAMOUNT, VGMAMOUNT, 20
			StringTrimRight, VGMAMOUNT, VGMAMOUNT, 8

			; Get track URLs
			VGMLOOP = 1
			VGMCURRENT = 0
			While VGMLOOP := RegExMatch(VGMSITE,"<td class=""clickable-row""><a href="".+"">", VGMTRACK, VGMLOOP + StrLen(VGMTRACK)) {

				; Download track site
				VGMCURRENT += 1
				VGMPROGRESS := (VGMCURRENT - 1) / VGMAMOUNT * 100
				Progress, %VGMPROGRESS%, Downloading track %VGMCURRENT% of %VGMAMOUNT%..., Downloading %VGMALBUM%...
				StringTrimLeft, VGMTRACK, VGMTRACK, 35
				StringTrimRight, VGMTRACK, VGMTRACK, 2
				VGMTRACK = https://downloads.khinsider.com%VGMTRACK%
				If VGM1CHOICE
					RunWait, aria2c --check-certificate=false %VGMTRACK% -o VGMLoader.html, , Hide
				If VGM2CHOICE or VGM8CHOICE
					UrlDownloadToFile, %VGMTRACK%, VGMLoader.html
				If VGM3CHOICE
					RunWait, curl -k %VGMTRACK% -o VGMLoader.html, , Hide
				If VGM4CHOICE
					RunWait, http --verify=no %VGMTRACK% > VGMLoader.html, , Hide
				If VGM5CHOICE
					RunWait, httrack -g %VGMTRACK% -N VGMLoader.html, , Hide
				If VGM9CHOICE
					RunWait, pwsh -c iwr %VGMTRACK% -outf VGMLoader.html, , Hide
				If VGM7CHOICE
					RunWait, wget --no-check-certificate %VGMTRACK% -O VGMLoader.html, , Hide
				If VGM6CHOICE
					RunWait, powershell iwr %VGMTRACK% -outf VGMLoader.html, , Hide
				FileRead, VGMTRACK, VGMLoader.html
				FileDelete, VGMLoader.html

				; Download track itself
				RegExMatch(VGMTRACK, "<p><a style=""color: #21363f;"" href="".+""><span class=""songDownloadLink""><i class=""material-icons"">get_app<\/i>Click here to download as " . VGMFORMAT . "<\/span><\/a><\/b>", VGMTRACK)
				StringTrimLeft, VGMTRACK, VGMTRACK, 36
				StringTrimRight, VGMTRACK, VGMTRACK, 111 + StrLen(VGMFORMAT)
				SplitPath, VGMTRACK, VGMFILE

				; Decode URL characters
				Loop
					If RegExMatch(VGMFILE, "i)(?<=%)[\da-f]{1,2}", VGMHEX)
						StringReplace, VGMFILE, VGMFILE, `%%VGMHEX%, % Chr("0x" . VGMHEX), All
					Else
						Break
				If VGM1CHOICE
					RunWait, aria2c --check-certificate=false "%VGMTRACK%" -o "%VGMFILE%", , Hide
				If VGM2CHOICE
					UrlDownloadToFile, %VGMTRACK%, %VGMFILE%
				If VGM3CHOICE
					RunWait, curl -k "%VGMTRACK%" -o "%VGMFILE%", , Hide
				If VGM4CHOICE
					RunWait, http --verify=no "%VGMTRACK%" > "%VGMFILE%", , Hide
				If VGM5CHOICE
					RunWait, httrack -g "%VGMTRACK%" -N "%VGMFILE%", , Hide
				If VGM9CHOICE {
					VGMTRACK := StrReplace(VGMTRACK, "'", "''")
					VGMFILE := StrReplace(VGMFILE, "'", "''")
					RunWait, pwsh -c iwr '%VGMTRACK%' -outf '%VGMFILE%', , Hide
				}
				If VGM7CHOICE
					RunWait, wget --no-check-certificate "%VGMTRACK%" -O "%VGMFILE%", , Hide
				If VGM6CHOICE {
					VGMTRACK := StrReplace(VGMTRACK, "'", "''")
					VGMFILE := StrReplace(VGMFILE, "'", "''")
					RunWait, powershell iwr '%VGMTRACK%' -outf '%VGMFILE%', , Hide
				}
				If VGM8CHOICE
					FileAppend, %VGMTRACK%`n, VGMLoader.txt
			}

			; Finished message popup
			Progress, OFF
			MsgBox, , VGMLoader v1.8.1, Success: %VGMALBUM% has been downloaded.
			ExitApp, 0
		} Else {
			ExitApp, 0
		}
	} Else {

		; If URL is invalid
		Goto, VGMINVALID
	}
}
ExitApp, 0

; If URL invalid or album not found
VGMINVALID:
Progress, OFF
MsgBox, , VGMLoader, Error: Entered URL does not appear to be a valid VGM album URL.
ExitApp, 1
