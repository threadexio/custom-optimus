#!/usr/bin/bash

disable_vsync="${NO_VSYNC:=0}"

if [ "$disable_vsync" -ne 0 ]; then
	export vblank_mode=0 __GL_SYNC_TO_VBLANK=0
fi

if [ "$(/usr/bin/optimus state)" -eq 1 ]; then
	exec prime-run $*
else
	exec $*
fi
