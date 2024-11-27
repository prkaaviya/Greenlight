platform :ios, '15.6'

target 'Greenlight' do
  use_frameworks!
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'SQLite.swift', '~> 0.13.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6' # Set your desired version here
    end
  end
end

