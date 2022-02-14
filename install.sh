#!/bin/bash
set -e

declare -a LAYOUT_OPTIONS
LAYOUT_OPTIONS=(
  "Elementary                    [⨯    —    ⤢]"
  "Elementary Reversed           [⤢    —    ⨯]"
  "Close Only Left               [⨯    —     ]"
	"Close Only Right              [     —    ⨯]"
	"Minimize Left                 [⨯⤓   —    ⤢]"
	"Minimize Right                [⨯    —   ⤓⤢]"
	"MacOS                         [⨯⤓⤢  —     ]"
	"Ubuntu                        [⨯⤢⤓  —     ]"
	"Windows                       [     —  ⤓⤢⨯]"
	"Replace Maximize to Minimize  [⨯    —    ⤓]"
)

declare -a LAYOUT_PATHS
LAYOUT_PATHS=(
  ""
  "/Elementary%20Reversed"
  "/Close%20Only%20Left"
	"/Close%20Only%20Right"
	"/Minimize%20Left"
	"/Minimize%20Right"
	"/macOS"
	"/Ubuntu"
	"/Windows"
	"/Replace%20Maximize%20to%20Minimize"
	"/Titlebar%20Enabled"
)

declare -a LAYOUT_SETTINGS
LAYOUT_SETTINGS=(
  "'close:maximize'"
	"'maximize:close'"
	"'close:'"
	"':close'"
	"'close,minimize:maximize'"
	"'close:minimize,maximize'"
	"'close,minimize,maximize'"
	"'close,maximize,minimize'"
	"':minimize,maximize,close'"
	"'close:minimize'"
)

PRIVATE_MODE_PATH="/Private%20Mode%20Style"

APP_EXECUTABLE="install.sh"
APP_HELP_MESSAGE="
Firefox Elementary Theme installation script
============================================

Installation script is recommended to install Firefox Elementary Theme.

Firefox Theme is set of stylesheets ('userChrome.css' and 'userContent.css').
To apply theme, stylesheets need to be placed at 'chrome' directory inside user
profile. That is what installation script will do.

Using custom stylesheets also requires preference
'toolkit.legacyUserProfileCustomizations.stylesheets' to be enabled. By default
it is turned off, so installation script will turn it on. Changing  preference
value requires all Firefox processes to be stopped, so installation script may
ask user to quit Firefox.

Firefox Elementary Theme requires different stylesheets depending on window
controls layout. This is because Firefox not using native window titlebar by
default, and stylesheets also responsible for window controls placement at
browser window. Window controls layout defines which of buttons (⨯⤓⤢) will be
placed at window title bar, and how these buttons will placed (left or right,
in which order). Installation script will detect current window controls layout
and select corresponding stylesheets. Detection requires gsetting
(https://www.linux.org/docs/man1/gsettings.html) to be installed.
Window controls layout may be changed with Pantheon Tweaks application
(https://github.com/pantheon-tweaks/pantheon-tweaks).

Supported window controls layouts are:

$(
  for INDEX in "${!LAYOUT_OPTIONS[@]}"; do
    printf "%3s. %s\n" "$((INDEX+1))" "${LAYOUT_OPTIONS[${INDEX}]}"
  done
)

When Firefox window uses native titlebar (by default is not) Firefox Elementary
Theme requires special stylesheet, which is completelly indifferent to controls
layout. Installation script will detect is Firefox using native titlebar or not
and will select corresponding theme stylesheet.

Installation script supports Firefox installed with apt and flatpak. It also
supports Librewolf. For best experience with Elementary theme it is recommended
to use Firefox installed with apt. Flatpak installed instances has limited
support.

Theme homepage https://github.com/Zonnev/elementaryos-firefox-theme

Usage: ${APP_EXECUTABLE} [OPTIONS]

OPTIONS:

-h, --help

  Print this help message and exit.

  Example: ${APP_EXECUTABLE} -h
  Example: ${APP_EXECUTABLE} --help

--browser-profile <profile_path>

  Install theme to specified firefox profile only. Multiple profiles may
  be specified.

  Example: ${APP_EXECUTABLE} --browser-profile /profile
  Example: ${APP_EXECUTABLE} --browser-profile /first/profile --browser-profile /second/profile

--controls-layout <number>

  Forces installation of theme for window controls layout specified by number.
  By default installation script will detect window controls layout, this
  option disables auto-detection. This option is not compatible with
  '--native-titlebar yes' and '--private-mode-style' options.

  Example: ${APP_EXECUTABLE} --controls-layout 2

--native-titlebar yes|no

  Controls whether to use native titlebar or not. By default installation
  script will detect whether titlebar enabled or not, by reading preference
  'browser.tabs.inTitlebar' at Firefox profile. When native titlebar is enabled
  options '--controls-layout' and '--private-mode-style' are inapplicable. When
  this options is specified installation script will ensure that preference
  'browser.tabs.inTitlebar' has corresponding value. Changing the preference
  requires all Firefox processes to be stopped, so script may ask user to quit
  Firefox.

  Example: ${APP_EXECUTABLE} --native-titlebar yes
  Example: ${APP_EXECUTABLE} --native-titlebar no

--private-mode-style

  Force private mode style (purple colours) for all windows. Sutable for
  Elementary window controls layout and disabled native titlebar only.
  This option is not compatible with '--controls-layout' and
  '--private-mode-style'.

  Example: ${APP_EXECUTABLE} --private-mode-style

--skip-preference-patch

  Do not patch Firefox 'toolkit.legacyUserProfileCustomizations.stylesheets'
  preference. User should patch this preference manulally. Installation
  script won't ask user to stop Firefox process to apply preference.

  Example: ${APP_EXECUTABLE} --skip-preference-patch
"

declare -a BROWSER_PROFILES
BROWSER_PROFILES=()
CONTROLS_LAYOUT=""
NATIVE_TITLEBAR=""
PATCH_PREFERENCE="yes"
PRIVATE_MODE_STYLE="no"

# #############################################################################
#  Parse options
# #############################################################################

while [ $# -ne 0 ]; do
  case "${1}" in
    "-h"|"--help")
      echo "${APP_HELP_MESSAGE}"
      exit 0
      ;;

    "--controls-layout")
      if [ -z "${2}" ]; then
        echo "" >&2
        echo "Controls layout is not specified." >&2
        echo "Try '${APP_EXECUTABLE} --help' to see available controls layouts." >&2
        echo "" >&2
        exit 1
      fi

      if [ -z "${LAYOUT_OPTIONS[$((${2}+1))]}" ]; then
        echo "" >&2
        echo "Unknown controls layout '${2}' is specified." >&2
        echo "Try '${APP_EXECUTABLE} --help' to see available controls layouts." >&2
        echo "" >&2
        exit 1
      fi

      CONTROLS_LAYOUT="${2}"
      shift 2
      ;;

    "--browser-profile")
      BROWSER_PROFILES+=("${2}")
      shift 2
      ;;

    "--native-titlebar")
      if [ "${2}" != "yes" ] && [ "${2}" != "no" ]; then
        echo "" >&2
        echo "Unknown option value '${2}' is specified." >&2
        echo "Expect '--native-titlebar yes' or '--native-titlebar no'." >&2
        echo "Try '${APP_EXECUTABLE} --help' to see manual." >&2
        echo "" >&2
        exit 1
      fi
      NATIVE_TITLEBAR="${2}"
      shift 2
      ;;

    "--private-mode-style")
      PRIVATE_MODE_STYLE="yes"
      shift
      ;;

    "--skip-preference-patch")
      PATCH_PREFERENCE="no"
      shift
      ;;

    *)
      echo "" >&2
      echo "Unknown option: ${1}" >&2
      echo "Try '${APP_EXECUTABLE} --help' to see available options." >&2
      echo "" >&2
      exit 1
  esac
