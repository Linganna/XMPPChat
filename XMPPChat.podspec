#
#  Be sure to run `pod spec lint XMPPChat.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|



s.name         = "XMPPChat"
s.version      = "0.0.1"
s.summary      = "A short description of XMPPChat"
s.description  = "A short description of XMPPCha"
s.homepage     = "https://google.com/"
s.license      = "MIT"
s.author             = { "Linganna" => "linganna.allula@gmail.com" }
s.platform     = :ios, "10.0"
s.source       = { :git => 'https://github.com/Linganna/XMPPChat.git', :tag => 'v0.0.1' }
s.source_files  = "XMPPChat", "XMPPChat/**/*.{h,m,swift}"
s.dependency "XMPPFramework", "~> 3.7.0"


end
