

Pod::Spec.new do |spec|

  spec.name         = "APlusChat"
  spec.version      = "0.0.1.4"
  spec.summary      = "APlusChat Chat is light weight SDK use for ChatSocket."

  spec.description  = "Plus Chat is light weight SDK use Socket.io for Real Time Communication."

  spec.homepage     = "https://github.com/pranayprajapati/APlusChat"

  spec.license      = "MIT"


  spec.author       = { "pranay.prajapati" => "pranay.prajapati@auxanoglobalservices.com" }


  spec.platform     = :ios, "12.5"
  spec.swift_versions = "5.0"
  
  spec.source       = { :git => "https://github.com/pranayprajapati/APlusChat.git", :tag => spec.version.to_s }


  spec.source_files  = "APlus", "APlus/**/*.{h,m,swift}"
  spec.resources = "APlus/**/*.{png,jpeg,jpg,storyboard,xib,xcasset}"

  #spec.resource_bundle = "APlus/*/Media.xcassets"
  #spec.public_header_files = "Classes/**/*.h"

  spec.framework  = "UIKit"

  spec.dependency "Socket.IO-Client-Swift"
  spec.dependency "ProgressHUD" 
  spec.dependency "JGProgressHUD" 

end
