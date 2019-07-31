ENV['COCOAPODS_DISABLE_STATS'] = "true"

platform :ios, '11.0'

#use_frameworks!

# Only download the files, do not create Xcode projects
install! 'cocoapods', integrate_targets: false

target 'Backit' do
    pod 'NewRelic'
end

target 'BackitTests' do
    pod 'AutoEquatable'
#    pod 'KIF/IdentifierTests'
    pod 'Spry'
    pod 'Spry+Nimble'
end
