Pod::Spec.new do |spec|

  spec.name         = "SundayListKit"
  spec.summary      = "A diffable list adapter"
  spec.version      = "0.0.1"
  spec.homepage     = "https://github.com/sundayfun/SundayListKit"
  spec.license      = "MIT"

  spec.ios.deployment_target = '9.0'
  spec.author = { "Frain" => "frainl@outlook.com" }
  spec.source = { :git => "" }
  spec.source_files  = "SundayListKit/**/*.{h,m,swift}"
  spec.exclude_files = 'SundayListKit/Sources/SourceBuilder'

end
