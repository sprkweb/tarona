#!/bin/sh
BIN_PATH=$(dirname -- "$0")
PROJ_PATH=$(dirname -- "$BIN_PATH")
# TODO: Env будут не нужны при bundler standalone mode
# GEM_HOME=$PROJ_PATH/vendor/bundle/$PLATFORM GEM_PATH=$PROJ_PATH/vendor/bundle/$PLATFORM
$PROJ_PATH/vendor/ruby/bin/ruby $BIN_PATH/tarona
