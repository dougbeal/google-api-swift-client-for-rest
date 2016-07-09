#!/bin/bash
this=$( cd $(dirname ${BASH_SOURCE[0]}); pwd -P )
sg=$this/Source/Tools/ServiceGenerator/
echo watch $sg
files=$(find $sg -name \*.m -or -name \*.h -or -name \*.swift)
echo "files ${files}"
fswatch --print0 -otvx --batch-marker $files  $this/run.sh --exclude .*build.* --exclude \.#.* | xargs -0 -n 1 -I {} bash $this/run.sh | tee $this/Logs/ci.log

