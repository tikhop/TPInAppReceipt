Pod::Spec.new do |s|

s.name         = "TPInAppReceipt"
s.version      = "2.2"
s.summary      = "Decode Apple Store Receipt and make it easy to read and validate it"
s.description  = "The library provides transparent way to decode and validate Apple Store Receipt. Pure swift, No OpenSSL!"

s.homepage     = "https://github.com/tikhop/TPInAppReceipt"
s.license      = "MIT"
s.source       = { :git => "https://github.com/tikhop/TPInAppReceipt.git", :tag => "#{s.version}" }

s.author       = { "Pavel Tikhonenko" => "hi@tikhop.com" }

s.swift_version = '5.0'
s.ios.deployment_target = '9.0'
s.osx.deployment_target = '10.10'
s.tvos.deployment_target = '9.0'
s.watchos.deployment_target = '2.0'
s.requires_arc = true

s.source_files  = "TPInAppReceipt/Source/*.{swift}", "TPInAppReceipt/Source/Vendor/CryptoSwift/*.{swift}"

s.resources  = "TPInAppReceipt/AppleIncRootCertificate.cer"



end
