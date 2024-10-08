#!/usr/bin/env bash

set -x

if [ -z "$1" ]; then
  echo "usage: $0 [-m|--monorepo]  NewProjectName Destination"
  exit 1
fi

SED="sed"
if [ "$(uname)" = "Darwin" ]; then
  SED="gsed"
fi

MONOREPO_FLAG=0

# Parse the arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--monorepo)
      MONOREPO_FLAG=1
      shift
      ;;
    *)
      break
      ;;
  esac
done

NAME_CC=$1
DST=$2

IGNORE=(".git" ".idea" "bazel-*" "create-proj.sh" "MODULE.bazel.lock" ".ijwb")

# Add monorepo-specific files to ignore list if the flag is set
if [ "$MONOREPO_FLAG" -eq 1 ]; then
  IGNORE+=("MODULE.bazel" "LICENSE.md" "WORKSPACE" ".bazelrc" ".gitignore")
fi

NAME_LC=$(echo "$NAME_CC" | tr '[:upper:]' '[:lower:]')
NAME_PC="$(tr '[:upper:]' '[:lower:]' <<< ${NAME_CC:0:1})${NAME_CC:1}"

RE_CC="s/KtProjStarter/$NAME_CC/g"
RE_LC="s/ktprojstarter/$NAME_LC/g"
RE_PC="s/ktProjStarter/$NAME_PC/g"

echo "sed is $SED"
echo "CamelCase: $NAME_CC"
echo "lowercase: $NAME_LC"
echo "pascalCase: $NAME_PC"
echo "ignoring: ${IGNORE[@]}"

TEMPLATE_ROOT=$(git rev-parse --show-toplevel)
PROJECT_ROOT="$DST/$NAME_LC"

mkdir -p "$PROJECT_ROOT"

exclude_options=()
for item in "${IGNORE[@]}"; do
  exclude_options+=("--exclude=${item}")
done

echo "excluding: ${exclude_options[@]}"

rsync -av "${exclude_options[@]}" "$TEMPLATE_ROOT/" "$PROJECT_ROOT"

rename_and_replace() {
  for f in $(ls -d -1 $1/*)
  do
    local nf=$(echo "$f" | $SED "$RE_CC" | $SED "$RE_LC" | $SED "$RE_PC")
    if [ "$f" != "$nf" ]; then
      mv "$f" "$nf"
    fi
    echo "file: $nf"
    if [ -f "$nf" ]; then
      $SED -i "$RE_CC" "$nf"
      $SED -i "$RE_LC" "$nf"
      $SED -i "$RE_PC" "$nf"
    fi
    if [ -d "$nf" ]; then
      rename_and_replace "$nf"
    fi
  done
}

#rename_and_replace "$PROJECT_ROOT"