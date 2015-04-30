#!/bin/sh


# iTerm2
ITERM2_PREF="com.googlecode.iterm2"
ITERM2_PREFFILE="${ITERM2_PREF}.plist"
ITERM2_PREFFILE_SRC="./plists/${ITERM2_PREFFILE}"
ITERM2_PREFFILE_TGT="~/Library/Preferences/${ITERM2_PREFFILE}"

if [[ -s "${ITERM2_PREFFILE_TGT}" ]]; then
  defaults delete "${ITERM2_PREF}"
  rm -f "${ITERM2_PREFFILE_TGT}"
fi

cp "${ITERM2_PREFFILE_SRC}" "${ITERM2_PREFFILE_TGT}"
defaults read "${ITERM2_PREF}"
