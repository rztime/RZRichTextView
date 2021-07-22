#
# Be sure to run `pod lib lint RZRichTextView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RZRichTextView'
  s.version          = '0.5.0'
  s.summary          = 'iOS 原生UITextView 富文本编辑器'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  对原生UITextView支持富文本编辑
                       DESC

  s.homepage         = 'https://github.com/rztime/RZRichTextView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rztime' => 'rztime@vip.qq.com' }
  s.source           = { :git => 'https://github.com/rztime/RZRichTextView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'RZRichTextView/Classes/**/*'
  
   s.resource_bundles = {
     'RZRichTextView' => ['RZRichTextView/Assets/*']
   }
   s.prefix_header_contents = <<-EOS
 #import <UIKit/UIKit.h>
 #import <Foundation/Foundation.h>
    EOS
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency 'RZColorful'
  s.dependency 'Masonry'
  s.dependency 'TZImagePickerController'
end
