

Pod::Spec.new do |spec|

  spec.name         = "APlus"
  spec.version      = "0.1.2.1.4"
  spec.summary      = "APlus Chat is light weight SDK use for ChatSocket"

  spec.description  = "Plus Chat is light weight SDK use Socket.io for Real Time Communication"

  spec.homepage     = "https://github.com/AshishRathod84/APlusChat"

  spec.license      = "MIT"


  spec.author             = { "AshishRathod84" => "ashish.rathod@auxanoglobalservices.com" }


   spec.platform     = :ios, "14.0"
   spec.swift_versions = "5.0"


  spec.source       = { :git => "https://github.com/AshishRathod84/APlusChat.git", :tag => spec.version.to_s }


  spec.source_files  = "APlus", "APlus/**/*.{h,m,swift}"
  spec.resources = "APlus/**/*.{png,jpeg,jpg,storyboard,xib,xcasset}"

  #spec.resource_bundle = "APlus/*/Media.xcassets"

  spec.framework  = "UIKit"

  spec.dependency "Socket.IO-Client-Swift"
  spec.dependency "ProgressHUD" 
  spec.dependency "JGProgressHUD" 

end
