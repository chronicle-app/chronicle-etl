
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "chronicle/etl/version"

Gem::Specification.new do |spec|
  spec.name          = "chronicle-etl"
  spec.version       = Chronicle::ETL::VERSION
  spec.authors       = ["Andrew Louis"]
  spec.email         = ["andrew@hyfen.net"]

  spec.summary       = "ETL tool for personal data"
  spec.description   = "Chronicle-ETL allows you to extract personal data from a variety of services, transformer it, and load it."
  spec.homepage      = "https://github.com/chronicle-app"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/chronicle-app/chronicle-etl"
    spec.metadata["changelog_uri"] = "https://github.com/chronicle-app/chronicle-etl/releases"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.7"

  spec.add_dependency "activesupport", "~> 7.0"
  spec.add_dependency "chronic_duration", "~> 0.10.6"
  spec.add_dependency "colorize", "~> 0.8.1"
  spec.add_dependency "faraday"
  spec.add_dependency "gems", ">= 1"
  spec.add_dependency "launchy"
  spec.add_dependency "marcel", "~> 1.0.2"
  spec.add_dependency "mini_exiftool", "~> 2.10"
  spec.add_dependency "nokogiri", "~> 1.13"
  spec.add_dependency "omniauth", "~> 2"
  spec.add_dependency "sequel", "~> 5.35"
  spec.add_dependency "sinatra", "~> 2"
  spec.add_dependency "sqlite3", "~> 1.4"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "thor-hollaback", "~> 0.2"
  spec.add_dependency "tty-progressbar", "~> 0.17"
  spec.add_dependency "tty-prompt", "~> 0.23"
  spec.add_dependency "tty-spinner"
  spec.add_dependency "tty-markdown"
  spec.add_dependency "tty-table", "~> 0.11"
  spec.add_dependency "xdg", ">= 4.0"

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "fakefs", "~> 1.4"
  spec.add_development_dependency "guard-rspec", "~> 4.7.3"
  spec.add_development_dependency "pry-byebug", "~> 3.9"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 1.25.1"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "vcr", "~> 6.1"
  spec.add_development_dependency "webmock", "~> 3"
  spec.add_development_dependency "yard", "~> 0.9.7"
end
