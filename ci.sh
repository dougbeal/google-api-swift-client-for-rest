#!/bin/bash
this=$( cd $(dirname ${BASH_SOURCE[0]}); pwd -P )
sg=$this/Source/Tools/ServiceGenerator/
echo watch $sg
fswatch --print0 -otvx --batch-marker $sg $this/run.sh --exclude .*build.* --exclude \.#.* | tee /dev/stderr | xargs -0 -n 1 -I {} bash $this/run.sh

