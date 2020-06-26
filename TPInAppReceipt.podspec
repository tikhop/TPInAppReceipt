Pod::Spec.new do |s|

s.name         = "TPInAppReceipt"
s.version      = "2.7.0"
s.summary      = "Reading and Validating In App Purchase Receipt Locally"
s.description  = "A lightweight iOS/OSX library for reading and validating Apple In App Purchase Receipt locally. Pure swift, No OpenSSL!"

s.homepage     = "https://github.com/tikhop/TPInAppReceipt"
s.license      = "MIT"
s.source       = { :git => "https://github.com/tikhop/TPInAppReceipt.git", :tag => "#{s.version}" }

s.author       = { "Pavel Tikhonenko" => "hi@tikhop.com" }

s.swift_versions = ['5.2', '5.3']
s.ios.deployment_target = '9.0'
s.osx.deployment_target = '10.10'
s.tvos.deployment_target = '9.0'
s.watchos.deployment_target = '2.0'
s.requires_arc = true

s.source_files  = "TPInAppReceipt/Source/*.{swift}", "TPInAppReceipt/Source/Vendor/CryptoSwift/*.{swift}"

s.resources  = "TPInAppReceipt/Source/AppleIncRootCertificate.cer"

end
