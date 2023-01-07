#!/bin/bash
while getopts krtym flag
do
    case "${flag}" in
        m) music=yes;;
        y) youtube=yes;;
        t) twitter=yes;;
        r) reddit=yes;;
        k) tiktok=yes;;
    esac
done
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

Likk="$GITHUB_WORKSPACE"
apksign () { java -jar apksigner.jar sign --cert "testkey.x509.pem" --key "testkey.pk8" --out "$2" "$1"; }
Xem () { curl -s -G -L -N -H "$User" --connect-timeout 20 "$1"; }


notset() {
	case $1 in '') return 0 ;; *) return 1 ;; esac
}

check_dep() {
	if ! command -v "$1" >/dev/null; then
		[ "$2" ] && out "${RED}$2${NC}"
		return 1
	else
		return 0
	fi
}

## grep
if notset "$grep" && check_dep "rg"; then
	grep="rg"
elif notset "$grep"; then
	grep="grep"
fi

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

mkdir -p build upload

# Artifacts associative array aka dictionary
declare -A artifacts
# Download from revanced extended
patchs_revanced_ex () {
	artifacts["revanced-cli-ex.jar"]="inotia00/revanced-cli revanced-cli .jar"
	artifacts["revanced-integrations-ex.apk"]="inotia00/revanced-integrations app-release-unsigned .apk"
	artifacts["revanced-patches-ex.jar"]="inotia00/revanced-patches revanced-patches .jar"
	artifacts["microg.apk"]="inotia00/VancedMicroG microg.apk"
}
# Download from revanced
patchs_revanced () {
	artifacts["revanced-cli.jar"]="revanced/revanced-cli revanced-cli .jar"
	artifacts["revanced-integrations.apk"]="revanced/revanced-integrations revanced-integrations .apk"
	artifacts["revanced-patches.jar"]="revanced/revanced-patches revanced-patches .jar"
	artifacts["microg.apk"]="inotia00/VancedMicroG microg.apk"
}

get_artifact_download_url () {
    # Usage: get_download_url <repo_name> <artifact_name> <file_type>
    local api_url="https://api.github.com/repos/$1/releases/latest"
    local result=$(curl $api_url | jq ".assets[] | select(.name | contains(\"$2\") and contains(\"$3\") and (contains(\".sig\") | not)) | .browser_download_url")
    echo ${result:1:-1}
}

# Fetch all the dependencies
dl_patchs () {
	for artifact in "${!artifacts[@]}"; do
	    if [ ! -f $artifact ]; then
	        echo "Downloading $artifact"
	        curl -L -o $artifact $(get_artifact_download_url ${artifacts[$artifact]})
	    fi
	done
}



# Download the following apk's from APKmirror

musicVersion="5-24-50"
twitterVersion="9-58-1-release-1"
redditVersion="2022-34-0"






declare -A apks

# YouTube Music builds for the following architectures are currently commented out as they don't appear to be building 
# properly right now if these do end up getting fixed in the future and if there are people needing them I'll look into re-enabling them.

#apks["youtube.apk"]=dl_yt
apks["music-arm.apk"]=dl_ytm_arm
apks["music-arm64.apk"]=dl_ytm_arm64
# apks["music-x86.apk"]=dl_ytm_x86
# apks["music-x86_64.apk"]=dl_ytm_x86_64
apks["twitter.apk"]=dl_twitter
apks["reddit.apk"]=dl_reddit
#apks["tiktok.apk"]=dl_tiktok


## Functions

# Wget user agent
WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0"

# Wget function
req() { wget -nv -O "$2" --header="$WGET_HEADER" "$1"; }

