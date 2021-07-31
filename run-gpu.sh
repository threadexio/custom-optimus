#!/usr/bin/bash

if [ "$(/usr/bin/optimus state)" -eq 1 ]; then
	exec prime-run $*
else
	exec $*
fi
