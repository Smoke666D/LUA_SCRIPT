Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.3.2091/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "C:\PS\WinGet.msixbundle"
winget install --id=Python.Python.3.2 -e  ; winget install --id=rjpcomputing.luaforwindows -e
pip install luaparser