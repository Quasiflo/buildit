#!/usr/bin/env bash
if [ -n "$REMOTE_CONTAINERS" ]; then
	echo "Skipping gen_devcontainer in devcontainer"
	exit 0
fi

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
	echo "Not in a Git repository"
	exit 1
}

LOCAL_GIT_DIR=$(git rev-parse --absolute-git-dir)                       # Must be absolute
COMMON_GIT_DIR=$(git rev-parse --path-format=absolute --git-common-dir) # Must be absolute
RELATIVE_LOCAL_GIT_DIR=''

# Ensure no trailing slash
LOCAL_GIT_DIR=${LOCAL_GIT_DIR%/}
COMMON_GIT_DIR=${COMMON_GIT_DIR%/}

if [ "$LOCAL_GIT_DIR" = "$COMMON_GIT_DIR" ]; then
	IS_WORKTREE="false"
	echo "In main worktree (or subdirectory thereof)"
	echo "Real .git folder: $COMMON_GIT_DIR"
else
	IS_WORKTREE="true"
	RELATIVE_LOCAL_GIT_DIR=${LOCAL_GIT_DIR#"$COMMON_GIT_DIR/"}
	GIT_WORKTREE_PROJECT_NAME=$(basename "$RELATIVE_LOCAL_GIT_DIR")
	echo "In linked worktree (or subdirectory thereof)"
	echo "Real .git folder: $COMMON_GIT_DIR"
	echo "Per-worktree gitdir: $LOCAL_GIT_DIR"
	echo "Relative local gitdir: $RELATIVE_LOCAL_GIT_DIR"
fi

export IS_WORKTREE
export COMMON_GIT_DIR
export RELATIVE_LOCAL_GIT_DIR
export GIT_WORKTREE_PROJECT_NAME

pkl eval --output-path .devcontainer/devcontainer.json .devcontainer/devcontainer.pkl
