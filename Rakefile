require 'rubygems'
require 'rake/gempackagetask'

PLUGIN   = "mex"
NAME     = "mex"
VERSION  = "0.2.0"
AUTHOR   = "Aaron Wheeler"
EMAIL    = "aaron@fightinjoe.com"
HOMEPAGE = "http://merb-plugins.rubyforge.org/mex/"
SUMMARY  = "Merb plugin that provides both integrated and stand-alone exception logging."

spec = Gem::Specification.new do |s|
  s.name             = NAME
  s.version          = VERSION
  s.platform         = Gem::Platform::RUBY

  s.author           = AUTHOR
  s.email            = EMAIL
  s.homepage         = HOMEPAGE
  s.summary          = SUMMARY
  s.description      = s.summary

#  s.has_rdoc         = true
#  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.require_path     = 'lib'
  s.autorequire      = PLUGIN
  s.files            = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs}/**/*")
  s.bindir           = "bin"
  s.executables      = %w( mex )
  s.add_dependency('merb', '>= 0.9.2')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task :install => [:package] do
  sh %{sudo gem install pkg/#{NAME}-#{VERSION}}
end

namespace :jruby do

  desc "Run :package and install the resulting .gem with jruby"
  task :install => :package do
    sh %{#{SUDO} jruby -S gem install pkg/#{NAME}-#{Merb::VERSION}.gem --no-rdoc --no-ri}
  end
  
end