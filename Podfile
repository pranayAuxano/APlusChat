# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'APlus' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Socket.IO-Client-Swift'
  pod 'ProgressHUD'
  pod 'JGProgressHUD'

  # Pods for APlus

  target 'APlusTests' do
    # Pods for testing
  end
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   # config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
   config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
  end
 end
end