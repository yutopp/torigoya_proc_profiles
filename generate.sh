#!/usr/bin/env bash

# check existence of bundler
which bundle &> /dev/null
if [ $? != 0 ]; then
    echo "generate error: please install 'bundler' gem package"
    exit -1
fi

cd _generator || exit -1
if [ ! -e vendor ]; then
    bundle install --path vendor/bundler || exit -1
fi

bundle exec ruby generate-profiles.rb "$@"
