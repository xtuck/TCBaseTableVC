#
# Be sure to run `pod lib lint TCBaseTableVC.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TCBaseTableVC'
  s.version          = '0.1.1'
  s.summary          = 'TableView基类，列表使用更加方便，统一了数据请求和翻页逻辑'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/xtuck/TCBaseTableVC'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xtuck' => '104166631@qq.com' }
  s.source           = { :git => 'https://github.com/xtuck/TCBaseTableVC.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TCBaseTableVC/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TCBaseTableVC' => ['TCBaseTableVC/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency 'Masonry'
  s.dependency 'MJRefresh'
  s.dependency 'DZNEmptyDataSet'

end
