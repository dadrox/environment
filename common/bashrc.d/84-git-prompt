#!/bin/sh

function async_run()
{
  {
    $1 &> /dev/null
  }&
}

function git_prompt_dir()
{
  # assume the gitstatus.py is in the same directory as this script
  # code thanks to http://stackoverflow.com/questions/59895
  if [ -z "${__GIT_PROMPT_DIR}" ]; then
    local SOURCE="${BASH_SOURCE[0]}"
    while [ -h "${SOURCE}" ]; do
      local DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
      SOURCE="$(readlink "${SOURCE}")"
      [[ $SOURCE != /* ]] && SOURCE="${DIR}/${SOURCE}"
    done
    __GIT_PROMPT_DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
  fi
}

function git_prompt_config()
{

  # source the user's ~/.git-prompt-colors.sh file, or the one that should be
  # sitting in the same directory as this script

  if [[ -z "$__GIT_PROMPT_COLORS_FILE" ]]; then
    local pfx file dir
    for dir in "$HOME" "$__GIT_PROMPT_DIR" ; do
      for pfx in '.' '' ; do
        file="$dir/${pfx}git-prompt-colors.sh"
        if [[ -f "$file" ]]; then
          __GIT_PROMPT_COLORS_FILE="$file"
          break 2
        fi
      done
    done
  fi
  # if the envar is defined, source the file for custom colors
  if [[ -n "$__GIT_PROMPT_COLORS_FILE" && -f "$__GIT_PROMPT_COLORS_FILE" ]]; then
    source "$__GIT_PROMPT_COLORS_FILE"
  else
    # Default values for the appearance of the prompt.  Do not change these
    # below.  Instead, copy these to `~/.git-prompt-colors.sh` and change them
    # there.
    GIT_PROMPT_PREFIX="["
    GIT_PROMPT_SUFFIX="]"
    GIT_PROMPT_SEPARATOR="|"
    GIT_PROMPT_BRANCH="$Magenta"
    GIT_PROMPT_STAGED="$Red●"
    GIT_PROMPT_CONFLICTS="$Red✖"
    GIT_PROMPT_CHANGED="$Blue✚"
    GIT_PROMPT_REMOTE=" "
    GIT_PROMPT_UNTRACKED="$Cyan…"
    GIT_PROMPT_STASHED="$Bold$Blue⚑"
    GIT_PROMPT_CLEAN="$Bold$Green✔"
  fi

  # set GIT_PROMPT_LEADING_SPACE to 0 if you want to have no leading space in front of the GIT prompt
  if [ "x${GIT_PROMPT_LEADING_SPACE}" == "x0" ]; then
    PROMPT_LEADING_SPACE=""
  else
    PROMPT_LEADING_SPACE=" "
  fi

  if [[ -n "${VIRTUAL_ENV}" ]]; then
    EMPTY_PROMPT="(${Blue}$(basename "${VIRTUAL_ENV}")${Reset}) ${PROMPT_START}$($prompt_callback)${PROMPT_END}"
  else
    EMPTY_PROMPT="${PROMPT_START}$($prompt_callback)${PROMPT_END}"
  fi

  # fetch remote revisions every other $GIT_PROMPT_FETCH_TIMEOUT (default 5) minutes
  GIT_PROMPT_FETCH_TIMEOUT=${1-5}
  if [ "x$__GIT_STATUS_CMD" == "x" ]
  then
    git_prompt_dir
    local sfx file
    # look first for a '.sh' version, then use the python version
    for sfx in sh py ; do
      file="${__GIT_PROMPT_DIR}/gitstatus.$sfx"
      if [[ -x "$file" ]]; then
        __GIT_STATUS_CMD="$file"
        break
      fi
    done
  fi
}

function setGitPrompt() {

  local EMPTY_PROMPT
  local __GIT_STATUS_CMD

  git_prompt_config

  local repo=`git rev-parse --show-toplevel 2> /dev/null`
  if [[ ! -e "${repo}" ]]; then
    Git_Prompt="${EMPTY_PROMPT}"
    return
  fi

  checkUpstream
  updatePrompt
}

function checkUpstream() {
  local GIT_PROMPT_FETCH_TIMEOUT
  git_prompt_config

  local FETCH_HEAD="${repo}/.git/FETCH_HEAD"
  # Fech repo if local is stale for more than $GIT_FETCH_TIMEOUT minutes
  if [[ ! -e "${FETCH_HEAD}"  ||  -e `find "${FETCH_HEAD}" -mmin +${GIT_PROMPT_FETCH_TIMEOUT}` ]]
  then
    if [[ -n $(git remote show) ]]; then
      (
        async_run "git fetch --quiet"
        disown -h
      )
    fi
  fi
}

function updatePrompt() {
  local GIT_PROMPT_PREFIX
  local GIT_PROMPT_SUFFIX
  local GIT_PROMPT_SEPARATOR
  local GIT_PROMPT_BRANCH
  local GIT_PROMPT_STAGED
  local GIT_PROMPT_CONFLICTS
  local GIT_PROMPT_CHANGED
  local GIT_PROMPT_REMOTE
  local GIT_PROMPT_UNTRACKED
  local GIT_PROMPT_STASHED
  local GIT_PROMPT_CLEAN
  local PROMPT_LEADING_SPACE
  local PROMPT_START
  local PROMPT_END
  local EMPTY_PROMPT
  local GIT_PROMPT_FETCH_TIMEOUT
  local __GIT_STATUS_CMD

  git_prompt_config

  local -a GitStatus
  GitStatus=($("${__GIT_STATUS_CMD}" 2>/dev/null))

  local GIT_BRANCH=${GitStatus[0]}
  local GIT_BEHIND=${GitStatus[1]}
  local GIT_AHEAD=${GitStatus[2]}
  local GIT_STAGED=${GitStatus[3]}
  local GIT_CONFLICTS=${GitStatus[4]}
  local GIT_CHANGED=${GitStatus[5]}
  local GIT_UNTRACKED=${GitStatus[6]}
  local GIT_STASHED=${GitStatus[7]}
  local GIT_CLEAN=${GitStatus[8]}

  if [[ -n "${GitStatus}" ]]; then
    local STATUS="${PROMPT_LEADING_SPACE}${GIT_PROMPT_PREFIX}${GIT_PROMPT_BRANCH}${GIT_BRANCH}${Reset}"

    STATUS="${STATUS}${GIT_PROMPT_SEPARATOR}"
    if [ "${GIT_BEHIND}" -ne 0 ]; then
      STATUS="${STATUS}${GIT_PROMPT_BEHIND}${GIT_BEHIND}${Reset}"
    fi

    if [ "${GIT_AHEAD}" -ne 0 ]; then
      STATUS="${STATUS}${GIT_PROMPT_AHEAD}${GIT_AHEAD}${Reset}"
    fi

    if [ "${GIT_BEHIND}" -ne 0 ] || [ "${GIT_AHEAD}" -ne 0 ]; then
      STATUS="${STATUS}${GIT_PROMPT_SEPARATOR}"
    fi

    if [ "${GIT_STAGED}" -ne "0" ]; then
      STATUS="${STATUS}${GIT_PROMPT_STAGED}${GIT_STAGED}${Reset}"
    fi

    if [ "${GIT_CONFLICTS}" -ne "0" ]; then
      STATUS="${STATUS}${GIT_PROMPT_CONFLICTS}${GIT_CONFLICTS}${Reset}"
    fi

    if [ "${GIT_CHANGED}" -ne "0" ]; then
      STATUS="${STATUS}${GIT_PROMPT_CHANGED}${GIT_CHANGED}${Reset}"
    fi

    if [ "${GIT_UNTRACKED}" -ne "0" ]; then
      STATUS="${STATUS}${GIT_PROMPT_UNTRACKED}${GIT_UNTRACKED}${Reset}"
    fi

    if [ "${GIT_STASHED}" -ne "0" ]; then
      STATUS="${STATUS}${GIT_PROMPT_STASHED}${GIT_STASHED}${Reset}"
    fi

    if [ "${GIT_CLEAN}" -eq "1" ]; then
      STATUS="${STATUS}${GIT_PROMPT_CLEAN}"
    fi

    STATUS="${STATUS}${Reset}${GIT_PROMPT_SUFFIX}"


    Git_Prompt="${PROMPT_START}$($prompt_callback)${STATUS}${PROMPT_END}"
    if [[ -n "${VIRTUAL_ENV}" ]]; then
      Git_Prompt="(${Blue}$(basename ${VIRTUAL_ENV})${Reset}) ${Git_Prompt}"
    fi

  else
    Git_Prompt="${EMPTY_PROMPT}"
  fi

export Git_Prompt
}

function prompt_callback_default {
    return
}

if [ "`type -t prompt_callback`" = 'function' ]; then
    prompt_callback="prompt_callback"
else
    prompt_callback="prompt_callback_default"
fi

if [ -z "$OLD_GITPROMPT" ]; then
  OLD_GITPROMPT=$Git_Prompt
fi

if [ -z "$PROMPT_COMMAND" ]; then
  PROMPT_COMMAND=setGitPrompt
else
  PROMPT_COMMAND=${PROMPT_COMMAND%% }; # remove trailing spaces
  PROMPT_COMMAND=${PROMPT_COMMAND%\;}; # remove trailing semi-colon
  PROMPT_COMMAND="$PROMPT_COMMAND;setGitPrompt"
fi

git_prompt_dir
source "$__GIT_PROMPT_DIR/git-prompt-help.sh"
