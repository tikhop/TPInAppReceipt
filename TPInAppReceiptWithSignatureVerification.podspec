Pod::Spec.new do |s|

s.name         = "TPInAppReceiptWithSignatureVerification"
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

# s.source_files  = "TPInAppReceipt/Source/*.{swift}", "Vendor/CryptoSwift/*.{swift}", 
s.ios.source_files  = "TPInAppReceipt/Source/*.{swift}", "Vendor/CryptoSwift/*.{swift}", "TPInAppReceipt/OpenSSL/*.{swift}" #, "TPInAppReceipt/OpenSSL/osx/include/**/*.{h}"
s.osx.source_files  = "TPInAppReceipt/Source/*.{swift}", "Vendor/CryptoSwift/*.{swift}", "TPInAppReceipt/OpenSSL/*.{swift}" #, "TPInAppReceipt/OpenSSL/macos/include/**/*.{h}"
s.requires_arc = ["TPInAppReceipt/Source/*.{swift}", "Vendor/CryptoSwift/*.{swift}", "TPInAppReceipt/OpenSSL/*.{swift}"]
# ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

s.swift_version = '5.0'

s.ios.deployment_target = '9.0'
s.osx.deployment_target = '10.10'

s.resources  = "TPInAppReceipt/AppleIncRootCertificate.cer"

# ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

s.static_framework = true

# s.dependency 'TPInAppReceipt', '~> 2.0.0'
s.dependency 'OpenSSL-Universal'

# s.ios.preserve_paths = 'TPInAppReceipt/OpenSSL/ios/include/', '/TPInAppReceipt/OpenSSL/ios/module.modulemap'
# s.osx.preserve_paths = 'TPInAppReceipt/OpenSSL/macos/include/', '/TPInAppReceipt/OpenSSL/macos/module.modulemap'

# s.ios.vendored_library = "TPInAppReceipt/OpenSSL/macos/lib/libcrypto.a", "TPInAppReceipt/OpenSSL/ios/lib/libssl.a"
# #s.ios.vendored_frameworks = "TPInAppReceipt/OpenSSL/ios/OpenSSL.framework"
# s.ios.public_header_files = 'TPInAppReceipt/OpenSSL/ios/include/**/*.h'

s.ios.pod_target_xcconfig = {
'HEADER_SEARCH_PATHS' => 'TPInAppReceipt/OpenSSL/ios/include/openssl/**/*.h',
'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
'GCC_C_LANGUAGE_STANDARD' => 'gnu11'
}

# s.osx.vendored_library = "TPInAppReceipt/OpenSSL/macos/lib/libcrypto.a", "TPInAppReceipt/OpenSSL/macos/lib/libssl.a"
#s.osx.vendored_frameworks = "TPInAppReceipt/OpenSSL/macos/OpenSSL.framework"
# s.osx.public_header_files = 'TPInAppReceipt/OpenSSL/macos/include/**/*.h'

s.osx.pod_target_xcconfig = {
'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/OpenSSL/macos/include/openssl',
'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
'GCC_C_LANGUAGE_STANDARD' => 'gnu11'
}

# s.ios.module_map = '/TPInAppReceipt/OpenSSL/ios/module.modulemap'
# s.osx.module_map = '/TPInAppReceipt/OpenSSL/macos/module.modulemap'

# s.ios.exclude_files = 'TPInAppReceipt/OpenSSL/macos/**'
# s.osx.exclude_files = 'TPInAppReceipt/OpenSSL/ios/**'

# ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  If your library depends on compiler flags you can set them in the xcconfig hash
#  where they will only apply to your library. If you depend on other Podspecs
#  you can include multiple dependencies to ensure it works.



end
