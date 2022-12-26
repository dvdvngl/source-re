# kakathic
# Tải Youtube
VERSION="17-49-37"

Taiyt () {
Upk="https://www.apkmirror.com"
Url1="$(curl -s -k -L -G -H "$User" "$Upk/apk/google-inc/youtube/youtube-17-49-37//./-}-release/youtube-17-49-37//./-}$2-android-apk-download/" | grep -m1 'downloadButton' | tr ' ' '\n' | grep -m1 'href=' | cut -d \" -f2)"
Url2="$Upk$(curl -s -k -L -G -H "$User" "$Upk$Url1" | grep -m1 '>here<' | tr ' ' '\n' | grep -m1 'href=' | cut -d \" -f2)"
curl -s -k -L -H "$User" $Url2 -o $Likk/lib/$1
}

echo "
- Download YouTube: 17-49-37"
Taiyt 'YouTube.apk' '-2'
Taiyt 'YouTube.apks'

if [ ! -e $Likk/lib/YouTube.apk ];then
echo "
- Lỗi tải Youtube.apk
"
exit 0
fi

echo "
- Complete"