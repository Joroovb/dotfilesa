#!/bin/bash

click_action () {
	i3-msg [class="Whatsapp-for-linux"] focus
}
handle_dismiss () {
	echo "gaaf"
}

## Arguments

# 1 is Sender name
# 2 is Message

ACTION=$(dunstify -i ~/.config/dunst/whatsapp.png --action="default,Reply" "$2" "$3" )

case "$ACTION" in
"default")
    click_action
    ;;
"2")
    handle_dismiss
    ;;
esac