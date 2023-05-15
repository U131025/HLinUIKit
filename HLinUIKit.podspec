#
# Be sure to run `pod lib lint HLUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HLinUIKit'
  s.version          = '1.0.8'
  s.summary          = '基于RxSwift的界面库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
基于RxSwift的界面库1.0.1版本
                       DESC

  s.homepage         = 'https://github.com/U131025/HLinUIKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mojy' => 'mojingyufly@163.com' }
  s.source           = { :git => 'https://github.com/U131025/HLinUIKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'HLinUIKit/Classes/**/*'
  s.framework    = "UIKit"
  s.requires_arc = true
  s.swift_version = '5.0'

  s.dependency 'SnapKit'
  s.dependency 'MYTableViewIndex'
  s.dependency 'Then'
  s.dependency 'MJRefresh'
  s.dependency 'JGProgressHUD'

  s.dependency 'RxDataSources'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'RxGesture'
  s.dependency 'SDCycleScrollView'
end
