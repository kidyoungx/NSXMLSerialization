Pod::Spec.new do |s|
  s.name         = "NSXMLSerialization"
  s.version      = "1.0.1"
  s.summary      = "An object that converts between XML and the equivalent Foundation objects. Like NSJSONSerialization."

  s.description  = <<-DESC
                    You use the NSJSONSerialization class to convert JSON to Foundation objects and convert Foundation objects to JSON.
                   DESC

  s.homepage     = "https://github.com/kidyoungx/NSXMLSerialization"

  s.license      = "MPL-2.0"

  s.author             = { "Kid Young" => "kidyoungx@gmail.com" }

  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = "10.9"

  s.source       = { :git => "https://github.com/kidyoungx/NSXMLSerialization.git", :tag => "#{s.version}" }

  s.source_files  = "NSXMLSerialization", "NSXMLSerialization/**/*.{h,m}"
  s.exclude_files = "SampleNSXMLSerialization"

  s.public_header_files = "NSXMLSerialization/**/*.h"

  s.requires_arc = true

end
