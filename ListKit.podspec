Pod::Spec.new do |spec|
  spec.name = "ListKit"
  spec.version = "0.10.2"
  spec.summary = "A faster, swift-er data-driven UICollectionView/UITableView framework for building flexible lists."
  spec.homepage = "https://github.com/Alpensegler/ListKit"
  spec.license = "MIT"
  spec.ios.deployment_target = '11.0'
  spec.swift_versions = ['5.4']
  spec.author = { "Alpensegler" => "frainl@outlook.com" }
  spec.source = { :git => "https://github.com/Alpensegler/ListKit.git", :tag => "#{spec.version.to_s}" }
  spec.source_files = 'Sources/**/*.swift'
end