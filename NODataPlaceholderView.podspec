#
#  Be sure to run `pod spec lint NODataPlaceholderView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "NODataPlaceholderView"
  s.version      = "1.0.5"
  s.summary      = "A UITableView and UICollectionView are used to display categories when there is no data."
  s.homepage     = "https://github.com/alpface/NODataPlaceholderView"
  # s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Ossey" => "xiaoyuan1314@me.com" }
  # Or just: s.author    = "alpface"
  # s.authors            = { "alpface" => "xiaoyuan1314@me.com" }
  # s.social_media_url   = "https://github.com/alpface"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/alpface/NODataPlaceholderView.git", :tag => "#{s.version}" }
  s.source_files = 'UIScrollView+NoDataExtend.{h,m}'
  s.requires_arc = true

end
