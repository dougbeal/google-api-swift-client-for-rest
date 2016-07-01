#!/bin/bash
this=$( cd $(dirname ${BASH_SOURCE[0]}); pwd -P )
cd $this/Source/Tools/ServiceGenerator/
xcodebuild install && /tmp/ServiceGenerator.dst/usr/local/bin/ServiceGenerator --outputDir $this/Output --apiLogDir $this/Logs --httpLogDir=$this/Logs  youtube:v3 --verbose --verbose
