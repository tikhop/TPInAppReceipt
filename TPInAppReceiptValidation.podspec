Pod::Spec.new do |s|

s.name         = "TPInAppReceiptValidation"
s.version      = "1.2.3"
s.summary      = "Decode Apple Store Receipt and make it easy to read it and validate using OpenSSL"

s.description  = "The library provides transparent way to decode and validate Apple Store Receipt. Pure swift, OpenSSL!"

s.homepage     = "http://tikhop.com"

s.license      = "MIT"
# s.license    = { :type => "MIT", :file => "FILE_LICENSE" }

s.author       = { "Pavel Tikhonenko" => "hi@tikhop.com" }

# ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  If this Pod runs only on iOS or OS X, then specify the platform and
#  the deployment target. You can optionally include the target after the platform.
#

s.ios.deployment_target = '9.0'
s.osx.deployment_target = '10.11'

# ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  Specify the location from where the source should be retrieved.
#  Supports git, hg, bzr, svn and HTTP.
#

s.source       = { :git => "https://github.com/tikhop/TPInAppReceipt.git",
                   :tag => "'Validation-' + s.version.to_s" }

# ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  CocoaPods is smart about how it includes source code. For source files
#  giving a folder will include any swift, h, m, mm, c & cpp files.
#  For header files it will include any header in the folder.
#  Not including the public_header_files will make all headers public.
#

# s.source_files  = "TPInAppReceipt/Source/*.{swift}", "Vendor/CryptoSwift/*.{swift}", "TPInAppReceipt/OpenSSL/*.{swift}"
s.ios.source_files  = "TPInAppReceipt/Source/*.{swift}", "Vendor/CryptoSwift/*.{swift}", "TPInAppReceipt/OpenSSL/ios/*.{h}"
s.osx.source_files  = "TPInAppReceipt/Source/*.{swift}", "Vendor/CryptoSwift/*.{swift}", "TPInAppReceipt/OpenSSL/macos/*.{h}"
# ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

s.swift_version = '5.0'

s.ios.deployment_target = '9.0'
s.osx.deployment_target = '10.10'

s.resources  = "TPInAppReceipt/AppleIncRootCertificate.cer"

# ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

s.static_framework = true

# s.dependency 'TPInAppReceipt', '~> 2.0.0'
# s.dependency 'OpenSSL-Universal/Framework'
# s.pod_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }

# s.ios.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/Vendor/OpenSSL/include', 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/Vendor/OpenSSL', 'LIBRARY_SEARCH_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/Vendor/OpenSSL/iOS' }

s.ios.vendored_frameworks = "TPInAppReceipt/OpenSSL/ios/OpenSSL.framework"
s.ios.xcconfig = {
'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
'GCC_C_LANGUAGE_STANDARD' => 'gnu11'
}

s.osx.vendored_frameworks = "TPInAppReceipt/OpenSSL/macos/OpenSSL.framework"
s.osx.xcconfig = {
'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
'GCC_C_LANGUAGE_STANDARD' => 'gnu11'
}

s.preserve_paths = 'TPInAppReceipt/OpenSSL/*'

s.ios.exclude_files = 'TPInAppReceipt/OpenSSL/macos/**'
s.osx.exclude_files = 'TPInAppReceipt/OpenSSL/ios/**'

# ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  If your library depends on compiler flags you can set them in the xcconfig hash
#  where they will only apply to your library. If you depend on other Podspecs
#  you can include multiple dependencies to ensure it works.

# s.requires_arc = true

end
