Pod::Spec.new do |s|

  s.name         = "TPInAppReceipt"
  s.version      = "0.0.1.2"
  s.summary      = "Apple in-app receipt helper."

  s.description  = "Apple in-app receipt helper. Readable receipt." 

  s.homepage     = "http://tikhop.com"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "Pavel Tikhonenko" => "hi@tikhop.com" }
  # Or just: s.author    = "Pavel Tikhonenko"
  # s.authors            = { "Pavel Tikhonenko" => "hi@tikhop.com" }
  # s.social_media_url   = "http://twitter.com/Pavel Tikhonenko"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  s.platform     = :ios, "9.0"

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

  s.source       = { :git => "https://github.com/tikhop/TPKit.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "TPReceiptValidator/**/*.{h,m}", "TPReceiptValidator/**/*.{swift}"
  
  s.public_header_files = "TPReceiptValidator/**/*.h", "TPReceiptValidator/openssl/include/*.h", "TPReceiptValidator/openssl/include/openssl/*.h"
  s.vendored_libraries = "TPReceiptValidator/openssl/lib/libssl.a", "TPReceiptValidator/openssl/lib/libcrypto.a"
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SRCROOT)/TPReceiptValidator/openssl/include', 'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/TPReceiptValidator/openssl' }
  s.preserve_paths = 'TPReceiptValidator/openssl/module.modulemap'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
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
  # s.libraries = "z", "sqlite3"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "AWSSNS", '~> 2.3.6'
  # s.dependency "JSONWebToken"
  # s.dependency "RMStore"
  # s.dependency "AFNetworking"
  
  #s.dependency "TPKit", git: 'https://github.com/tikhop/TPKit.git', branch: 'swift3' 
end
