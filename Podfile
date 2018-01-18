# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

def based_pods
  pod 'Alamofire', '~> 4.5'
  pod 'GRDB.swift'
  pod 'SwiftyJSON'
  pod 'HydraAsync'
  pod 'XCGLogger', '~> 6.0.2'
end

target 'iMast' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iMast

  based_pods
  pod 'Compass'
  pod 'Starscream'
  pod 'ReachabilitySwift', '~> 3'
  pod 'Eureka'
  pod 'ActionClosurable'

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
  target 'iMastSiriExt' do
    inherit! :search_paths
    based_pods
  end
  target 'iMastSiriExtUI' do
    inherit! :search_paths
    based_pods
  end

end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-iMast/Pods-iMast-acknowledgements.plist', 'iMast/Settings.bundle/Acknowledgements.plist')
end
