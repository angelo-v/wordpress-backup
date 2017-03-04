#!/bin/bash

# kill script if any test script fails
set -e

cd ./test &&
bundle install &&
for file in *_spec.rb
do
  rspec $file # run all test files separetly, so that different container instances can be tested
done
