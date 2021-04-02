Pod::Spec.new do |s|

s.name         = "TPInAppReceipt"
s.version      = "3.1.0"
s.summary      = "Reading and Validating In App Purchase Receipt Locally"
s.description  = "A lightweight iOS/OSX library for reading and validating Apple In App Purchase Receipt locally. Pure swift, No OpenSSL!"

s.homepage     = "https://github.com/tikhop/TPInAppReceipt"
s.license      = "MIT"
s.source       = { :git => "https://github.com/tikhop/TPInAppReceipt.git", :tag => "#{s.version}" }

s.author       = { "Pavel Tikhonenko" => "hi@tikhop.com" }

s.swift_versions = ['5.3']
s.ios.deployment_target = '10.0'
s.osx.deployment_target = '10.12'
s.tvos.deployment_target = '10.0'
s.watchos.deployment_target = '6.2'
s.requires_arc = true

s.source_files  = "Sources/*.{swift}"

s.resources  = "Sources/AppleIncRootCertificate.cer", "Sources/StoreKitTestCertificate.cer"

s.dependency 'ASN1Swift', '~> 1.2.3'

end
