require "bundler/gem_tasks"
require "rake/extensiontask"
require 'rspec/core/rake_task'

spec = Gem::Specification.load('living_dead.gemspec')

Rake::ExtensionTask.new("living_dead", spec){|ext|
  ext.lib_dir = "lib/living_dead"
}

RSpec::Core::RakeTask.new('spec' => 'compile')

task default: :spec

task :run => 'compile' do
  ruby %q{-I ./lib test.rb}
end
