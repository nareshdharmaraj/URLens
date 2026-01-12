; URLens Windows Installer Script
; Requires Inno Setup: https://jrsoftware.org/isdl.php

[Setup]
AppName=URLens
AppVersion=1.0.0
AppPublisher=PathMakers
AppPublisherURL=https://github.com/nareshdharmaraj
DefaultDirName={autopf}\URLens
DefaultGroupName=URLens
OutputDir=C:\Users\nares\AndroidStudioProjects\URLens
OutputBaseFilename=URLens-Setup-1.0.0-Windows
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
SetupIconFile=C:\Users\nares\AndroidStudioProjects\URLens\logo.png
UninstallDisplayIcon={app}\urlens.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"

[Files]
Source: "C:\Users\nares\AndroidStudioProjects\URLens\frontend\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\URLens"; Filename: "{app}\urlens.exe"
Name: "{group}\Uninstall URLens"; Filename: "{uninstallexe}"
Name: "{autodesktop}\URLens"; Filename: "{app}\urlens.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\urlens.exe"; Description: "Launch URLens"; Flags: nowait postinstall skipifsilent
