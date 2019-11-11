#!/bin/bash
set -e

function saveProfile() {
	ITEM="${1}"
	PROFILE_PATH="${2}"
	PROFILE_CHROME_DIR="${FIREFOX_DIR}/${PROFILE_PATH}/chrome"
    PROFILE_USER_CHROME_CSS_FILE="${PROFILE_CHROME_DIR}/userChrome.css"
    MARKER=" $((${ITEM}+3))."
    echo    "${MARKER} Install theme at profile path ${FIREFOX_DIR}/${PROFILE_PATH}:"
    echo -n "    ensure directory 'chrome' ... "
    mkdir -p "${PROFILE_CHROME_DIR}"
    echo "done"
    echo -n "    create file 'chrome/userChrome.css' ... "
    curl -s -o "${PROFILE_USER_CHROME_CSS_FILE}" "${USER_CHROME_CSS_URL}"
    echo "done"
}

echo "Install Elementaryos Firefox Theme (https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme)"
echo ""

FIREFOX_DIR="${HOME}/.mozilla/firefox"
PROFILES_FILE="${FIREFOX_DIR}/profiles.ini"
USER_CHROME_CSS_URL="https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/master/userChrome.css"

echo -n " 1. Check Firefox installation ... "
if [ ! -d "${FIREFOX_DIR}" ]; then
	>&2 echo "failed, please check Firefox installation, unable to find ${FIREFOX_DIR}"
	exit 1
fi
if [ ! -f "${PROFILES_FILE}" ]; then
	>&2 echo "failed, lease check Firefox installation, unable to find profile.ini at ${FIREFOX_DIR}"
	exit 1
fi
echo " done"

echo -n " 2. Search for firefox profiles ... "
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
	    saveProfile "${ITEM}" "${PROFILES_PATHS[0]}"
	    ITEM="$((${ITEM}+1))"
	done
fi

echo ""
echo "Done, restart firefox, please"
