#!bin/sh
#
# Get hex rgb under mouse cursor. Put it into the clipboard and create a notification
#

eval $(xdotool getmouselocation --shell)
IMAGE=`import -window root --depth 8 -crop 1x1+$X+$Y txt:-`
COLOR=`echo $IMAGE | grep -om1 '#\w\+'`
echo -n $COLOR | xclip -i -selection clipboard
notify-send "Color under mouse cursor:" $COLOR
