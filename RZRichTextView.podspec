#
# Be sure to run `pod lib lint RZRichTextView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RZRichTextView'
  s.version          = '2.0.0'
  s.summary          = 'RZRichTextView. 原生UITextView，支持富文本输入（图片，视频，列表序号，文本颜色大小各种样式等等）'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/rztime/RZRichTextView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rztime' => 'rztime@vip.qq.com' }
  s.source           = { :git => 'https://github.com/rztime/RZRichTextView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'RZRichTextView/Classes/**/*'
  
  s.swift_version = ["4.2", "5.0"]
  s.dependency 'SnapKit'
  s.dependency 'QuicklySwift'
  s.dependency 'RZColorfulSwift'
  s.dependency 'Kingfisher'
  # s.resource_bundles = {
  #   'RZRichTextView' => ['RZRichTextView/Assets/*.png']
  # }
  s.resource_bundles = {
    'RZRichTextView' => ['RZRichTextView/Assets/*']
  }
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
