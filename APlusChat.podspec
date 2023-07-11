

Pod::Spec.new do |spec|

  spec.name         = "APlusChat"
  spec.version      = "0.0.2.0.7"

  spec.summary      = "APlusChat Chat is light weight SDK use for Chat."
  spec.description  = "Plus Chat is light weight SDK use Socket.io for Real Time Communication."


  spec.homepage     = "https://github.com/pranayprajapati/APlusChat"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author       = { "pranayprajapati" => "pranay.prajapati@auxanoglobalservices.com" }


  spec.ios.deployment_target = "13.0"

  spec.platform     = :ios, "13.0"

  spec.swift_versions = "5.0"
  
  spec.source       = { :git => "https://github.com/pranayprajapati/APlusChat.git", :tag => spec.version.to_s }


#  spec.source_files  = "APlus", "APlus/**/*.{h, m, swift}"
  spec.source_files  = "APlus/Classes/**/*"
#  spec.public_header_files = 'APlus/Classes/**/*.h'


  spec.resources = "APlus/**/*.{png, jpeg, jpg, storyboard, xib, xcasset}"
#  spec.resources = "APlus/**/*.{png, jpeg, jpg, storyboard, xib, xcasset, xcassets}"


  #spec.resource_bundle = "APlus/*/Media.xcassets"
  #spec.public_header_files = "Classes/**/*.h"

  Spec.ios.vendored_frameworks = 'Frameworks/APlus.frameworks'


  spec.framework  = "UIKit"

  spec.dependency "Socket.IO-Client-Swift"
  spec.dependency "ProgressHUD" 
  spec.dependency "JGProgressHUD" 

end
