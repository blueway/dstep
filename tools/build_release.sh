#!/bin/bash

set -ex

app_name="dstep"
target_dir="bin"
target_path="$target_dir/$app_name"

function configure {
  local os=$(os)
  local default_flags="--llvm-path tmp/clang"

  if [ "$os" = 'macos' ]; then
    ./configure --statically-link-clang $default_flags
  elif [ "$os" = 'linux' ]; then
    ./configure --statically-link-binary $default_flags
  elif [ "$os" = 'freebsd' ]; then
    ./configure --statically-link-binary $default_flags
  else
    echo "Platform not supported: $os"
    exit 1
  fi
}

function build {
   sudo apt-get install gcc-multilib
  dub build -b release --verror --arch=x86
  strip "$target_path"
}

function test_dstep {
  dub -c test-functional --verror
}

function version {
  "$target_path" --version
}

function arch {
  uname -m
}

function os {
  os=$(uname | tr '[:upper:]' '[:lower:]')
  [ $os = 'darwin' ] && echo 'macos' || echo $os
}

function release_name {
  local release_name="$app_name-$(version)-$(os)"

  if [ "$(os)" = 'macos' ]; then
    echo "$release_name"
  else
    echo "$release_name-$(arch)"
  fi
}

function archive {
  tar Jcf "$(release_name)".tar.xz -C "$target_dir" "$app_name"
}

configure
build
test_dstep
archive
