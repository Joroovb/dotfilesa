#!/usr/bin/env sh

## Add this to your wm startup file.

# Terminate already running bar instances
killall -q picom

# Wait until the processes have been shut down
while pgrep -u $UID -x picom >/dev/null; do sleep 1; done

# Launch Picom
picom --no-use-damage
