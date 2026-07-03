#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'tv_textfield'
  s.version          = '0.1.0'
  s.summary          = 'TV-friendly TextField for Flutter.'
  s.description      = <<-DESC
A TV-friendly TextField that fixes D-pad focus issues on Android TV and Apple TV.
                       DESC
  s.homepage         = 'https://github.com/example/tv_textfield'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'tv_textfield' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.tvos.deployment_target = '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
