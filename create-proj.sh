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

# Function to replace content in files
replace_content_in_files() {
  echo "Replacing content in files..."
  find "$PROJECT_ROOT" -type f \( -name "*.kt" -o -name "*.java" -o -name "*.yaml" -o -name "*.yml" -o -name "*.md" -o -name "*.txt" -o -name "*.json" -o -name "*.bzl" -o -name "*.bazel" -o -name "BUILD*" -o -name "MODULE.bazel" -o -name "*.sh" \) -exec $SED -i "$RE_CC" {} \;
  find "$PROJECT_ROOT" -type f \( -name "*.kt" -o -name "*.java" -o -name "*.yaml" -o -name "*.yml" -o -name "*.md" -o -name "*.txt" -o -name "*.json" -o -name "*.bzl" -o -name "*.bazel" -o -name "BUILD*" -o -name "MODULE.bazel" -o -name "*.sh" \) -exec $SED -i "$RE_LC" {} \;
  find "$PROJECT_ROOT" -type f \( -name "*.kt" -o -name "*.java" -o -name "*.yaml" -o -name "*.yml" -o -name "*.md" -o -name "*.txt" -o -name "*.json" -o -name "*.bzl" -o -name "*.bazel" -o -name "BUILD*" -o -name "MODULE.bazel" -o -name "*.sh" \) -exec $SED -i "$RE_PC" {} \;
}

# Function to rename directories (deepest first to avoid path issues)
rename_directories() {
  echo "Renaming directories..."
  # Find all directories, sort by depth (deepest first) to avoid path conflicts
  find "$PROJECT_ROOT" -type d | sort -r | while read -r dir; do
    local parent_dir=$(dirname "$dir")
    local dir_name=$(basename "$dir")
    local new_name=$(echo "$dir_name" | $SED "$RE_CC" | $SED "$RE_LC" | $SED "$RE_PC")

    if [ "$dir_name" != "$new_name" ]; then
      local new_path="$parent_dir/$new_name"
      echo "Renaming directory: $dir -> $new_path"
      mv "$dir" "$new_path"
    fi
  done
}

# Function to rename files
rename_files() {
  echo "Renaming files..."
  find "$PROJECT_ROOT" -type f | while read -r file; do
    local parent_dir=$(dirname "$file")
    local file_name=$(basename "$file")
    local new_name=$(echo "$file_name" | $SED "$RE_CC" | $SED "$RE_LC" | $SED "$RE_PC")

    if [ "$file_name" != "$new_name" ]; then
      local new_path="$parent_dir/$new_name"
      echo "Renaming file: $file -> $new_path"
      mv "$file" "$new_path"
    fi
  done
}

# Execute the transformations
echo "Starting project transformation..."
echo "Project root: $PROJECT_ROOT"

# 1. First, replace content in files
replace_content_in_files

# 2. Then rename files
rename_files

# 3. Finally, rename directories (deepest first)
rename_directories

echo "Project transformation completed!"
