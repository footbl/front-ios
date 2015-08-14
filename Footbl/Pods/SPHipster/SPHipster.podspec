Pod::Spec.new do |spec|
  spec.name = 'SPHipster'
  spec.version = '0.5.3'
  spec.platform = :ios, '7.0'
  spec.requires_arc = true
  spec.source_files = 'Source/**/*.{h,m}'
  spec.frameworks = 'UIKit'
end