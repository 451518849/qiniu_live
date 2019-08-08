#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'qiniu_live'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin for qiniu live.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/451518849/qiniu_live'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'xiaofwang' => '451518849@qq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'QNRTCKit','2.3.0'
  s.dependency 'JGProgressHUD','2.0.3'

  s.ios.deployment_target = '8.0'
end

