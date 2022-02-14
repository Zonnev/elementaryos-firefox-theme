#!/bin/bash
set -e

declare -a BROWSERS
declare -A BROWSERS_PROCESS_ID
declare -A BROWSERS_PROFILES_ROOT

DEFAULT_BROWSER="Firefox"

BROWSER="${DEFAULT_BROWSER}";
BROWSERS+=("${BROWSER}");
BROWSERS_PROCESS_ID["${BROWSER}"]='pidof "firefox" || exit 0'
BROWSERS_PROFILES_ROOT["${BROWSER}"]="${HOME}/.mozilla/firefox"

BROWSER="Firefox Nightly";
BROWSERS+=("${BROWSER}");
BROWSERS_PROCESS_ID["${BROWSER}"]='pidof "firefox-trunk" || exit 0'
BROWSERS_PROFILES_ROOT["${BROWSER}"]="${HOME}/.mozilla/firefox-trunk"

# BROWSER="Firefox (Flatpak)";
# BROWSERS+=("${BROWSER}");
# BROWSERS_PROCESS_ID["${BROWSER}"]='flatpak ps --columns=pid,application | grep "org.mozilla.firefox" | cut -f1'
# BROWSERS_PROFILES_ROOT["${BROWSER}"]="${HOME}/.var/app/org.mozilla.firefox/cache/mozilla/firefox"

# BROWSER="Librewolf";
# BROWSERS+=("${BROWSER}");
# BROWSERS_PROCESS_ID["${BROWSER}"]='pidof "librewolf" || exit 0'
# BROWSERS_PROFILES_ROOT["${BROWSER}"]="${HOME}/.cache/librewolf"

# BROWSER="Librewolf (Flatpak)";
# BROWSERS+=("${BROWSER}");
# BROWSERS_PROCESS_ID["${BROWSER}"]='flatpak ps --columns=pid,application | grep "io.gitlab.librewolf-community" | cut -f1'
# BROWSERS_PROFILES_ROOT["${BROWSER}"]="${HOME}/.var/app/io.gitlab.librewolf-community/cache/librewolf"

declare -a LAYOUTS
declare -A LAYOUTS_PATHS
declare -A LAYOUTS_SETTINGS
declare -A LAYOUTS_TITLEBARS

LAYOUT="Elementary"
LAYOUTS+=("${LAYOUT}")
LAYOUTS_PATHS["${LAYOUT}"]=""
LAYOUTS_SETTINGS["${LAYOUT}"]="'close:maximize'"
LAYOUTS_TITLEBARS["${LAYOUT}"]="[⨯    —    ⤢]"

LAYOUT="Elementary Reversed"
LAYOUTS+=("${LAYOUT}")
LAYOUTS_PATHS["${LAYOUT}"]="Elementary%20Reversed/"
LAYOUTS_SETTINGS["${LAYOUT}"]="'maximize:close'"
LAYOUTS_TITLEBARS["${LAYOUT}"]="[⤢    —    ⨯]"

LAYOUT="Close Only Left"
LAYOUTS+=("${LAYOUT}")
LAYOUTS_PATHS["${LAYOUT}"]="Close%20Only%20Left/"
LAYOUTS_SETTINGS["${LAYOUT}"]="'close:'"
LAYOUTS_TITLEBARS["${LAYOUT}"]="[⨯    —     ]"

LAYOUT="Close Only Right"
LAYOUTS+=("${LAYOUT}")
LAYOUTS_PATHS["${LAYOUT}"]="Close%20Only%20Right/"
LAYOUTS_SETTINGS["${LAYOUT}"]="':close'"
LAYOUTS_TITLEBARS["${LAYOUT}"]="[     —    ⨯]"

LAYOUT="Minimize Left"
LAYOUTS+=("${LAYOUT}")
LAYOUTS_PATHS["${LAYOUT}"]="Minimize%20Left/"
LAYOUTS_SETTINGS["${LAYOUT}"]="'close,minimize:maximize'"
LAYOUTS_TITLEBARS["${LAYOUT}"]="[⨯⤓   —    ⤢]"

