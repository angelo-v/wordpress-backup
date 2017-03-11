#!/bin/sh

testinfra -s -v test/*_test.py --connection docker
