# Uncomment the next line to define a global platform for your project
source 'https://cdn.cocoapods.org/'
platform :ios, '10.0'

def based_pods
  pod 'SwiftLint', '~> 0.30.1'
  pod 'Alamofire', '~> 4.8.1'
  pod 'GRDB.swift', '~> 3.7.0'
  pod 'SwiftyJSON', '~> 4.2.0'
  pod 'HydraAsync'
  pod 'XCGLogger', '~> 7.0.0'
  pod 'SDWebImage', '~> 4.4.5'
  pod 'SDWebImage/WebP', '~> 4.4.5'
  pod 'Fuzi', '~> 3.0.0'
  pod 'SnapKit'
  pod '※ikemen'
  pod 'R.swift', '~> 5.0.3'
  pod 'Mew', :git => 'https://github.com/rinsuki/Mew.git', :branch => "fix/podspec"
end

target 'iMast' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iMast

  based_pods
  pod 'Crossroad'
  pod 'Starscream', '~> 3.0.6'
  pod 'ReachabilitySwift', '~> 4.3.0'
  pod 'Eureka', '~> 4.3.1'
  pod 'ActionClosurable', :git => "https://github.com/rinsuki/ActionClosurable.git", :branch => "fix/swift4.2"
  pod 'KeychainAccess', '~> 3.1.2'
  pod 'SVProgressHUD'
  pod 'Notifwift'
  pod '1PasswordExtension', '~> 1.8.5'
  pod 'LicensePlist', '~> 2.1.0'

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

post_install do | installer |
  # R.swift in Swift 4.2 workaround
  # 5.0が出るまで我慢
  installer.pods_project.targets.each do | target |
    if [].include? target.name
      target.build_configurations.each do | config |
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
    if ["GRDB.swift"].include? target.name
      target.build_configurations.each do | config |
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
