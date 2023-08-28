Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.name         = "APlusChat"
  spec.version      = "0.0.2.3.7"
  spec.summary      = "APlusChat Chat is light weight SDK use for ChatSocket."

  spec.description  = "Plus Chat is light weight SDK use Socket.io for Real Time Communication."

  spec.homepage     = "https://github.com/pranayprajapati/APlusChat"

  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.license      = "MIT"

  # spec.license      = { :type => "MIT", :file => "LICENSE" }
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.author             = { "pranayprajapati" => "pranay.prajapati@auxanoglobalservices.com" }

  # Or just: spec.author    = "pranayprajapati"
  # spec.authors            = { "pranay-L53" => "pranay.prajapati@auxanoglobalservices.com" }
  # spec.social_media_url   = ""

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.ios.deployment_target = "13.0"
  spec.platform     = :ios, "13.0"
  spec.swift_versions = "5.0"

  # spec.swift_versions = "5.0"

  # spec.platform     = :ios, "5.0"

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source       = { :git => "https://github.com/pranayprajapati/APlusChat.git", :tag => spec.version.to_s }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source_files  = "APlus", "APlus/**/*.{h,m,swift}"
  
  # spec.source_files  = "APlus/**/*.{h,m,swift}"

  # spec.exclude_files = "APlus/Exclude"
  # spec.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.resources  = "APlus/**/*.{png,jpeg,jpg,storyboard,xib,xcasset}"

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"
  # spec.resource_bundle = "APlus/*/Media.xcassets"
  # spec.public_header_files = "Classes/**/*.h"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.framework  = "UIKit"

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.dependency "ProgressHUD"

  # spec.dependency "Socket.IO-Client-Swift"
  # spec.dependency "JGProgressHUD"

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  # spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  # spec.dependency "JSONKit", "~> 1.4"

end
