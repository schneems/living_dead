require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe LivingDead do
  describe 'trace' do
    it 'should be callable' do
      obj = Object.new
      LivingDead.trace(obj)
    end
  end
end
