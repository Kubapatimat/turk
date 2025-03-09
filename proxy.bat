@echo off
setlocal EnableDelayedExpansion

set "arg="
for %%a in (%*) do (
   if not defined arg (
      set "arg=%%a"
   ) else (
      set "!arg:~2!=%%a"
      set "arg="
   )
)

if /i "%connection%"=="tcp" (
    hub4com.exe ^
    --create-filter=escparse,com,parse ^
    --create-filter=pinmap,com,pinmap:"--rts=cts --dtr=dsr" ^
    --create-filter=linectl,com,lc:"--br=local --lc=local" ^
    --add-filters=0:com --create-filter=telnet,tcp,telnet:" --comport=client" ^
    --create-filter=pinmap,tcp,pinmap:"--rts=cts --dtr=dsr --break=break" ^
    --create-filter=linectl,tcp,lc:"--br=remote --lc=remote" ^
    --add-filters=1:tcp --octs=off "\\.\CNCB0" ^
    --use-driver=tcp "*localhost:5000" ^
    --baud=9600
) else if /i "%connection%"=="serial" (
    hub4com.exe ^
    --bi-route=2:0,1 ^
    --baud=9600 ^
    --no-default-fc-route=All:All ^
    --octs=off ^
    \\.\CNCB0 \\.\CNCB1 \\.\CNCB2
) else (
    echo Error: Missing or invalid --connection flag. Use:
    echo   --connection tcp     for TCP connection
    echo   --connection serial  for Serial connection
    exit /b 1
)