"unison 2.48.4 text.exe" ^
    "C:\ProgramData\RenewedVision\ProPresenter6" ^
    "I:\Public Ministries\AV Team\02 - Sync Data & Backups\5 - ProPresenter 6\SYNC_ProPresenter6\__User_Data" ^
    -ignore "Name ?*" ^
    -ignorenot "Name messageData.pro6data" ^
    -ignorenot "Name countdownTimers.pro6data" ^
    -ignorenot "Name stageDisplayLayouts.pro6data" ^
    -ignorenot "Name toolbar.pro6data" ^
    -ignorenot "Name UISettings.pro6data" ^
    -ignorenot "Name Props.pro6" ^
    -ignorenot "Name Preferences" ^
    -ignorenot "Name SocialMedia.pro6Template" ^
    -ignorenot "Path Preferences/LabelsPreferences.pro6pref" ^

rem    -ignorenot "Name Audio.pro6pl"
rem    -ignorenot "Name Media.pro6pl" ^
rem these files are sync'd by the media sync script, so metadata and media stay in sync