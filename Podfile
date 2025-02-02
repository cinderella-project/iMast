# Uncomment the next line to define a global platform for your project
source 'https://cdn.cocoapods.org/'
plugin 'cocoapods-pod-linkage'

abstract_target 'iMastShared' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'SwiftLint', '0.52.4'
  def core_pods
    pod 'GRDB.swift', '~> 4.6.2', :linkage => :static
  end
  pod 'HydraAsync', '~> 2.0.6'
  pod 'SDWebImage', '~> 5.18.10'
  # https://github.com/cezheng/Fuzi/pull/133 is needed for Xcode 16's release build
  pod 'Fuzi', :git => 'https://github.com/rinsuki/Fuzi.git', :commit => '4092585ab3eea9de6c2a92024d3ab5ec3bfc4785'
  pod 'SnapKit', :git => 'https://github.com/SnapKit/SnapKit.git', :tag => '5.7.0'
  pod 'KeychainAccess', '4.2.2'
  pod 'SwiftGen', '6.5.1' # I don't want to include fallback strings in source (ref. https://github.com/SwiftGen/SwiftGen/pull/964 )
  
  abstract_target 'iOS' do
    platform :ios, '16.4'
    
    pod 'Mew', :git => 'https://github.com/rinsuki/Mew.git', :branch => "fix/podspec"
    
    target 'iMast iOS' do
      # Pods for iMast
      pod 'Starscream', '~> 3.1.1'
      pod 'LicensePlist', '~> 3.22.0'
      
      target 'iMastTests' do
        # Pods for testing
      end

      target 'iMastUITests' do
        # Pods for testing
      end
    end


    target 'iMastShare' do
    end

    target 'iMastNotifyService' do
    end

    target 'iMastIntents' do
    end

    target 'iMastiOSCore' do
      core_pods
    end
  end
  
  abstract_target 'Mac' do
    platform :osx, '10.15'
    target 'iMast Mac (App Store)' do
    end
    
    target 'iMast Mac (with Sparkle)' do
    end

    target 'iMastMacCore' do
      core_pods
    end
  end
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.4'
        config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '13.0'
        if config.build_settings['SDKROOT'].include? "iphoneos" then
          config.build_settings['SUPPORTED_PLATFORMS'] = "iphoneos iphonesimulator xros xrsimulator"
        end
      end
    end
  end
end
