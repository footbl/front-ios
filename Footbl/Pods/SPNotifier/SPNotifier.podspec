Pod::Spec.new do |spec|
  spec.name = 'SPNotifier'
  spec.version = '0.2.2'
  spec.platform = :ios, '7.0'
  spec.requires_arc = true
  spec.source_files = 'Source/**/*.{h,m}'

  spec.authors = { 'Fernando Saragoça' => 'fsaragoca@me.com' }
  spec.license = 'MIT'
  spec.summary = 'A not so short summary for SPHipster'
  spec.homepage = 'https://madeatsampa.com'
  spec.source = { :path => '.'}
end
