# Uncomment the next line to define a global platform for your project
source 'https://cdn.cocoapods.org/'
platform :ios, '13.0'

abstract_target 'iMastShared' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'SwiftLint', '~> 0.35.0'
  pod 'Alamofire', '~> 4.9.0'
  pod 'GRDB.swift', '~> 4.4.0'
  pod 'SwiftyJSON', '~> 5.0.0'
  pod 'HydraAsync', '~> 2.0.2'
  pod 'XCGLogger', '~> 7.0.0'
  pod 'SDWebImage', '~> 5.2.0'
  pod 'SDWebImageWebPCoder', '~> 0.2.4'
  pod 'Fuzi', '~> 3.1.1'
  pod 'SnapKit', '~> 5.0.1'
  pod '※ikemen', '~> 0.6.0'
  pod 'R.swift', '~> 5.0.3'
  pod 'Mew', :git => 'https://github.com/rinsuki/Mew.git', :branch => "fix/podspec"
  pod 'KeychainAccess', :git => 'https://github.com/tupperkion/KeychainAccess.git', :commit => "e41375d0ea7bf57ec3b464f75e8ab7e2a126cb85"

  target 'iMast' do
    # Pods for iMast
    pod 'Crossroad', '~> 3.0'
    pod 'Starscream', '~> 3.1.0'
    pod 'ReachabilitySwift', '~> 4.3.1'
    pod 'Eureka', '~> 5.1'
    pod 'EurekaFormBuilder'
    pod 'SVProgressHUD'
    pod 'Notifwift', '~> 1.1.1'
    # If you want to build Catalyst version of iMast, please comment out next one line
    pod '1PasswordExtension', '~> 1.8.5'
    pod 'LicensePlist', '~> 2.6.0'
    
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
end
