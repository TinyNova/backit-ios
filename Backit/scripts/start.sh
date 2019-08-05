#!/bin/bash
./scripts/clean.sh
./scripts/carthage.sh
xcodegen
./scripts/open.sh
