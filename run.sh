#!/bin/bash
this=$( cd $(dirname ${BASH_SOURCE[0]}); pwd -P )
cd "$this/Source/Tools/ServiceGenerator/"
target="youtube:v3"
file="$this/Logs/youtube_v3.json"
if [ -e "$file" ]; then
    target="$file"
fi
xcodebuild install && /tmp/ServiceGenerator.dst/usr/local/bin/ServiceGenerator --outputDir $this/Output --apiLogDir $this/Logs --httpLogDir=$this/Logs  "$target" --verbose --verbose
