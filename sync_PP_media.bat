REM sync Media files - fastcheck on so you don't need to scan contents of all the files.

"unison 2.48.4 text.exe" ^
    "C:\ProgramData\Renewed Vision Media" ^
    "I:\Public Ministries\AV Team\02 - Sync Data & Backups\5 - ProPresenter 6\SYNC_ProPresenter6\__Media" ^
    -force "I:\Public Ministries\AV Team\02 - Sync Data & Backups\5 - ProPresenter 6\SYNC_ProPresenter6\__Media" ^
    -auto -batch
    -fastcheck

"unison 2.48.4 text.exe" ^
    "C:\ProgramData\RenewedVision\ProPresenter6" ^
    "I:\Public Ministries\AV Team\02 - Sync Data & Backups\5 - ProPresenter 6\SYNC_ProPresenter6\__User_Data" ^
    -ignore "Name ?*" ^
    -ignorenot "Name Audio.pro6pl" ^
    -ignorenot "Name Media.pro6pl" ^
    -auto -batch ^