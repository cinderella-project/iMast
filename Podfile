# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'iMast' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iMast

  pod 'Alamofire', '~> 4.4'
  pod 'GRDB.swift'
  pod 'SwiftyJSON'
  pod 'Compass'
  pod 'HydraAsync'
  pod 'Starscream'
  pod 'ReachabilitySwift', '~> 3'
  pod 'Eureka', git: 'https://github.com/xmartlabs/Eureka', branch: 'feature/Xcode9-Swift3_2'
  pod 'XCGLogger', '~> 5.0.1'

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
    pod 'Alamofire', '~> 4.4'
    pod 'SwiftyJSON'
    pod 'HydraAsync'
    pod 'GRDB.swift'
    pod 'XCGLogger', '~> 5.0.1'
    pod 'Starscream'
  end
  target 'iMastTodayWidget' do
    inherit! :search_paths
    pod 'Alamofire', '~> 4.4'
    pod 'SwiftyJSON'
    pod 'HydraAsync'
    pod 'GRDB.swift'
    pod 'Eureka', git: 'https://github.com/xmartlabs/Eureka', branch: 'feature/Xcode9-Swift3_2'
  end

end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-iMast/Pods-iMast-acknowledgements.plist', 'iMast/Settings.bundle/Acknowledgements.plist')
end
