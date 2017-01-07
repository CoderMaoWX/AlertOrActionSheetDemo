Pod::Spec.new do |s|
s.name         = "OKAlertContrActionSheet"
s.version      = "0.0.1"
s.ios.deployment_target = '6.0'
s.osx.deployment_target = '10.8'
s.summary      = "A fast use system UIAlertView/UIAlertController or UIActionSheet Library"
s.homepage     = "https://github.com/luocheng2013/AlertOrActionSheetDemo"
s.license      = "MIT"
s.author             = { "luocheng" => "maowangxin_2013@163.com" }
s.social_media_url   = "http://www.jianshu.com/u/c4ac9f9adf58"
s.source       = { :git => "https://github.com/luocheng2013/AlertOrActionSheetDemo.git", :tag => s.version }
s.source_files  = "AlertOrActionSheetClass"
s.requires_arc = true
end
