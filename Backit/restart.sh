#!/bin/bash
./clean.sh
rm -rf Carthage
carthage update --platform iOS
