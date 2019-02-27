#!/bin/bash
for n in `seq 1 16` ; do date ; qstat -u brettin ; sleep 1800 ; done
