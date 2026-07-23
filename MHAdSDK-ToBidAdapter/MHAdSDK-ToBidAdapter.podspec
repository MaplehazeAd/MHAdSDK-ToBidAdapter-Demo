Pod::Spec.new do |s|
  s.name         = 'MHAdSDK-ToBidAdapter'
  s.version      = '1.0.1'
  s.summary      = 'ToBid (WindMill) custom adapter for MHAdSDK.'
  s.description  = <<-DESC
    MHAdSDK-ToBidAdapter 是 MHAdSDK 的 ToBid 聚合平台自定义适配器，
    支持开屏（Splash）、信息流（Native）、激励视频（RewardedVideo）广告类型。
  DESC

  s.homepage     = 'https://github.com/MaplehazeAd/MHAdSDK-ToBidAdapter-Demo'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'MaplehazeAd' => 'rd@maplehaze.cn' }

  s.source       = { :git => 'https://github.com/MaplehazeAd/MHAdSDK-ToBidAdapter-Demo.git', :tag => s.version.to_s }

  s.platform     = :ios, '12.0'
  s.requires_arc = true
  s.static_framework = true

  s.source_files = 'MHAdSDK-ToBidAdapter/**/*.{h,m}'
  s.public_header_files = 'MHAdSDK-ToBidAdapter/**/*.h'

  s.dependency 'MHAdSDK', '~> 1.4.5'
  s.dependency 'ToBid-iOS'

  s.frameworks   = 'UIKit', 'Foundation'
end
