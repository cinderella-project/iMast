# Uncomment the next line to define a global platform for your project
source 'https://cdn.cocoapods.org/'

abstract_target 'iMastShared' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'SwiftLint', '~> 0.39.2'
  pod 'Alamofire', '~> 4.9.1'
  pod 'GRDB.swift', '~> 4.6.2'
  pod 'SwiftyJSON', '~> 5.0.0'
  pod 'HydraAsync', '~> 2.0.2'
  pod 'SDWebImage', '~> 5.8.3'
  pod 'SDWebImageWebPCoder', '~> 0.6.1'
  pod 'Fuzi', '~> 3.1.2'
  pod 'SnapKit', '~> 5.0.1'
  pod '※ikemen', '~> 0.6.0'
  pod 'KeychainAccess', '~> 4.2.0'
  pod 'SwiftGen', '~> 6.2.1'
  pod "STRegex", "~> 2.1.1"
  
  abstract_target 'iOS' do
    platform :ios, '13.2'
    
    pod 'Mew', :git => 'https://github.com/rinsuki/Mew.git', :branch => "fix/podspec"
    
    target 'iMast' do
      # Pods for iMast
      pod 'Crossroad', '~> 3.2.0'
      pod 'Starscream', '~> 3.1.1'
      pod 'ReachabilitySwift', '~> 4.3.1'
      pod 'Eureka', '~> 5.2.1'
      pod 'EurekaFormBuilder', '~> 0.2.1'
      pod 'SVProgressHUD'
      pod 'Notifwift', '~> 1.1.1'
      pod 'LicensePlist', '~> 2.16.0'
      
      target 'iMastTests' do
        inherit! :search_paths
        # Pods for testing
      end

      target 'iMastUITests' do
        inherit! :search_paths
        # Pods for testing
      end
    end


    target 'iMastShare' do
    end

    target 'iMastTodayWidget' do
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
    target 'iMast-Mac' do
    end

    target 'iMastMacCore' do
    end
  end
end
