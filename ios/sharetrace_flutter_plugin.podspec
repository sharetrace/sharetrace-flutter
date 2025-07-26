#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sharetrace_flutter_plugin.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sharetrace_flutter_plugin'
  s.version          = '1.0.7'
  s.summary          = 'Sharetrace flutter plugin.'
  s.description      = <<-DESC
Sharetrace flutter plugin.
                       DESC
  s.homepage         = 'https://www.sharetrace.com/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { "ShareTrace" => "sharetrace@shoot.net.cn" }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  s.dependency 'SharetraceSDK', "~> 2.4.2"

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
