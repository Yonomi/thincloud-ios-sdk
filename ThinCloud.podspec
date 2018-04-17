# `pod lib lint ThinCloud.podspec'

Pod::Spec.new do |s|
  s.name             = 'ThinCloud'
  s.version          = '0.1.0'
  s.summary          = 'The Yonomi ThinCloud SDK for iOS.'
  s.homepage         = 'https://github.com/Yonomi/thincloud-sdk-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { 'Yonomi' => 'developer@yonomi.co' }
  s.source           = { :git => 'https://github.com/Yonomi/thincloud-sdk-ios.git', :tag => s.version.to_s }

  s.swift_version = '4.1'
  s.ios.deployment_target = '11.0'

  s.source_files = 'ThinCloud/Classes/**/*'

  s.frameworks = 'UIKit'
  
  s.dependency 'Alamofire', '~> 4.7.2'
end
