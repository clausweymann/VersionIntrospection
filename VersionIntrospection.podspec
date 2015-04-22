Pod::Spec.new do |s|
  s.name             = "VersionIntrospection"
  s.version          = "0.1.2"
  s.summary          = "Simple tool to expose versions of dependencies by parsing Podfile.lock"
  s.homepage         = "https://github.com/clausweymann/VersionIntrospection"
  s.license          = 'MIT'
  s.author           = { "Claus Weymann" => "claus.weymann@sprylab.com" }
  s.source           = { :git => "https://github.com/clausweymann/VersionIntrospection.git", :tag => s.version.to_s }
  
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'VersionIntrospection' => ['Pod/Assets/*.png']
  }
end
