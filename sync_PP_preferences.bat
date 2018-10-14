"unison 2.48.4 text.exe" ^
    "C:\ProgramData\RenewedVision\ProPresenter6" ^
    "I:\Public Ministries\AV Team\02 - Sync Data & Backups\5 - ProPresenter 6\SYNC_ProPresenter6\__User_Data" ^
    -ignore "Name ?*" -auto -batch ^
    -ignorenot "Name messageData.pro6data" -auto -batch ^
    -ignorenot "Name countdownTimers.pro6data" -auto -batch^
    -ignorenot "Name toolbar.pro6data" -auto -batch ^
    -ignorenot "Name UISettings.pro6data" -auto -batch ^
    -ignorenot "Name Props.pro6" -auto -batch ^
    -ignorenot "Name Preferences" -auto -batch ^
    -ignorenot "Name SocialMedia.pro6Template" -auto -batch ^
    -ignorenot "Path Preferences/LabelsPreferences.pro6pref" -auto -batch ^
    -force "newer" ^
    -auto -batch

rem    -ignorenot "Name Audio.pro6pl"
rem    -ignorenot "Name Media.pro6pl" ^
rem these files are sync'd by the media sync script, so metadata and media stay in sync

"I:\Public Ministries\AV Team\02 - Sync Data & Backups\0 - Software & Drivers\Computer sync scripts\sync_PP_media.bat"