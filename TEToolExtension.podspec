Pod::Spec.new do |s|

s.name = 'TEToolExtension'
s.version = '1.0.0'
s.license = 'MIT'
s.summary = 'TEToolExtension.'

s.homepage = 'https://github.com/jojojoe/TEToolExtension'
s.authors = { "Joe" => "zx804463232@gmail.com" }

s.swift_version = '5.0'
s.requires_arc = true
s.ios.deployment_target = '13.0'
    
s.source = {
    :git => 'https://github.com/jojojoe/TEToolExtension.git',
    :tag => s.version
}

s.source_files = 'TEToolExtensionResource/*.swift'
s.resource  = "TEToolExtensionResource/*.{lproj,xcassets,storyBoard}"
s.deprecated = true

s.dependency 'SnapKit'
s.dependency 'SwifterSwift'
s.dependency 'DeviceKit'

end