LAYOUT="Minimize Right"
LAYOUTS+=("${LAYOUT}")
LAYOUTS_PATHS["${LAYOUT}"]="Minimize%20Right/"
LAYOUTS_SETTINGS["${LAYOUT}"]="'close:minimize,maximize'"
LAYOUTS_TITLEBARS["${LAYOUT}"]="[⨯    —   ⤓⤢]"

LAYOUT="MacOS"
LAYOUTS+=("${LAYOUT}")
LAYOUTS_PATHS["${LAYOUT}"]="macOS/"
LAYOUTS_SETTINGS["${LAYOUT}"]="'close,minimize,maximize'"
LAYOUTS_TITLEBARS["${LAYOUT}"]="[⨯⤓⤢  —     ]"

LAYOUT="Ubuntu"
LAYOUTS+=("${LAYOUT}")
LAYOUTS_PATHS["${LAYOUT}"]="Ubuntu/"
LAYOUTS_SETTINGS["${LAYOUT}"]="'close,maximize,minimize'"
LAYOUTS_TITLEBARS["${LAYOUT}"]="[⨯⤢⤓  —     ]"

LAYOUT="Windows"
LAYOUTS+=("${LAYOUT}")
LAYOUTS_PATHS["${LAYOUT}"]="Windows/"
LAYOUTS_SETTINGS["${LAYOUT}"]="':minimize,maximize,close'"
LAYOUTS_TITLEBARS["${LAYOUT}"]="[     —  ⤓⤢⨯]"

LAYOUT="Replace Maximize to Minimize"
LAYOUTS+=("${LAYOUT}")
LAYOUTS_PATHS["${LAYOUT}"]="Replace%20Maximize%20to%20Minimize/"
LAYOUTS_SETTINGS["${LAYOUT}"]="'close:minimize'"
LAYOUTS_TITLEBARS["${LAYOUT}"]="[⨯    —    ⤓]"

PRIVATE_MODE_PATH="Private%20Mode%20Style/"
TITLEBAR_ENABLED_PATH="Titlebar%20Enabled/"

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
  for INDEX in "${!LAYOUTS[@]}"; do
    LAYOUT="${LAYOUTS[${INDEX}]}"
    TITLEBAR="${LAYOUTS_TITLEBARS[${LAYOUT}]}"
    printf "%3s. %-30s %s\n" "$((INDEX+1))" "${LAYOUT}" "${TITLEBAR}"
  done
)

When Firefox window uses native titlebar (by default is not) Firefox Elementary
Theme requires special stylesheet, which is completelly indifferent to controls
layout. Installation script will detect is Firefox using native titlebar or not
and will select corresponding theme stylesheet.

Installation script supports:

$(
  for INDEX in "${!BROWSERS[@]}"; do
    printf "%3s. %s\n" "$((INDEX+1))" "${BROWSERS[${INDEX}]}"
  done
)

For best experience with Firefox Elementary Theme it is recommended to use
${DEFAULT_BROWSER}. Other installations has limited support.

We welcome contributions like editing a userChrome, for example to make a fully
supported Flatpak version possible. Thanks in advance.

See more at theme homepage https://github.com/Zonnev/elementaryos-firefox-theme

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

--controls-layout <layout>

  Forces installation of theme for specified window controls layout. Layout may
  be specified by name or number. By default installation script will detect
  window controls layout, this option disables auto-detection. This option is
  not compatible with '--native-titlebar yes' and '--private-mode-style' options.

  Example: ${APP_EXECUTABLE} --controls-layout 'Elementary Reversed'
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

  Force private mode style (purple colours) for all windows. Suitable for
  Elementary window controls layout and disabled native titlebar only.
  This option is not compatible with '--controls-layout' and
  '--private-mode-style'.

  Example: ${APP_EXECUTABLE} --private-mode-style

