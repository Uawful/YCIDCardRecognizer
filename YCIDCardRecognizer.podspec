#
#  Be sure to run `pod spec lint YCIDCardRecognizer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "YCIDCardRecognizer"
  spec.version      = "0.0.8"
  spec.summary      = "身份证号码识别"

  spec.description  = <<-DESC
基于opencv以及TesseractOCRiOS的身份证号码识别工具 身份证号码识别工具
                   DESC

  spec.homepage     = "https://github.com/Uawful/YCIDCardRecognizer"
  spec.license      = "MIT"
  spec.author             = { "jeremy" => "441406859@qq.com" }
  spec.platform      = :ios, "9.0"

  spec.source       = { :git => "https://github.com/Uawful/YCIDCardRecognizer.git", :tag => "#{spec.version}" }
  spec.source_files = 'YCIDCardRecognizer/**/*'
  spec.resources     = "YCIDCardRecognizer/tessdata"
  spec.public_header_files = 'YCIDCardRecognizer/public'
  spec.frameworks = "Foundation","UIKit"
  spec.dependency "OpenCV", "~> 3.0.0"
  spec.dependency "TesseractOCRiOS", "~> 4.0.0"

end
