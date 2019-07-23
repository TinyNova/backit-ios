#!/bin/bash
carthage update --platform iOS
xcodegen
pod install
open Backit.xcworkspace
