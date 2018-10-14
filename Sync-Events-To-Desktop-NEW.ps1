###########################################################
# AV Sync-Events Content from X:drive to Desktop Script
#
# (C) 2018 Daniel Fairhead <daniel.fairhead@om.org>
#
# -----
# Runs every night, and manually before events by the AV operator
#
#####################
#
# TODO: what if there is no 'Events' Folder?
# TODO: take which venue to use from configuration somehow
#
# TODO: nested / recursive shortcuts.
# TODO: Log how often files are needed but not in the cache.

# configuration values:

param([string]$VENUENAME=$(Read-Host "Which Venue? (Logos Lounge, Hope Theatre, etc"))

$OriginalPath = "\\gba-lh-fs1\Scratch\AV\Events\$VENUENAME Events"
$Desktop = [Environment]::GetFolderPath("Desktop")
$NewPath = "$Desktop\Events\"

# to save network bandwidth and be faster, here's a cache:
$ServerAVPlayoutFolder = "I:\Public Ministries\Events\AV PLAYOUT FOR LATIN AMERICA\"
$LocalAVPlayoutCache = "C:\-- AV PLAYOUT SYNC\"

# TODO: Bring the whole cache locally on all computers?  Or at least the big / most used ones?

# End script on first error, or at least make them work correctly w/ try {} catch {} blocks.
$ErrorActionPreference = "Stop"

# Debugging Display Level.
# - The default is not to display display-debug messages.
$InformationPreference = 'Continue'

#$DebugPreference = 'Continue' #show debugging messages.

###############################################################################
#
# Notes to the future reader:
#
# - Powershell is nuts.  So much crazy.
#
# - Functions return as their return value not just what you tell it to return,
#   but also anything in their 'output stream'.
#   So Write-Output outside of a function writes to the output.  Inside a function,
#   adds it to what is returned.  BEWARE.
#
# - Sometimes it may try to interpret paths with [brackets][etc] as pattern matching,
#   so you've got to shove '-LiteralPath' all over the place.
# 
# - Get-ChildItem doesn't return the file objects, but strings telling you the names
#   of the child objects.
#
# - Good Luck.
#
################################################################################

# get some command shell
$sh = New-Object -ComObject WScript.Shell

###############################################################################
#
# Functions:
#
###############################################################################

###################################################
#
# compare-file (fromFileName, toFileName)
#
# - compares file size and last modified times of 2 files, returning if they match.
#

# Return Codes:
$ORIGINAL_DOESNT_EXIST = 1
$NEWFILE_DOESNT_EXIST = 2
$FILES_DIFFER = 3
$FILES_SAME = 4

function compare-file {
    param([string]$FromFileName, [string]$ToFileName)

    # Ensure files exist:
    try { $FromFile = Get-Item -literalpath $FromFileName } catch { return $ORIGINAL_DOESNT_EXIST }
    try { $ToFile = Get-Item -literalpath $ToFileName } catch { return $NEWFILE_DOESNT_EXIST }

    # Check if size and last-modified-time are equal:

    if ($FromFile.Length -eq $ToFile.Length) {
        Write-Debug "Same Length..."
        if ($FromFile.LastWriteTime -eq $ToFile.LastWriteTime) {
            Write-Debug "same mtime..."
            return $FILES_SAME
        } else {
            return $FILES_DIFFER
        }
        Write-Debug "SAME: $FromFileName - $ToFileName"
        return $FILES_SAME
    } else {
        Write-Debug "DIFFERENT: $FromFileName => $ToFileName"
        return $FILES_DIFFER
    }
}

#####################################
#
# exists-in-cache($file)
#
# - Checks the local playout sync cache, and if the original file is in the cache
#   returns the filename of the cached version instead.
#
# NOTE:
# - This is currently very basic, only testing shortcuts to original files in the same
#   layout as cache folder.  If someone puts the original file in place on the drive,
#   rather than a short-cut, it won't detect that.  It would be better if it did.
# - It would also be really cool if instead of copying, we could just make hard-links
#   if it was on the same hard-drive.

function exists-in-cache {
    param([System.IO.FileInfo]$originalfile)
    if (!$originalfile.FullName.StartsWith("I:")) { return }

    $cachefile = $originalfile.FullName.Replace($ServerAVPlayoutFolder, $LocalAVPlayoutCache)

    if ((compare-file $originalfile $cachefile) -eq 4) {
        return $cachefile
    }

}

##################################
#
# copy-file-only-if-needed($from, $to)
#
# - uses compare-file to see if a file needs copying, and if so, copy it over.

# Now copy new events over.

