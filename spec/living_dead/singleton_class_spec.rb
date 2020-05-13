require 'spec_helper'

describe LivingDead do
  context "calling `singleton_class` " do
    it "does not retain in the simple case" do
      file = fixtures('singleton_class/simple.rb')
      out = run("env ruby #{file}")
      expect(out).to match("PASS")
    end

    it "does retain objects when used with a instance variable" do
      file = fixtures('singleton_class/retained.rb')
      out = run("env ruby #{file}")
      expect(out).to match("PASS")
    end

    it "does not retain in a class" do
      file = fixtures('singleton_class/in_class.rb')
      out = run("env ruby #{file}")
      expect(out).to match("PASS")
    end

    it "does not retain in a proc" do
      file = fixtures('singleton_class/in_proc.rb')
      out = run("env ruby #{file}")
      expect(out).to match("PASS")
    end

    it "does not retain in method in proc" do
      file = fixtures('singleton_class/method_in_proc.rb')
      out = run("env ruby #{file}")
      expect(out).to match("PASS")
    end
  end
end
