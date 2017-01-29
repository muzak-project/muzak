require_relative "lib/muzak"

Gem::Specification.new do |s|
  s.name = "muzak"
  s.version = Muzak::VERSION
  s.summary = "muzak - A metamusic player."
  s.description = "A library for controlling playlists and media players."
  s.authors = ["William Woodruff"]
  s.email = "william@tuffbizz.com"
  s.files = Dir["LICENSE", "*.md", ".yardopts", "lib/**/*"]
  s.executables = [
                    "muzakd",
                    "muzak-cmd",
                    "muzak-dmenu",
                    "muzak-index",
                    "muzak-setup",
                  ]
  s.required_ruby_version = ">= 2.3.0"
  s.homepage = "https://github.com/muzak-project/muzak"
  s.license = "MIT"
  s.add_runtime_dependency "taglib-ruby", "~> 0.7"
  s.add_runtime_dependency "mpv", "~> 1.2", ">= 1.2.0"
  s.add_runtime_dependency "vlc-client", "~> 0.0.7"
  s.add_runtime_dependency "tty-prompt", "~> 0.10.0"
end
