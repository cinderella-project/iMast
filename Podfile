# Uncomment the next line to define a global platform for your project
source 'https://cdn.cocoapods.org/'

abstract_target 'iMastShared' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'SwiftLint', '~> 0.37.0'
  pod 'Alamofire', '~> 4.9.1'
  pod 'GRDB.swift', '~> 4.6.2'
  pod 'SwiftyJSON', '~> 5.0.0'
  pod 'HydraAsync', '~> 2.0.2'
  pod 'XCGLogger', '~> 7.0.0'
  pod 'SDWebImage', '~> 5.3.2'
  pod 'SDWebImageWebPCoder', '~> 0.2.5'
  pod 'Fuzi', '~> 3.1.1'
  pod 'SnapKit', '~> 5.0.1'
  pod '※ikemen', '~> 0.6.0'
  pod 'KeychainAccess', '~> 4.1.0'
  pod 'SwiftGen', '~> 6.1.0'
  pod "STRegex", "~> 2.1"
  
  abstract_target 'iOS' do
    platform :ios, '13.2'
    
    pod 'Mew', :git => 'https://github.com/rinsuki/Mew.git', :branch => "fix/podspec"
    pod 'R.swift', '~> 5.1.0'
    
    target 'iMast' do
      # Pods for iMast
      pod 'Crossroad', '~> 3.0.1'
      pod 'Starscream', '~> 3.1.1'
      pod 'ReachabilitySwift', '~> 4.3.1'
      pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka', :commit => '41bbb0ace994dcbbb706228baa850cd678f69fb3'
      pod 'EurekaFormBuilder', '~> 0.2.1'
      pod 'SVProgressHUD'
      pod 'Notifwift', '~> 1.1.1'
      # If you want to build Catalyst version of iMast, please comment out next one line
      pod '1PasswordExtension', '~> 1.8.5'
      pod 'LicensePlist', '~> 2.9.0'
      
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
