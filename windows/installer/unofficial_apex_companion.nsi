!include "MUI2.nsh"
!include "x64.nsh"

; Basic settings
Name "Unofficial Apex Companion"
OutFile "$%GITHUB_WORKSPACE%\unofficial-apex-companion-installer.exe"
InstallDir "$PROGRAMFILES\Unofficial Apex Companion"
RequestExecutionLevel admin

; MUI Settings
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Section "Install"
  SetOutPath "$INSTDIR"

  ; Copy all files from the Release folder
  File /r "$%GITHUB_WORKSPACE%\build\windows\x64\runner\Release\*.*"

  ; Create uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"

  ; Create Start Menu shortcuts
  CreateDirectory "$SMPROGRAMS\Unofficial Apex Companion"
  CreateShortcut "$SMPROGRAMS\Unofficial Apex Companion\Unofficial Apex Companion.lnk" "$INSTDIR\unofficial_apex_companion.exe" "" "$INSTDIR\unofficial_apex_companion.exe" 0
  CreateShortcut "$SMPROGRAMS\Unofficial Apex Companion\Uninstall.lnk" "$INSTDIR\uninstall.exe"

  ; Create Desktop shortcut
  CreateShortcut "$DESKTOP\Unofficial Apex Companion.lnk" "$INSTDIR\unofficial_apex_companion.exe" "" "$INSTDIR\unofficial_apex_companion.exe" 0

  ; Add to Add/Remove Programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\UnofficialApexCompanion" "DisplayName" "Unofficial Apex Companion"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\UnofficialApexCompanion" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\UnofficialApexCompanion" "DisplayVersion" "0.9.0"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\UnofficialApexCompanion" "Publisher" "Ajwad Tahmid"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\UnofficialApexCompanion" "DisplayIcon" "$INSTDIR\unofficial_apex_companion.exe"
SectionEnd

Section "Uninstall"
  ; Remove shortcuts
  RMDir /r "$SMPROGRAMS\Unofficial Apex Companion"
  Delete "$DESKTOP\Unofficial Apex Companion.lnk"

  ; Remove files
  RMDir /r "$INSTDIR"

  ; Remove registry entries
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\UnofficialApexCompanion"
SectionEnd
