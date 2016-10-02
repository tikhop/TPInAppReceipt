Pod::Spec.new do |s|

  s.name         = "TPInAppReceipt"
  s.version      = "0.0.7"
  s.summary      = "Validates and parses Apple Store Receipt."

  s.description  = "This helper validates and parses the payload and the PKCS7 container itself. Pure swift, openssl+bitcode" 

  s.homepage     = "http://tikhop.com"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "Pavel Tikhonenko" => "hi@tikhop.com" }
  # s.authors            = { "Pavel Tikhonenko" => "hi@tikhop.com" }
  

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  s.platform     = :ios, "8.3"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
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
  #s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/TPInAppReceipt/Vendor/OpenSSL' }
  s.preserve_paths = 'TPInAppReceipt/*', 'Vendor/OpenSSL/module.modulemap', 'TPInAppReceipt/**/*'
  #s.module_map = 'Vendor/OpenSSL/module.modulemap'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  s.resources  = "TPInAppReceipt/AppleIncRootCertificate.cer"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "StoreKit", "AdSupport"

  # s.library   = "iconv"
  s.libraries = "ssl", "crypto"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true
  
end
