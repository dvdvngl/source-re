#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

out() {
	# print a message
	printf '%b\n' "$@"
}
notset() {
	case $1 in '') return 0 ;; *) return 1 ;; esac
}

equals() {
	case $1 in "$2") return 0 ;; *) return 1 ;; esac
}

# Export versions used for the Magisk Module
export magiskMusic="v5.24.50"
export magiskYouTube="v17.33.42"

# Export versions used for the Magisk Module
export magiskMusic="v5.24.50"
export magiskYouTube="v17.33.42"


# Artifacts associative array aka dictionary
declare -A artifacts

artifacts["revanced-cli.jar"]="revanced/revanced-cli revanced-cli .jar"
artifacts["revanced-integrations.apk"]="revanced/revanced-integrations app-release-unsigned .apk"
artifacts["revanced-patches.jar"]="Lyceris-chan/revanced-patches revanced-patches .jar"

get_artifact_download_url () {
    # Usage: get_download_url <repo_name> <artifact_name> <file_type>
    local api_url="https://api.github.com/repos/$1/releases/latest"
    local result=$(curl $api_url | jq ".assets[] | select(.name | contains(\"$2\") and contains(\"$3\") and (contains(\".sig\") | not)) | .browser_download_url")
    echo ${result:1:-1}
}

# Fetch all the dependencies
for artifact in "${!artifacts[@]}"; do
    if [ ! -f $artifact ]; then
        echo "Downloading $artifact"
        curl -L -o $artifact $(get_artifact_download_url ${artifacts[$artifact]})
    fi
done


# Download the following apk's from APKmirror

youtube=no
music=no
twitter=no
reddit=no
tiktok=yes

while getopts mr flag
do
    case "${flag}" in
        m) music=yes;;
        y) youtube=yes;;
        t) twitter=yes;;
        r) reddit=yes;;
        k) tiktok=yes;;
    esac
done



youtubeVersion="17-33-42"
musicVersion="5-24-50"
twitterVersion="9-58-1-release-1"
redditVersion="2022-34-0"
tiktokVersion="27.0.3"

declare -A apks

# YouTube Music builds for the following architectures are currently commented out as they don't appear to be building 
# properly right now if these do end up getting fixed in the future and if there are people needing them I'll look into re-enabling them.

apks["youtube.apk"]=dl_yt
apks["music-arm.apk"]=dl_ytm_arm
apks["music-arm64.apk"]=dl_ytm_arm64
# apks["music-x86.apk"]=dl_ytm_x86
# apks["music-x86_64.apk"]=dl_ytm_x86_64
apks["twitter.apk"]=dl_twitter
apks["reddit.apk"]=dl_reddit
apks["tiktok.apk"]=dl_tiktok


## Functions

# Wget user agent
WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0"

# Wget function
req() { wget -nv -O "$2" --header="$WGET_HEADER" "$1"; }