--skip-preferences-patch

  This preference disables Firefox preferences patching:

    1. 'toolkit.legacyUserProfileCustomizations.stylesheets'. This preference
       must be turned on to use theme stylesheets. Script default behavour is
       turn preference on if not yet;
    2. 'browser.tabs.inTitlebar'. This preference define whether Firefox window
       use native titlebar or not. Script may want to switch this preference
       when '--native-titlebar yes|no' options is used.

  Patching Firefox preferences requires no Firefox process to be running. By
  default script will ask user to shut down all Firefox processe before
  patching preferences, so when this option is used, script won't ask user to
  shut down Firefox processes.

  Example: ${APP_EXECUTABLE} --skip-preferences-patch
"

# #############################################################################
#  Parse options
# #############################################################################

declare -a BROWSER_PROFILES
BROWSER_PROFILES=()
CONTROLS_LAYOUT=""
NATIVE_TITLEBAR=""
PATCH_PREFERENCES="yes"
PRIVATE_MODE_STYLE="no"
REPOSITORY_FILES_URL="https://raw.githubusercontent.com/Zonnev/elementaryos-firefox-theme/elementaryos-firefox-theme"

LOG_PADDING=""

function increaseLogPadding {
  LOG_PADDING="${LOG_PADDING}  "
}

function decreaseLogPadding {
  LOG_PADDING="${LOG_PADDING:0:-2}"
}

function info {
  local MESSAGE="${@}"
  echo "${LOG_PADDING}${MESSAGE}"
}

function error {
  local MESSAGE="${@}"
  echo "${LOG_PADDING}${MESSAGE}" >&2
}

function parseWindowControlsLayout {
  local LAYOUT="${1}"
  for INDEX in "${!LAYOUTS[@]}"; do
    if [ $((${INDEX}+1)) == "${LAYOUT}" ]; then
      echo "${LAYOUTS[${INDEX}]}"
      break
    fi
    if [ "${LAYOUTS[${INDEX}]}" == "${LAYOUT}" ]; then
      echo "${LAYOUT}"
      break
    fi
  done
}

function parseOptions {
  while [ $# -ne 0 ]; do
    case "${1}" in
      "-h"|"--help")
        info "${APP_HELP_MESSAGE}"
        exit 0
        ;;

      "--controls-layout")
        case "${2}" in
          # empty string
          ""|"--"*)
            error ""
            error "Controls layout is not specified."
            error "Try '${APP_EXECUTABLE} --help' to see available controls layouts."
            error ""
            exit 1
            ;;

          # not a number
          *[!0-9]*)
            CONTROLS_LAYOUT="$(parseWindowControlsLayout "${2}")"
            if [ -z "${CONTROLS_LAYOUT}" ]; then
              error ""
              error "Unknown controls layout '${2}' is specified."
              error "Try '${APP_EXECUTABLE} --help' to see available controls layouts."
              error ""
              exit 1
            fi
            shift 2
            ;;

          # number
          *)
            CONTROLS_LAYOUT="$(parseWindowControlsLayout "${2}")"
            if [ -z "${CONTROLS_LAYOUT}" ]; then
              error ""
              error "Unknown controls layout number '${2}' is specified."
              error "Try '${APP_EXECUTABLE} --help' to see available controls layouts."
              error ""
              exit 1
            fi
            shift 2
            ;;
        esac
        ;;

      "--browser-profile")
        BROWSER_PROFILES+=("${2}")
        shift 2
        ;;

      "--native-titlebar")
        if [ "${2}" != "yes" ] && [ "${2}" != "no" ]; then
          error ""
          error "Unknown option value '${2}' is specified."
          error "Expect '--native-titlebar yes' or '--native-titlebar no'."
          error "Try '${APP_EXECUTABLE} --help' to see manual."
          error ""
          exit 1
        fi
        NATIVE_TITLEBAR="${2}"
        shift 2
        ;;

      "--private-mode-style")
        PRIVATE_MODE_STYLE="yes"
        shift
        ;;

      "--skip-preferences-patch")
        PATCH_PREFERENCES="no"
        shift
        ;;

      *)
        error ""
        error "Unknown option: ${1}"
        error "Try '${APP_EXECUTABLE} --help' to see available options."
        error ""
        exit 1
    esac
  done

  if [ ! -z "${CONTROLS_LAYOUT}" ] && [ "${NATIVE_TITLEBAR}" == "yes" ]; then
    error ""
    error "Options '--controls-layout ${CONTROLS_LAYOUT}' and '--native-titlebar yes' are incompatible."
    error "Try '${APP_EXECUTABLE} --help' to see manual."
    error ""
    exit 1
  fi

  if [ ! -z "${CONTROLS_LAYOUT}" ] && [ "${PRIVATE_MODE_STYLE}" == "yes" ]; then
    error ""
    error "Options '--controls-layout ${CONTROLS_LAYOUT}' and '--private-mode-style' are incompatible."
    error "Try '${APP_EXECUTABLE} --help' to see manual."
    error ""
    exit 1
  fi

  if [ "${NATIVE_TITLEBAR}" == "yes" ] && [ "${PRIVATE_MODE_STYLE}" == "yes" ]; then
    error ""
    error "Options '--native-titlebar yes' and '--private-mode-style' are incompatible."
    error "Try '${APP_EXECUTABLE} --help' to see manual."
    error ""
    exit 1
  fi

  if [ "${PRIVATE_MODE_STYLE}" == "yes" ]; then
    NATIVE_TITLEBAR="no"
  fi
}