done

if [ ! -z "${CONTROLS_LAYOUT}" ] && [ "${NATIVE_TITLEBAR}" == "yes" ]; then
  echo "" >&2
  echo "Options '--controls-layout ${CONTROLS_LAYOUT}' and '--native-titlebar yes' are incompatible." >&2
  echo "Try '${APP_EXECUTABLE} --help' to see manual." >&2
  echo "" >&2
  exit 1
fi

if [ ! -z "${CONTROLS_LAYOUT}" ] && [ "${PRIVATE_MODE_STYLE}" == "yes" ]; then
  echo "" >&2
  echo "Options '--controls-layout ${CONTROLS_LAYOUT}' and '--private-mode-style' are incompatible." >&2
  echo "Try '${APP_EXECUTABLE} --help' to see manual." >&2
  echo "" >&2
  exit 1
fi

if [ "${NATIVE_TITLEBAR}" == "yes" ] && [ "${PRIVATE_MODE_STYLE}" == "yes" ]; then
  echo "" >&2
  echo "Options '--native-titlebar yes' and '--private-mode-style' are incompatible." >&2
  echo "Try '${APP_EXECUTABLE} --help' to see manual." >&2
  echo "" >&2
  exit 1
fi

if [ "${PRIVATE_MODE_STYLE}" == "yes" ]; then
  NATIVE_TITLEBAR="no"
fi

# #############################################################################
#  Find profiles
# #############################################################################

function findBrowserProfiles {
  # TODO: ignore empty profiles
  local FIREFOX_DIR="${1}"
  if [ -d "${FIREFOX_DIR}" ]; then
    PROFILES_FILE="${FIREFOX_DIR}/profiles.ini"
    if [ -f "${PROFILES_FILE}" ]; then
      grep -E "^Path=" "${PROFILES_FILE}" | \
        cut -d "=" -f2- | \
        xargs -I '{}' echo "${FIREFOX_DIR}/{}"
    else
      find "${FIREFOX_DIR}" -mindepth 1 -maxdepth 1 -type d
    fi
  fi
}

function findBrowsersProfiles {
  if [ ${#BROWSER_PROFILES[@]} -eq 0 ]; then
    # TODO: support Firefox and Librewolf installed as appimage
    BROWSER_PROFILES+=($(findBrowserProfiles "${HOME}/.mozilla/firefox"))
    # TODO: find a way to get flatpak installed app directory
    BROWSER_PROFILES+=(
      $(findBrowserProfiles "${HOME}/.var/app/org.mozilla.firefox/cache/mozilla/firefox")
    )
    BROWSER_PROFILES+=(
      $(findBrowserProfiles "${HOME}/.var/app/io.gitlab.librewolf-community/cache/librewolf")
    )
  fi
}

findBrowsersProfiles

# ###
echo "BROWSER_PROFILES=${BROWSER_PROFILES[@]} (${#BROWSER_PROFILES[@]})"
echo "CONTROLS_LAYOUT=${CONTROLS_LAYOUT}"
echo "NATIVE_TITLEBAR=${NATIVE_TITLEBAR}"
echo "PATCH_PREFERENCE=${PATCH_PREFERENCE}"
echo "PRIVATE_MODE_STYLE=${PRIVATE_MODE_STYLE}"
