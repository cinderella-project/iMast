# Uncomment the next line to define a global platform for your project
source 'https://cdn.cocoapods.org/'
platform :ios, '13.0'

def based_pods
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
end

target 'iMast' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iMast

  based_pods
  pod 'Crossroad', '~> 3.0'
  pod 'Starscream', '~> 3.1.0'
  pod 'ReachabilitySwift', '~> 4.3.1'
  # for iOS 13 Dark Mode supports
  # after merged https://github.com/xmartlabs/Eureka/pull/1866 , need to change to upstream 
  pod 'Eureka', :git => "https://github.com/ykphuah/Eureka.git", :commit => "60e0668cc3755ef791c3d685d2951610ddc47597"
  # pod 'Eureka', '~> 4.3.1'
  pod 'EurekaFormBuilder'
  pod 'KeychainAccess', '~> 3.2.0'
  pod 'SVProgressHUD'
  pod 'Notifwift', '~> 1.1.1'
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

  target 'iMastShare' do
    inherit! :search_paths
    based_pods
  end

  target 'iMastTodayWidget' do
    inherit! :search_paths
    based_pods
  end

  target 'iMastNotifyService' do
    inherit! :search_paths
    based_pods
  end

  target 'iMastIntents' do
    inherit! :search_paths
    based_pods
  end

end