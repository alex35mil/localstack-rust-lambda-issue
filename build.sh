#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

BIN=$1

TARGET_DIR=target/lambda
RELEASE_DIR=$TARGET_DIR/release
PACKAGE_DIR=$TARGET_DIR/$BIN

export CARGO_HOME=/cargo
export RUSTUP_HOME=/rustup
export CARGO_TARGET_DIR=$PWD/$TARGET_DIR

source /cargo/env

mkdir -p $TARGET_DIR
cargo build --release --bin $BIN
rm -rf $PACKAGE_DIR 2>/dev/null || true
mkdir -p $PACKAGE_DIR
cp $RELEASE_DIR/$BIN $PACKAGE_DIR/bootstrap
