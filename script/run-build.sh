#!/bin/bash

dir="$(dirname "$0")"
build_dir="$1"
node_version="$2"
ruby_version="$3"
yarn_version="$4"
cmd="$5"

BUILD_COMMAND_PARSER=$(cat <<EOF
$cmd
EOF
)

. "$dir/run-build-functions.sh"

cd $build_dir

echo "Installing dependencies"
install_dependencies $node_version $ruby_version $yarn_version

echo "Installing missing commands"
install_missing_commands

echo "Executing user command: $cmd"
`$cmd` > out.log 2> err.log
CODE=$?

echo "Caching artifacts"
cache_artifacts

exit $CODE
