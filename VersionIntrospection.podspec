Pod::Spec.new do |s|
  s.name             = "VersionIntrospection"
  s.version          = "0.2.0-Dev"
  s.summary          = "Simple tool to expose versions of dependencies by parsing Podfile.lock"
  s.homepage         = "https://github.com/clausweymann/VersionIntrospection"
  s.license          = 'MIT'
  s.author           = { "Claus Weymann" => "claus.weymann@sprylab.com" }
  s.source           = { :git => "https://github.com/clausweymann/VersionIntrospection.git", :tag => s.version.to_s }
  
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.7'
  
  s.requires_arc = true

s.source_files = 'Pod/Classes/**/*.{h,m}'
s.resources = 'Pod/Classes/**/*.{xib}'
end