get_latest_version_info() {
	out "${BLUE}getting latest versions info"
	## revanced cli
	revanced_cli_version=$(curl -s -L https://github.com/revanced/revanced-cli/releases/latest | awk 'match($0, /v([0-9].*[0-9])/) {print substr($0, RSTART, RLENGTH)}' | awk -F'/' 'NR==1 {print $1}')
	revanced_cli_version=${revanced_cli_version#v}
	out "${YELLOW}revanced_cli : $revanced_cli_version${NC}"
	## revanced patches
	revanced_patches_version=$(curl -s -L https://github.com/revanced/revanced-patches/releases/latest | awk 'match($0, /v([0-9].*[0-9])/) {print substr($0, RSTART, RLENGTH)}' | awk -F'/' 'NR==1 {print $1}')
	revanced_patches_version=${revanced_patches_version#v}
	out "${YELLOW}revanced_patches : $revanced_patches_version${NC}"
	## integrations
	revanced_integrations_version=$(curl -s -L https://github.com/revanced/revanced-integrations/releases/latest | awk 'match($0, /v([0-9].*[0-9])/) {print substr($0, RSTART, RLENGTH)}' | awk -F'/' 'NR==1 {print $1}')
	revanced_integrations_version=${revanced_integrations_version##v}
	out "${YELLOW}revanced_integrations : $revanced_integrations_version${NC}"
}

## getting versions information
get_latest_version_info


# Wget download apk
dl_apk() {
	local url=$1 regexp=$2 output=$3
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n "s/href=\"/@/g; s;.*${regexp}.*;\1;p")"
	echo "$url"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
	req "$url" "$output"
}

# Download YouTube
dl_yt() {
	if [ "$youtube" = 'yes' ]; then
		echo "Downloading YouTube..."

		local base_apk="youtube.apk"
		if [ ! -f "$base_apk" ]; then
			declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube/youtube-${youtubeVersion}-release/" \
				"APK</span>[^@]*@\([^#]*\)" \
				"$base_apk")
		fi
	else
		echo "Skipping YouTube..."
	fi
}

# Download YouTube Music
dl_ytm_arm() {
	if [ "$music" = 'yes' ]; then
		echo "Downloading YouTube Music arm..."

		local base_apk="music-arm.apk"
		if [ ! -f "$base_apk" ]; then
			local regexp_arch='armeabi-v7a</div>[^@]*@\([^"]*\)'
			declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-${musicVersion}-release/" \
				"$regexp_arch" \
				"$base_apk")
		fi
	else
		echo "Skipping YouTube Music arm..."
	fi
}

dl_ytm_arm64() {
	if [ "$music" = 'yes' ]; then
		echo "Downloading YouTube Music arm64..."

		local base_apk="music-arm64.apk"
		if [ ! -f "$base_apk" ]; then
			local regexp_arch='arm64-v8a</div>[^@]*@\([^"]*\)'
			declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-${musicVersion}-release/" \
				"$regexp_arch" \
				"$base_apk")
		fi
	else
		echo "Skipping YouTube Music arm64..."
	fi
}

#dl_ytm_x86() {
#	if [ "$music" = 'yes' ]; then
#		echo "Downloading YouTube Music x86..."
#
#		local base_apk="music-x86.apk"
#		if [ ! -f "$base_apk" ]; then
#			local regexp_arch='x86</div>[^@]*@\([^"]*\)'
#			declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-${musicVersion}-release/" \
#				"$regexp_arch" \
#				"$base_apk")
#		fi
#	else
#		echo "Skipping YouTube Music x86..."
#	fi
#}

#dl_ytm_x86_64() {
#	if [ "$music" = 'yes' ]; then
#		echo "Downloading YouTube Music x86_64..."
#
#		local base_apk="music-x86_64.apk"
#		if [ ! -f "$base_apk" ]; then
#			local regexp_arch='x86_64</div>[^@]*@\([^"]*\)'
#			declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-${musicVersion}-release/" \
#				"$regexp_arch" \
#				"$base_apk")
#		fi
#	else
#		echo "Skipping YouTube Music x86_64..."
#	fi
#}

dl_twitter() {
	if [ "$twitter" = 'yes' ]; then
		echo "Downloading Twitter..."

		local base_apk="twitter.apk"
		if [ ! -f "$base_apk" ]; then
			declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/twitter-inc/twitter/twitter-${redditVersion}-release/" \
				"APK</span>[^@]*@\([^#]*\)" \
				"$base_apk")
		fi
	else
		echo "Skipping Twitter..."
	fi
}

dl_tiktok() {
	if [ "$tiktok" = 'yes' ]; then
		echo "Downloading Tiktok..."

		local base_apk="tiktok_${tiktokVersion}.apk"
		if [ ! -f "$base_apk" ]; then
			declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/tiktok-pte-ltd/tik-tok/tik-tok-${tiktokVersion}-release/" \
				"APK</span>[^@]*@\([^#]*\)" \
				"$base_apk")
		fi
	else
		echo "Skipping Tiktok..."
	fi
}

dl_reddit() {
	if [ "$reddit" = 'yes' ]; then
		echo "Downloading Reddit..."

		local base_apk="reddit_${redditVersion}.apk"
		if [ ! -f "$base_apk" ]; then
			declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/redditinc/reddit/reddit-${redditVersion}-release/" \
				"APK</span>[^@]*@\([^#]*\)" \
				"$base_apk")
		fi
	else
		echo "Skipping Reddit..."
	fi
}

## Main

for apk in "${!apks[@]}"; do
    if [ ! -f $apk ]; then
        ${apks[$apk]}
    fi
done

mkdir -p build

# All patches will be included by default, you can exclude patches by appending -e patch-name to exclude said patch.
# Example: -e microg-support

# All available patches can be found here: https://github.com/Lyceris-chan/revanced-patches

echo "************************************"
echo "Building YouTube APK"
echo "************************************"

if [ -f "youtube.apk" ]
then
    echo "Building Root APK"
    java -jar revanced-cli.jar -m revanced-integrations.apk -b revanced-patches.jar --experimental \
                               -e microg-support \
                               -a youtube.apk -o build/revanced-root.apk
    echo "Building Non-root APK"
    java -jar revanced-cli.jar -m revanced-integrations.apk -b revanced-patches.jar --experimental \
                               -a youtube.apk -o build/revanced-nonroot.apk
else
    echo "Cannot find YouTube APK, skipping build"
fi

echo "************************************"
echo "Building YouTube Music APK"
echo "************************************"
if [ -f "music-arm.apk" ]
then
    echo "Building Non-root arm APK"
    java -jar revanced-cli.jar -b revanced-patches.jar --experimental \
                               -a music-arm.apk -o build/revanced-music-nonroot-arm-signed.apk

    echo "Building Root arm APK"
    java -jar revanced-cli.jar -b revanced-patches.jar --experimental \
                               -e music-microg-support \
                               -a music-arm.apk -o build/revanced-music-root-arm-signed.apk

else
   echo "Cannot find YouTube Music ARM APK, skipping build"
fi

if [ -f "music-arm64.apk" ]
then
    echo "Building Non-root arm64 APK"
    java -jar revanced-cli.jar -b revanced-patches.jar --experimental \
                               -a music-arm64.apk -o build/revanced-music-nonroot-arm64-signed.apk

    echo "Building Root arm64 APK"
    java -jar revanced-cli.jar -b revanced-patches.jar --experimental \
                               -e music-microg-support \
                               -a music-arm64.apk -o build/revanced-music-root-arm64-signed.apk
else
    echo "Cannot find YouTube Music ARM64 APK, skipping build"
fi

#    echo "Building Non-root x86 APK"
#    java -jar revanced-cli.jar -b revanced-patches.jar --experimental \
#                               -a music-x86.apk -o build/revanced-music-x86-nonroot.apk

#    echo "Building Non-root x86_64 APK"
#    java -jar revanced-cli.jar -b revanced-patches.jar --experimental \
#                               -a music-x86_64.apk -o build/revanced-music-x86_64-nonroot.apk

echo "************************************"
echo "Building Twitter APK"
echo "************************************"
if [ -f "twitter.apk" ]
then
    java -jar revanced-cli.jar -b revanced-patches.jar \
                               -a twitter.apk -o build/twitter.apk
else
   echo "Cannot find Twitter APK, skipping build"
fi

echo "************************************"
echo "Building Reddit APK"
echo "************************************"
if [ -f "reddit.apk" ]
then
    java -jar revanced-cli.jar -b revanced-patches.jar -r \
                               -a reddit.apk -o build/reddit.apk
else
   echo "Cannot find Reddit APK, skipping build"
fi
