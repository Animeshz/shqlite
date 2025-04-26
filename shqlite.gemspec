Gem::Specification.new do |spec|
  spec.name          = "shqlite"
  spec.version       = "1.0.0"
  spec.summary       = "Use Google Sheets to edit Sqlite tables."
  spec.authors       = ["Animeshz"]
  spec.files         = Dir["lib/**/*.rb"] + ["bin/shqlite"]
  spec.executables   = ["shqlite"]
  spec.require_paths = ["lib"]
  spec.homepage      = "https://rubygems.org/gems/shqlite"
  spec.license       = "MIT"
end
