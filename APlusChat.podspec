
Pod::Spec.new do |s|

  s.name         = "APlusChat"
  s.version      = "0.0.2.2.0"
  s.summary      = "APlusChat Chat is light weight SDK use for ChatSocket."

  s.description  = "Plus Chat is light weight SDK use Socket.io for Real Time Communication."

  s.homepage     = "https://github.com/pranayprajapati/APlusChat"
  s.license      = "MIT"

  s.author       = { "pranayprajapati" => "pranay.prajapati@auxanoglobalservices.com" }

  s.ios.deployment_target = "13"
  s.platform     = :ios, "13"
  s.swift_versions = "5.0"
  
  s.source       = { :git => "https://github.com/pranayprajapati/APlusChat.git", :tag => s.version.to_s }

  s.source_files  = "APlus", "APlus/**/*.{h,m,swift}"
  s.resources = "APlus/**/*.{png,jpeg,jpg,storyboard,xib,xcasset}"

  #s.resource_bundle = "APlus/*/Media.xcassets"
  #s.public_header_files = "Classes/**/*.h"

  s.framework  = "UIKit"

  s.dependency "Socket.IO-Client-Swift"
  s.dependency "ProgressHUD" 
  s.dependency "JGProgressHUD" 

end
