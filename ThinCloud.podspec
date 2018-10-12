# `pod lib lint ThinCloud.podspec'

Pod::Spec.new do |s|
  s.name             = 'ThinCloud'
  s.version          = '0.3.1'
  s.summary          = 'The Yonomi ThinCloud SDK for iOS.'
  s.homepage         = 'https://github.com/Yonomi/thincloud-ios-sdk'
  s.license          = { :type => 'Copyright', :file => 'LICENSE' }
  s.authors          = { 'Yonomi' => 'developer@yonomi.co' }
  s.source           = { :git => 'https://github.com/Yonomi/thincloud-ios-sdk.git', :tag => s.version.to_s }

  s.swift_version = '4.2'
  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'

  s.source_files = 'Source/ThinCloud/**/*.swift'

  s.frameworks = 'UIKit'
  
  s.dependency 'Alamofire', '~> 4.7.3'
end
