REM - This file should be identical to the sync_PP_songs.bat - EXCEPT without the -batch option
REM -   this means that instead of skipping files when it's unsure, it will ask for user input.

REM - generally you press < (or ,) to sync a file from the network to the local machine
REM -   or > (or .) to sync from the computer to the network.
REM -   and when it asks if you want to do it, press 'y' for "yes".


"unison 2.48.4 text.exe" ^
    "C:\Users\avoperator\Documents\ProPresenter6" ^
    "I:\Public Ministries\AV Team\02 - Sync Data & Backups\5 - ProPresenter 6\SYNC_ProPresenter6\__Documents\Default" ^
    -auto

"unison 2.48.4 text.exe" ^
    "C:\ProgramData\RenewedVision\ProPresenter6\Templates" ^
    "I:\Public Ministries\AV Team\02 - Sync Data & Backups\5 - ProPresenter 6\SYNC_ProPresenter6\__Templates" ^
    -auto
