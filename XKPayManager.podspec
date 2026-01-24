#
# Be sure to run `pod lib lint XKPayManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XKPayManager'
  s.version          = '0.0.1'
  s.summary          = 'A short description of XKPayManager.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/kunhum/XKPayManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kunhum' => 'kunhum@163.com' }
  s.source           = { :git => 'https://github.com/kunhum/XKPayManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

#  s.source_files = 'XKPayManager/Classes/**/*'
  
  s.static_framework = true
  
#  s.source_files = 'XKPayManager/**/*.{h,swift}'
  # s.resource_bundles = {
  #   'XKPayManager' => ['XKPayManager/Assets/*.png']
  # }

#  s.public_header_files = 'XKPayManager/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.subspec 'Common' do |ss|
    ss.source_files = "XKPayManager/Classes/Common/**/*"
    ss.dependency 'WechatOpenSDK'
  end
  
  s.subspec 'Pay' do |ss|
    ss.source_files = "XKPayManager/Classes/Pay/**/*"
    ss.dependency 'XKPayManager/Common'
    ss.dependency 'WechatOpenSDK'
    ss.dependency 'AlipaySDK-iOS'
  end
  
  s.subspec 'Share' do |ss|
    ss.source_files = "XKPayManager/Classes/Share/**/*"
    ss.dependency 'WechatOpenSDK'
    ss.dependency 'XKPayManager/Common'
  end
  
end
