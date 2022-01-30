#!/bin/bash
set -e

function selectLayout() {
	
	if [ "${1}" != "" ]; then
		USER_CHROME_LAYOUT=${1}
	else
		echo "Select Available Layouts:"
		echo ""
		echo "   1. Default"
		echo "   2. Close Only Left"
		echo "   3. Close Only Right"
		echo "   4. Minimize Left"
		echo "   5. Minimize Right"
		echo "   6. OSX"
		echo "   7. Ubuntu"
		echo "   8. Windows"
		echo "   9. Titlebar Enabled"
		echo ""
		read -p "Please select the preferred layout (press Enter for default) [1-8]:" USER_CHROME_LAYOUT < /dev/tty
		echo ""
	fi
	
	case $USER_CHROME_LAYOUT in
		2 )
		    echo "Calling the install script for the 'Close Only Left' layout"
			curl -s -o- https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/Close%20Only%20Left/install.sh | bash
			exit 0
			;;
		3 )
		    echo "Calling the install script for the 'Close Only Right' layout"
			curl -s -o- https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/Close%20Only%20Right/install.sh | bash
			exit 0
			;;
		4 )
		    echo "Calling the install script for the 'Minimize Left' layout"
			curl -s -o- https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/Minimize%20Left/install.sh | bash
			exit 0
			;;
		5 )
		    echo "Calling the install script for the 'Minimize Right' layout"
			curl -s -o- https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/Minimize%20Right/install.sh | bash
			exit 0
			;;
		6 )
		    echo "Calling the install script for the 'OSX' layout"
			curl -s -o- https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/OSX/install.sh | bash
			exit 0
			;;
		7 )
		    echo "Calling the install script for the 'Ubuntu' layout"
			curl -s -o- https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/Ubuntu/install.sh | bash
			exit 0
			;;
		8 )
		    echo "Calling the install script for the 'Windows' layout"
			curl -s -o- https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/Windows/install.sh | bash
			exit 0
			;;
		9 )
		    echo "Calling the install script for 'Titlebar Enabled'"
			curl -s -o- https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/Titlebar%20Enabled/install.sh | bash
			exit 0
			;;
		10 )
		    echo "Calling the install script for 'Private Mode Style'"
			curl -s -o- https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/Private%20Mode%20Style/install.sh | bash
			exit 0
			;;
		* )
		    echo "Installing Default layout"
			;;
	esac
	echo ""
}

function saveProfile() {
	ITEM="${1}"
	PROFILE_PATH="${2}"
	PROFILE_CHROME_DIR="${FIREFOX_DIR}/${PROFILE_PATH}/chrome"
    PROFILE_USER_CHROME_CSS_FILE="${PROFILE_CHROME_DIR}/userChrome.css"
    PROFILE_USER_CONTENT_CSS_FILE="${PROFILE_CHROME_DIR}/userContent.css"
    echo "  $((${ITEM}+3)). Install theme at profile path ${FIREFOX_DIR}/${PROFILE_PATH}:"
    echo -n "     - Ensure directory 'chrome' ... "
    mkdir -p "${PROFILE_CHROME_DIR}"
    echo "done"
    echo -n "     - Create file 'chrome/userChrome.css' ... "
    curl -s -o "${PROFILE_USER_CHROME_CSS_FILE}" "${USER_CHROME_CSS_URL}" -s -o "${PROFILE_USER_CONTENT_CSS_FILE}" "${USER_CONTENT_CSS_URL}"
    echo "done"
}

echo "Install ElementaryOS Firefox Theme (https://github.com/Zonnev/elementaryos-firefox-theme/tree/elementaryos-firefox-theme)"
echo ""

selectLayout "$1"

FIREFOX_DIR="${HOME}/.mozilla/firefox"
USER_CHROME_CSS_URL="https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/userChrome.css"
USER_CONTENT_CSS_URL="https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme/userContent.css"

echo -n "  1. Check Firefox installation ... "
if [ ! -d "${FIREFOX_DIR}" ]; then
	>&2 echo "failed, please check Firefox installation, unable to find ${FIREFOX_DIR}"
	exit 1
fi
PROFILES_FILE="${FIREFOX_DIR}/profiles.ini"
if [ ! -f "${PROFILES_FILE}" ]; then
	>&2 echo "failed, please check Firefox installation, unable to find profile.ini at ${FIREFOX_DIR}"
	exit 1
fi
echo " done"
	
echo -n "  2. Search for firefox profiles ... "
PROFILES_PATHS=($(grep -E "^Path=" "${PROFILES_FILE}" | cut -d "=" -f2-))
if [ ${#PROFILES_PATHS[@]} -eq 0 ]; then
	>&2 echo "failed, no profiles found at ${PROFILES_FILE}"
	exit 0
elif [ ${#PROFILES_PATHS[@]} -eq 1 ]; then
	echo "one profile found"
	saveProfile "0" "${PROFILES_PATHS[0]}"
else
	echo "${#PROFILES_PATHS[@]} profiles found"
	ITEM=0
	for PROFILE_PATH in "${PROFILES_PATHS[@]}"; do
	    saveProfile "${ITEM}" "${PROFILE_PATH}"
	    ITEM="$((${ITEM}+1))"
	done
fi

echo ""
echo "Done, restart Firefox, please."