function copy-file-only-if-needed {
    param([System.IO.FileInfo]$originallocation, [string]$newlocation)

    $comparestate = (compare-file $originallocation $newlocation)
    
    if ($comparestate -eq 4) {
        Write-Debug "$f Does not need copying."
    } else {
        #Write-Information "$f ($target) syncing down... ($comparestate)"
        Write-Debug "Getting $originallocation (why: $comparestate)"
        $basename = $originallocation.BaseName
        Write-Information "Downloading $basename"
        
        $cached = exists-in-cache $originallocation
        if ($cached) {
            $originallocation = Get-Item -LiteralPath "$cached"
            Write-Information "using cached file"
            # - It would also be really cool if instead of copying, we could just make hard-links
            #   if it was on the same hard-drive.
        }

        cmd /c copy /z /y $originallocation $newlocation
        #Copy-Item -LiteralPath $fullolditem (Join-Path $ToDir $f)
        # TODO: investigate using BITS? copying, rather than an external cmd.
        # TODO: hard links to local dir, rather than copy from network all files again and again.
    }
}

##########################################################
#
# sync-dir
# - the actual main complex function of it all, copying files, creating folders,
#   and checking that with shortcuts, the original files are copied, not the shortcut itself.

function sync-dir {
    param([System.IO.DirectoryInfo]$FromDir, [string]$ToDirName) #[System.IO.DirectoryInfo]$ToDir)

    Write-Debug "Syncing $FromDir -> $ToDirName"
    $localname = $ToDirName.Substring($NewPath.Length)
    Write-Information "$localname"

    if (! (Test-Path -pathtype Container $ToDirName) ) {
        Write-Information "creating new directory $ToDirName"
        New-Item -path $ToDirName -ItemType directory -Force
    }

    $ToDir = Get-Item -LiteralPath $ToDirName

    
    foreach ($f in (Get-ChildItem($FromDir))) {
        $fullolditem = get-item -literalPath (Join-Path $FromDir $f)

        if (Test-Path -PathType Container -literalPath $fullolditem) {
            sync-dir $fullolditem (join-path $ToDir $f)
        } else {
            # Actual file! (Or shortcut...)

            if ($f.extension -eq ".lnk") {
                #"shortcut!"
                try {
                    $target = (get-item -literalPath $sh.CreateShortcut($f.FullName).TargetPath)
                } catch {
                    Write-Information "Sorry! Bad Shortcut! ($f)"
                    Copy-Item -literalPath $f.fullName (join-path $ToDir $f)
                    continue
                }

                if (Test-Path -PathType Container -literalPath $target) {

                    write-debug "Following Shortcut to directory" 

                    sync-dir $target (join-path $ToDir ($f.baseName))

                } else {
                    Write-Debug "It's a shortcut to a file"

                    # figure out a decent name for the file to end up being - shortcuts often drop the correct
                    # file type extension (.mp4, .mov, etc.) and replace it with .lnk (link).  They also often
                    # end up with ' - Shortcut' added in.  We ain't got time for that, we just want a decently
                    # named file in the correct place:

                    $newfilename = $f.basename
                    if ($newfilename.endswith(" - Shortcut")) {
                        $newfilename = $newfilename.substring(0, $newfilename.length - " - Shortcut".Length)
                    }
                    if (! $newfilename.endswith($target.Extension) ) {
                        $newfilename = $newfilename + $target.Extension
                    }
                    
                    copy-file-only-if-needed $target (Join-Path $ToDir $newfilename)

                }
            } else {

                copy-file-only-if-needed $fullolditem (Join-Path $ToDir $f)
                
            }
        }
    }
}


############################################################################
#
# Now actually start work:
#
############################################################################

# quit if we're not connected to the network correctly
$can_see_folder = Test-Path($OriginalPath)
Write-Information $OriginalPath
if (! $can_see_folder) {
    Write-host "Failed! I can't connect to the server correctly..." -BackgroundColor Red -ForegroundColor Black
    exit(1)
}

write-output "OK, I can connect to the server, so I'll start copying now."

# delete old events:
$events = Get-ChildItem($NewPath)

foreach ($event in $events) {
    if (!(test-path(join-path $OriginalPath $event))) {
        write-output "deleting local copy of '$event'!"
        try {
            Remove-Item -Path (Join-Path $NewPath $event) -Recurse
        } catch {
            Write-Host "Failed to delete $event!" -BackgroundColor Red -ForegroundColor Black
        }
    }
}

$events = Get-ChildItem($OriginalPath)

foreach ($event in $events) {
    write-host "Syncing Event: $event" -BackgroundColor white -ForegroundColor Black

    sync-dir (get-item -literalPath $event.FullName) (join-path $NewPath $event)

}


#Add-Type -AssemblyName PresentationFramework
#[System.Windows.MessageBox]::Show('done!')
