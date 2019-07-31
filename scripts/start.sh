#!/bin/bash
xcodegen && pod install && synx Backit.xcodeproj && open Backit.xcworkspace