function detectBrowsersProfiles {
  function findBrowserProfiles {
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

  if [ ${#BROWSER_PROFILES[@]} -eq 0 ]; then
    info "Detect browser profiles"
    increaseLogPadding
    for BROWSER in "${BROWSERS[@]}"; do
      declare -a FOUND_PROFILES
      FOUND_PROFILES=($(findBrowserProfiles "${BROWSERS_PROFILES_ROOT["${BROWSER}"]}"))
      if [ "${#FOUND_PROFILES[@]}" -gt 0 ]; then
        info "- Found ${#FOUND_PROFILES[@]} ${BROWSER} profile(s) at"
        for FOUND_PROFILE in "${FOUND_PROFILES[@]}"; do
          info "  Directory ${FOUND_PROFILE}"
        done
        BROWSER_PROFILES+=("${FOUND_PROFILES[@]}")
      fi
    done
    decreaseLogPadding
  fi

  if [ ${#BROWSER_PROFILES[@]} -eq 0 ]; then
    error ""
    error "Unable to detect browsers profiles."
    error "Please, specify profiles with '--browser-profile' option."
    error "Try '${APP_EXECUTABLE} --help' to see manual."
    error ""
    exit 1
  fi
}

function installThemeAtBrowserProfile {
  function detectBrowser {
    local BROWSER_PROFILE="${1}"
    for BROWSER in "${BROWSERS[@]}"; do
      local BROWSER_PROFILES_ROOT="${BROWSERS_PROFILES_ROOT["${BROWSER}"]}/"
      if [ "${BROWSER_PROFILE:0:${#BROWSER_PROFILES_ROOT}}" == "${BROWSER_PROFILES_ROOT}" ]; then
        echo "${BROWSER}"
        return 0
      fi
    done
    echo "${DEFAULT_BROWSER}"
  }

  function getFirefoxPreference {
    local BROWSER_PROFILE="${1}"
    local PREFERENCES_FILE="${BROWSER_PROFILE}/prefs.js"

    if [ -f "${PREFERENCES_FILE}" ]; then
      local PREFERENCE="${2}"
      local MATCH=$(\
        grep "user_pref(\"${PREFERENCE}\"," "${PREFERENCES_FILE}" || echo "" \
      )
      if [ ! -z "${MATCH}" ]; then
        local CURRENT_VALUE="${MATCH:$((14+${#PREFERENCE})):-2}"
        echo "${CURRENT_VALUE}"
      else
        echo ""
      fi
    fi
  }

  function setFirefoxPreference {
    local BROWSER_PROFILE="${1}"
    local PREFERENCES_FILE="${BROWSER_PROFILE}/prefs.js"
    local BROWSER=$(detectBrowser "${BROWSER_PROFILE}")
    local PREFERENCE="${2}"
    local CURRENT_VALUE=$(getFirefoxPreference "${PREFERENCE}")
    local TARGET_VALUE="${3}"

    if [ "${TARGET_VALUE}" == "${CURRENT_VALUE}" ]; then
      return 0
    fi

    info "Set preference '${PREFERENCE}' to '${TARGET_VALUE}'"
    increaseLogPadding

    while [ ! -z "$(bash -c "${BROWSERS_PROCESS_ID[${BROWSER}]}")" ]; do
      info "Please, close all ${BROWSER} windows."
      info "Press 'Enter' to proceed ..."
      read -s
    done

    local LINE_NUMBER=""

    if [ -f "${PREFERENCES_FILE}" ]; then
      LINE_NUMBER=$(grep -n "user_pref(\"${PREFERENCE}\"," "${PREFERENCES_FILE}" | cut -d':' -f1)
    fi

    if [ -z "${LINE_NUMBER}" ]; then
      echo "user_pref(\"${PREFERENCE}\", ${TARGET_VALUE});" >> "${PREFERENCES_FILE}"
    else
      sed -i "${LINE_NUMBER}s/.*/user_pref(\"${PREFERENCE}\", "${TARGET_VALUE}");/" "${PREFERENCES_FILE}"
    fi

    decreaseLogPadding
  }

  function delectControlsLayout {
    if [ -z "${CONTROLS_LAYOUT}" ]; then
      if ! (which gsettings >/dev/null); then
        error ""
        error "Unable to detect window controls layout. Util gsettings is not installed."
        error "Please, install gsettings or specify layout with '--controls-layout' option."
        error "Try '${APP_EXECUTABLE} --help' to see manual."
        error ""
        exit 1
      fi

      local GALA_BUTTON_LAYOUT="$(gsettings get org.pantheon.desktop.gala.appearance button-layout)"
      local WM_BUTTON_LAYOUT="$(gsettings get org.gnome.desktop.wm.preferences button-layout)"
      local BUTTON_LAYOUT=""

      if [ ! -z "${GALA_BUTTON_LAYOUT}" ]; then
        BUTTON_LAYOUT="${GALA_BUTTON_LAYOUT}"
      elif [ ! -z "${WM_BUTTON_LAYOUT}" ]; then
        BUTTON_LAYOUT="${GALA_BUTTON_LAYOUT}"
      fi

      if [ ! -z "${BUTTON_LAYOUT}" ]; then
        for LAYOUT in "${!LAYOUTS_SETTINGS[@]}"; do
          if [ "${BUTTON_LAYOUT}" == "${LAYOUTS_SETTINGS[${LAYOUT}]}" ]; then
            CONTROLS_LAYOUT="${LAYOUT}"
            break
          fi
        done
      fi

      if [ -z "${CONTROLS_LAYOUT}" ]; then
        error ""
        error "Unable to detect window controls layout."
        error "Please, specify layout with '--controls-layout' option."
        error "Try '${APP_EXECUTABLE} --help' to see manual."
        error ""
        exit 1
      fi
    fi
  }

  function getBrowserNativeTitlebarEnabled {
    local BROWSER_PROFILE="${1}"
    local CURRENT_VALUE=$(\
      getFirefoxPreference "${BROWSER_PROFILE}" "browser.tabs.inTitlebar" \
    )
    case "${CURRENT_VALUE}" in
      "0")
        echo "yes"
        ;;
      "1")
        echo "no"
        ;;
      *)
        echo "no"
        ;;
    esac
  }

  function setBrowserNativeTitlebarEnabled {
    local BROWSER_PROFILE="${1}"
    local CURRENT_VALUE=$(getBrowserNativeTitlebarEnabled "${BROWSER_PROFILE}")
    local TARGET_VALUE="${2}"

    if [ "${TARGET_VALUE}" == "${CURRENT_VALUE}" ]; then
      return 0
    fi

    if [ "${TARGET_VALUE}" == "yes" ]; then
      setFirefoxPreference "${BROWSER_PROFILE}" "browser.tabs.inTitlebar" "0"
    else
      setFirefoxPreference "${BROWSER_PROFILE}" "browser.tabs.inTitlebar" "1"
    fi
  }

  function getBrowserUsesLegacyStylesheets {
    local BROWSER_PROFILE="${1}"
    local CURRENT_VALUE=$(\
      getFirefoxPreference "${BROWSER_PROFILE}" \
        "toolkit.legacyUserProfileCustomizations.stylesheets" \
    )
    case "${CURRENT_VALUE}" in
      "true")
        echo "yes"
        ;;
      "false")
        echo "no"
        ;;
      *)
        echo "no"
        ;;
    esac
  }

  function setBrowserUsesLegacyStylesheets {
    local BROWSER_PROFILE="${1}"
    local CURRENT_VALUE=$(getBrowserUsesLegacyStylesheets "${BROWSER_PROFILE}")
    local TARGET_VALUE="yes"

    if [ "${TARGET_VALUE}" == "${CURRENT_VALUE}" ]; then
      return 0
    fi

    setFirefoxPreference "${BROWSER_PROFILE}" \
      "toolkit.legacyUserProfileCustomizations.stylesheets" "true"
  }

  function installStyleSheets {
    local BROWSER_PROFILE="${1}"
    local STYLE_SHEETS_PATH="${2}"
    local CHROME_DIR="${BROWSER_PROFILE}/chrome"
    local USER_CHROME_FILE="${CHROME_DIR}/userChrome.css"
    local USER_CONTENT_FILE="${CHROME_DIR}/userContent.css"
    local USER_CHROME_URL="${REPOSITORY_FILES_URL}/${STYLE_SHEETS_PATH}userChrome.css"
    local USER_CONTENT_URL="${REPOSITORY_FILES_URL}/${STYLE_SHEETS_PATH}userContent.css"

    info "Install stylesheets at ${BROWSER_PROFILE}"
    increaseLogPadding
    info "Ensure chrome directory"
    mkdir -p "${CHROME_DIR}"
    info "Downalod stylesheets to chrome directory"
    wget --output-document="${USER_CHROME_FILE}" --quiet "${USER_CHROME_URL}"
    wget --output-document="${USER_CONTENT_FILE}" --quiet "${USER_CONTENT_URL}"
    decreaseLogPadding
  }

  local BROWSER=$(detectBrowser "${BROWSER_PROFILE}")

  info "Installing theme for ${BROWSER} profile ${BROWSER_PROFILE}"
  increaseLogPadding

  if [ "${PATCH_PREFERENCES}" == "yes" ]; then
    setBrowserUsesLegacyStylesheets "${BROWSER_PROFILE}" "yes"
    if [ ! -z "${NATIVE_TITLEBAR}" ]; then
      setBrowserNativeTitlebarEnabled "${BROWSER_PROFILE}" "${NATIVE_TITLEBAR}"
    fi
  fi

  if [ "${PRIVATE_MODE_STYLE}" == "yes" ]; then
    installStyleSheets "${BROWSER_PROFILE}" "${PRIVATE_MODE_PATH}"
  elif [ $(getBrowserNativeTitlebarEnabled "${BROWSER_PROFILE}") == "yes" ]; then
    installStyleSheets "${BROWSER_PROFILE}" "${TITLEBAR_ENABLED_PATH}"
  else
    delectControlsLayout
    installStyleSheets "${BROWSER_PROFILE}" "${LAYOUTS_PATHS[${CONTROLS_LAYOUT}]}"
  fi

  decreaseLogPadding
}

parseOptions "${@}"
detectBrowsersProfiles
for BROWSER_PROFILE in "${BROWSER_PROFILES[@]}"; do
  installThemeAtBrowserProfile
done
info "Done! Please, restart browser."
