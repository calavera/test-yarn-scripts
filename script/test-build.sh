#!/bin/bash

# Usage: script/test-build.sh PATH_TO_GIT_REPO BUILD_COMMAND
#
# Example with clean git clone:
# 	script/test-build.sh ../netlify-cms 'npm run build'
#
# Example with previous cached build:
#	T=/tmp/cache script/test-build.sh ../netlify-cms 'npm run build'

set -e


NODE_VERSION="6"
RUBY_VERSION="2.3"
YARN_VERSION="0.18.0"
REPO_URL=$1

mkdir -p tmp
if [ $(uname -s) == "Darwin" ]; then
  : ${T=`mktemp -d tmp/tmp.XXXXXXXXXX`}
else
  : ${T=`mktemp -d -p tmp`}
fi

echo "Using temp dir: $T"
chmod +w $T
mkdir -p $T/scripts

cp script/run-build* $T/scripts
chmod +x $T/scripts/*

rm -rf $T/repo
git clone $REPO_URL $T/repo

# This script runs as root but
# pivots to the buildbot user to
# actually run the user's build command.
# That way we can setup and teardown the cache properly.
SCRIPT="mkdir /opt/build && \
	cp -r /opt/base/* /opt/build && \
	chown -R buildbot /opt/build && \
	sudo -H -u buildbot bash -c \"/opt/build/scripts/run-build.sh /opt/build/repo $NODE_VERSION $RUBY_VERSION $YARN_VERSION '$2'\"; \
	rm -rf /opt/base/cache && mv /opt/build/cache /opt/base/cache"

docker run --rm \
	--security-opt seccomp:unconfined \
	-e "NETLIFY_VERBOSE=1" \
	-v $PWD/$T/:/opt/base \
	-u root \
	-it \
	netlify/build sh -c "$SCRIPT"
