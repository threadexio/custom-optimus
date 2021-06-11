#!/usr/bin/bash

if [ "$(/usr/bin/optimus state)" -eq 1 ]; then
	prime-run $*
else
	$*
fi