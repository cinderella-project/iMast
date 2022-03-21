# Uncomment the next line to define a global platform for your project
source 'https://cdn.cocoapods.org/'

abstract_target 'iMastShared' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'SwiftLint', '~> 0.40.3'
  pod 'Alamofire', '~> 4.9.1'
  pod 'GRDB.swift', '~> 4.6.2'
  pod 'SwiftyJSON', '~> 5.0.0'
  pod 'HydraAsync', '~> 2.0.6'
  pod 'SDWebImage', '5.9.1'
  pod 'Fuzi', '~> 3.1.2'
  pod 'SnapKit', '~> 5.0.1'
  pod '※ikemen', '~> 0.6.0'
  pod 'KeychainAccess', '~> 4.2.1'
  pod 'SwiftGen', '~> 6.3.0'
  pod "STRegex", "~> 2.1.1"
  
  abstract_target 'iOS' do
    platform :ios, '14.0'
    
    pod 'Mew', :git => 'https://github.com/rinsuki/Mew.git', :branch => "fix/podspec"
    
    target 'iMast iOS' do
      # Pods for iMast
      pod 'Crossroad', '~> 3.2.0'
      pod 'Starscream', '~> 3.1.1'
      pod 'ReachabilitySwift', '~> 4.3.1'
      pod 'Eureka', '~> 5.3.0'
      pod 'EurekaFormBuilder', '~> 0.2.2'
      pod 'EurekaTwolineSliderRow'
      pod 'SVProgressHUD'
      pod 'LicensePlist', '~> 2.16.0'
      
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
    end
  end
  
  abstract_target 'Mac' do
    platform :osx, '10.15'
    target 'iMast Mac (App Store)' do
    end
    
    target 'iMast Mac (with Sparkle)' do
    end

    target 'iMastMacCore' do
    end
  end
end
