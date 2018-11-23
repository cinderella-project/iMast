# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

def based_pods
  pod 'SwiftLint'
  pod 'Alamofire', '~> 4.5'
  pod 'GRDB.swift', '~> 3.5.0'
  pod 'SwiftyJSON'
  pod 'HydraAsync'
  pod 'XCGLogger', '~> 6.0.2'
  pod 'SDWebImage', '~> 4.0'
  pod 'Fuzi', '~> 2.1.0'
  pod 'SnapKit'
  pod '※ikemen'
end

target 'iMast' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iMast

  based_pods
  pod 'Compass'
  pod 'Starscream'
  pod 'ReachabilitySwift', '~> 3'
  pod 'Eureka', '~> 4.3.0'
  pod 'ActionClosurable', :git => "https://github.com/rinsuki/ActionClosurable.git", :branch => "fix/swift4.2"
  pod 'KeychainAccess'
  pod 'SVProgressHUD'
  pod 'Notifwift'
  pod 'Texture', :inhibit_warnings => true
  pod 'R.swift', '~> 4.0.0'
  pod '1PasswordExtension', '~> 1.8.5'

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

end

post_install do | installer |
  # Acknowledgements file auto generate
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-iMast/Pods-iMast-acknowledgements.plist', 'iMast/Settings.bundle/Acknowledgements.plist')

  # R.swift in Swift 4.2 workaround
  # 5.0が出るまで我慢
  installer.pods_project.targets.each do | target |
    if ["R.swift.Library"].include? target.name
      target.build_configurations.each do | config |
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end
end
