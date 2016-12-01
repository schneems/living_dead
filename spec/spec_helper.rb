require 'pathname'
require "open3"
require 'tempfile'
require 'tmpdir'
require 'fileutils'

require 'rubygems'
require 'bundler/setup'
require 'living_dead'

RSpec.configure do |config|
  config.mock_framework = :rspec
end


def fixtures(name)
  Pathname.new(File.expand_path("../fixtures", __FILE__)).join(name)
end

def run(cmd)
  out = ""
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    err = stderr.read
    raise err unless err.empty?
    out = stdout.read
  end
  out
end
