#!/bin/bash

echo "Install Elementaryos Firefox Theme (https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme)"
FIREFOX_DIR="${HOME}/.mozilla/firefox"
PROFILES_FILE="${FIREFOX_DIR}/profiles.ini"
USER_CHROME_CSS_URL="https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/master/userChrome.css"

echo -n " - search for default firefox profile ... "
if [[ $(grep "\[Profile[^0]\]" ${PROFILES_FILE}) ]]; then
	PROFILE_NAME=$(grep -E "^\[Profile|^Path|^Default" "${PROFILES_FILE}" | grep -1 "^Default=1" | grep "^Path" | cut -c6-)
else
	PROFILE_NAME=$(grep "Path=" "${PROFILES_FILE}" | sed "s/^Path=//")
fi
echo "found ${PROFILE_NAME}"

CHROME_DIR="${FIREFOX_DIR}/${PROFILE_NAME}/chrome"
echo -n " - ensure directory ${CHROME_DIR} ... "
mkdir -p "${CHROME_DIR}"
echo "done"

USER_CHROME_CSS_FILE="${CHROME_DIR}/userChrome.css"
echo -n " - save userCrome.css to ${USER_CHROME_CSS_FILE} ... "
curl -s -o "${USER_CHROME_CSS_FILE}" "${USER_CHROME_CSS_URL}"
echo "done"

echo "done, restart firefox, please"
