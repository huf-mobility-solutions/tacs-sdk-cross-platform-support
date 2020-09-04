#
# Be sure to run `pod lib lint TACS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TACS'
  s.version          = '1.6.1'
  s.summary          = 'TACS Framework'
  s.description      = "Framework for TACS (Telematics and Vehicle access controler suite)"

  s.homepage         = 'https://github.com/hufsm/mobile-ios-tacs'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Huf Secure Mobile GmbH' => 'info@hufsecuremobile.com' }
  s.source           = { :git => 'https://github.com/hufsm/mobile-ios-tacs.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3'
  s.source_files = 'TACS/Classes/**/*'
  
  s.dependency 'SecureAccessBLE'
  s.swift_version = '5.2'
end
