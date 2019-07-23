#!/bin/bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf Pods
rm -rf Carthage
carthage update --platform iOS
