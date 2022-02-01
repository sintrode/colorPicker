::------------------------------------------------------------------------------
:: NAME
::     Color Picker
::
:: DESCRIPTION
::     Manually set RGB values to find the ideal background and text colors.
::     VT100 sequence capability is mandatory.
::
:: AUTHOR
::     sintrode
::------------------------------------------------------------------------------
@echo off
setlocal enabledelayedexpansion
echo [?25l
cls

::Initialization
set "selected_row=1"
for %%A in (1`7`"RED:  "`0`"40;37"
            2`8`"GREEN:"`0`"40;37"
            3`9`"BLUE: "`0`"40;37"
            4`12`"RED:  "`255`"40;37"
            5`13`"GREEN:"`255`"40;37"
            6`14`"BLUE: "`255`"40;37") do (
	for /f "tokens=1-5 delims=`" %%B in ("%%A") do (
		set "row[%%B].line=%%C"
		set "row[%%B].label=%%~D"
		set "row[%%B].color=%%E"
		set "row[%%B].select_color=%%~F"
	)
)

:: Constants (note: case-sensitive)
set "small_decrement=a"
set "large_decrement=A"
set "small_increment=d"
set "large_increment=D"
set "select_up=w"
set "select_down=s"
set "quit=q"
set "small_value=1"
set "large_value=10"

:select_color
set "row[%selected_row%].select_color=30;47"
set "bg_color=[48;2;%row[1].color%;%row[2].color%;%row[3].color%m"
set "fg_color=[38;2;%row[4].color%;%row[5].color%;%row[6].color%m"
for /L %%A in (1,1,6) do (
	set "row[%%A].display_color=000!row[%%A].color!"
	set "row[%%A].display_color=!row[%%A].display_color:~-3!"
)

echo [0m[1;1H################################################################
echo #%bg_color%%fg_color%                     This is sample text.                     [0m#
echo ################################################################[2B
echo BACKGROUND[5B[10DTEXT

for /L %%A in (1,1,6) do (
	echo [!row[%%A].line!;5H!row[%%A].label! ^<^< [!row[%%A].select_color!m!row[%%A].display_color![0m ^>^>
)

%systemroot%\System32\choice.exe /c:%large_decrement%%small_decrement%%select_up%%select_down%%small_increment%%large_increment%%quit% /CS /n >nul
if "%errorlevel%"=="1" set /a row[%selected_row%].color-=%large_value%
if "%errorlevel%"=="2" set /a row[%selected_row%].color-=%small_value%
if "%errorlevel%"=="5" set /a row[%selected_row%].color+=%small_value%
if "%errorlevel%"=="6" set /a row[%selected_row%].color+=%large_value%
if !row[%selected_row%].color! LSS 0 set "row[%selected_row%].color=0"
if !row[%selected_row%].color! GTR 255 set "row[%selected_row%].color=255"
if %errorlevel% GEQ 3 if %errorlevel% LEQ 4 set "row[%selected_row%].select_color=40;37"
if "%errorlevel%"=="3" set /a selected_row-=1
if "%errorlevel%"=="4" set /a selected_row+=1
if %selected_row% LSS 1 set "selected_row=1"
if %selected_row% GTR 6 set "selected_row=6"
if "%errorlevel%"=="7" (
	echo [?25h
	exit /b
)
goto :select_color