get_latest_version_info() {
	out "${BLUE}getting latest versions info${NC}"
	## revanced cli
	revanced_cli_version="$(Xem https://github.com/revanced/revanced-cli | grep -m1 'revanced/revanced-cli/releases/tag' | sed 's|v||g' | tr "/" "\n" | grep -m1 '\">' | cut -d \" -f1)"
	out "${YELLOW}revanced_cli : $revanced_cli_version${NC}"
	## revanced patches
	revanced_patches_version="$(Xem https://github.com/revanced/revanced-patches | grep -m1 'revanced/revanced-patches/releases/tag' | sed 's|v||g' | tr "/" "\n" | grep -m1 '\">' | cut -d \" -f1)"
	out "${YELLOW}revanced_patches : $revanced_patches_version${NC}"
	## integrations
	revanced_integrations_version="$(Xem https://github.com/revanced/revanced-integrations | grep -m1 'revanced/revanced-integrations/releases/tag' | sed 's|v||g' | tr "/" "\n" | grep -m1 '\">' | cut -d \" -f1)"
	out "${YELLOW}revanced_integrations : $revanced_integrations_version${NC}"
}
get_ex_latest_version_info() {
	out "${BLUE}getting latest versions info${NC}"
	## revanced cli
	revanced_cli_version="$(Xem https://github.com/inotia00/revanced-cli | grep -m1 'inotia00/revanced-cli/releases/tag' | sed 's|v||g' | tr "/" "\n" | grep -m1 '\">' | cut -d \" -f1)"
	out "${YELLOW}revanced_cli : $revanced_cli_version${NC}"
	## revanced patches
	revanced_patches_version="$(Xem https://github.com/inotia00/revanced-patches | grep -m1 'inotia00/revanced-patches/releases/tag' | sed 's|v||g' | tr "/" "\n" | grep -m1 '\">' | cut -d \" -f1)"
	out "${YELLOW}revanced_patches : $revanced_patches_version${NC}"
	## integrations
	revanced_integrations_version="$(Xem https://github.com/inotia00/revanced-integrations | grep -m1 'inotia00/revanced-integrations/releases/tag' | sed 's|v||g' | tr "/" "\n" | grep -m1 '\">' | cut -d \" -f1)"
	out "${YELLOW}revanced_integrations : $revanced_integrations_version${NC}"
}


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
		youtubeVersion="$(java -jar revanced-cli-ex.jar -a revanced-integrations-ex.apk -b revanced-patches-ex.jar -l --with-versions 2>/dev/null | grep -m1 video-ads | tr '	' '\n' | tac | head -n 1 | awk '{print $1}')"
		out "${YELLOW}YouTube version to be patched : $youtubeVersion${NC}"
		echo "VS=${youtubeVersion}" >> $GITHUB_ENV
		echo "Downloading YouTube..."
		
		local base_apk="youtube.apk"
		if [ ! -f "$base_apk" ]; then
			declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube/youtube-${youtubeVersion}-release/" \
				"APK</span>[^@]*@\([^#]*\)" \
				"$base_apk")
				
		cp youtube.apk youtube-arm.apk
		cp youtube.apk youtube-arm64.apk
		7z d  youtube-arm64.apk -r lib/x86_64/ lib/x86/ lib/armeabi-v7a/ > nul
		7z d  youtube-arm.apk -r lib/x86_64/ lib/x86/ lib/arm64-v8a/ > nul
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
		tiktokVersion=$(curl -sL "https://api.github.com/repos/XDream8/revanced-creator/releases" | $grep -io "tiktok-[0-9].*[0-9]" | grep -o "[0-9].*[0-9]" | uniq | sort | awk 'END{print}')
		out "${YELLOW}Tiktok version to be patched : $tiktokVersion${NC}"
		echo "VST=${tiktokVersion}" >> $GITHUB_ENV
		echo "Downloading Tiktok..."

		local base_apk="tiktok.apk"
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

# All patches will be included by default, you can exclude patches by appending -e patch-name to exclude said patch.
# Example: -e microg-support

# All available patches can be found here: https://github.com/Lyceris-chan/revanced-patches

common_included_patches="-i predictive-back-gesture"

if [ "$youtube" = 'yes' ]; then
    echo "************************************"
    echo "*     Building ReVanced      *"
    echo "************************************"
    patchs_revanced_ex
    dl_patchs
    get_ex_latest_version_info
    echo "VS_PATCHES=$revanced_patches_version" >> $GITHUB_ENV
    echo "VS_CLI=$revanced_cli_version" >> $GITHUB_ENV
    echo "VS_INTERGAITIONS=$revanced_integrations_version" >> $GITHUB_ENV
    dl_yt

    yt_excluded_patches="-e custom-branding-icon-afn-blue -e custom-branding-icon-afn-red -e custom-branding-name -e custom-branding-icon-revancify -e custom-video-buffer -e custom-video-speed -e default-video-speed -e disable-haptic-feedback -e enable-hdr-auto-brightness -e enable-old-layout -e enable-old-seekbar-color -e enable-seekbar-tapping -e enable-tablet-miniplayer -e enable-wide-searchbar -e header-switch -e hide-auto-player-popup-panels -e hide-autoplay-button -e hide-comment-component -e hide-crowdfunding-box -e hide-email-address -e hide-filmstrip-overlay -e hide-flyout-panel -e hide-fullscreen-buttoncontainer -e hide-info-cards -e hide-pip-notification -e hide-player-captions-button -e hide-player-overlay-filter -e hide-stories -e hide-suggested-actions -e hide-time-and-seekbar -e layout-switch -e remove-player-button-background -e return-youtube-dislike -e swipe-controls"
    yt_included_patches="-i theme -i force-premium-heading"

    echo "=== Building arm APK ==="
    if [ -f "youtube-arm.apk" ]; then
        java -jar revanced-cli-ex.jar -m revanced-integrations-ex.apk -b revanced-patches-ex.jar \
                                $yt_excluded_patches $yt_included_patches $common_included_patches \
                                -a youtube-arm.apk -o build/revanced-arm.apk
        apksign "$Likk/build/revanced-arm.apk" "$Likk/upload/ReEx-${youtubeVersion}-nonroot-armeabi-v7a.apk"
	echo "ReEx-${youtubeVersion}-nonroot armeabi-v7a build finished"
    else
        echo "Cannot find YouTube arm APK, skipping build"
    fi
    
    echo "=== Building arm APK ==="
    if [ -f "youtube-arm64.apk" ]; then
        java -jar revanced-cli-ex.jar -m revanced-integrations-ex.apk -b revanced-patches-ex.jar \
                                $yt_excluded_patches $yt_included_patches $common_included_patches \
                                -a youtube-arm64.apk -o build/revanced-arm64.apk
        apksign "$Likk/build/revanced-arm64.apk" "$Likk/upload/ReEx-${youtubeVersion}-nonroot-arm64-v8a.apk"
	echo "ReEx-${youtubeVersion}-nonroot arm64-v8a build finished"
    else
        echo "Cannot find YouTube arm APK, skipping build"
    fi
else
    echo "Skipping ReVanced build"
fi

if [ "$music" = 'yes' ]; then
    echo "************************************"
    echo "*     Building ReVanced Music      *"
    echo "************************************"

    ytm_excluded_patches="-e always-autorepeat -e autorepeat-by-default -e client-spoof -e comments -e custom-branding -e custom-video-buffer -e custom-video-speed -e debugging -e disable-auto-captions -e disable-auto-player-popup-panels -e disable-create-button -e disable-fullscreen-panels -e disable-startup-shorts-player -e disable-zoom-haptics -e downloads -e enable-wide-searchbar -e general-ads -e hdr-auto-brightness -e hide-album-cards -e hide-artist-card -e hide-autoplay-button -e hide-captions-button -e hide-cast-button -e hide-create-button -e hide-crowdfunding-box -e hide-email-address -e hide-endscreen-cards -e hide-info-cards -e hide-my-mix -e hide-shorts-button -e hide-time-and-seekbar -e hide-video-buttons -e hide-watch-in-vr -e hide-watermark -e microg-support -e minimized-playback -e old-quality-layout -e open-links-directly -e premium-heading -e remember-video-quality -e remove-player-button-background -e return-youtube-dislike -e seekbar-tapping -e settings -e sponsorblock -e swipe-controls -e tablet-mini-player -e video-ads"

    echo "=== Building arm APK ==="
    if [ -f "music-arm.apk" ]; then
        java -jar revanced-cli.jar -m revanced-integrations.apk -b revanced-patches.jar \
                                $ytm_excluded_patches $common_included_patches \
                                -a music-arm.apk -o upload/revanced-music-nonroot-arm.apk
        echo "ReVanced Music arm build finished"
    else
        echo "Cannot find YouTube Music arm APK, skipping build"
    fi

    echo "=== Building arm64 APK === "
    if [ -f "music-arm64.apk" ]; then
        java -jar revanced-cli.jar -m revanced-integrations.apk -b revanced-patches.jar \
                                $ytm_excluded_patches \
                                -a music-arm64.apk -o upload/revanced-music-nonroot-arm64.apk
        echo "ReVanced Music arm64 build finished"
    else
        echo "Cannot find YouTube Music arm64 APK, skipping build"
    fi

    echo "=== Building x86 APK ==="
    if [ -f "music-x86.apk" ]; then
        java -jar revanced-cli.jar -m revanced-integrations.apk -b revanced-patches.jar \
                                $ytm_excluded_patches \
                                -a music-x86.apk -o upload/revanced-music-nonroot-x86.apk
        echo "ReVanced Music x86 build finished"
    else
        echo "Cannot find YouTube Music x86 APK, skipping build"
    fi

    echo "=== Building x86_64 APK ==="
    if [ -f "music-x86_64.apk" ]; then
        java -jar revanced-cli.jar -m revanced-integrations.apk -b revanced-patches.jar \
                                $ytm_excluded_patches \
                                -a music-x86_64.apk -o upload/revanced-music-nonroot-x86_64.apk
        echo "ReVanced Music x86_64 build finished"
        echo "ReVanced Music build finished"
    else
        echo "Cannot find YouTube Music x86_64 APK, skipping build"
    fi
else
    echo "Skipping ReVanced Music build"
fi

echo "************************************"
echo "Building Twitter APK"
echo "************************************"
if [ -f "twitter.apk" ]
then
    java -jar revanced-cli.jar -b revanced-patches.jar \
                               -a twitter.apk -o upload/twitter.apk
else
   echo "Cannot find Twitter APK, skipping build"
fi

echo "************************************"
echo "Building Reddit APK"
echo "************************************"
if [ -f "reddit.apk" ]
then
    java -jar revanced-cli.jar -b revanced-patches.jar -r \
                               -a reddit.apk -o upload/reddit.apk
else
   echo "Cannot find Reddit APK, skipping build"
fi

echo "************************************"
echo "Building Tiktok APK"
echo "************************************"
if [ "$tiktok" = 'yes' ]; then
    patchs_revanced
    dl_patchs
    get_latest_version_info
    echo "VS_PATCHES=$revanced_patches_version" >> $GITHUB_ENV
    echo "VS_CLI=$revanced_cli_version" >> $GITHUB_ENV
    echo "VS_INTERGAITIONS=$revanced_integrations_version" >> $GITHUB_ENV
    dl_tiktok
    java -jar revanced-cli.jar -m revanced-integrations.apk -b revanced-patches.jar \
                               -a tiktok.apk -o build/tiktok_${tiktokVersion}.apk
        apksign "$Likk/build/tiktok_${tiktokVersion}.apk" "$Likk/upload/tiktok_${tiktokVersion}.apk"
	echo "tiktok_${tiktokVersion}.apk build finished"
else
   echo "Cannot find Reddit APK, skipping build"
fi
