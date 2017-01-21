Pod::Spec.new do |s|

  s.name         = "TPInAppReceipt"
  s.version      = "1.0"
  s.summary      = "Validates and parses Apple Store Receipt."

  s.description  = "This helper validates and parses the payload and the PKCS7 container itself. Pure swift, openssl+bitcode" 

  s.homepage     = "http://tikhop.com"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "Pavel Tikhonenko" => "hi@tikhop.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  s.platform     = :ios, "8.2"
    # s.osx.deployment_target = "10.7"
    # s.tvos.deployment_target = "9.0"
  
  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "https://github.com/tikhop/TPInAppReceipt.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "TPInAppReceipt/**/*.{h,m}", "TPInAppReceipt/**/*.{swift}", "Vendor/OpenSSL/include/**/*.h"
  
  s.public_header_files = "TPInAppReceipt/**/*.h"
  s.vendored_libraries = "Vendor/OpenSSL/lib/libssl.a", "Vendor/OpenSSL/lib/libcrypto.a"
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/Vendor/OpenSSL/include', 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/Vendor/OpenSSL', 'LIBRARY_SEARCH_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/Vendor/OpenSSL/lib' }
  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/Vendor/OpenSSL/include', 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/Vendor/OpenSSL', 'LIBRARY_SEARCH_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/Vendor/OpenSSL/lib' }
  s.preserve_paths = 'TPInAppReceipt/*', 'Vendor/OpenSSL/module.modulemap', 'TPInAppReceipt/**/*'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.resources  = "TPInAppReceipt/AppleIncRootCertificate.cer"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.libraries = "ssl", "crypto"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true
  
end
