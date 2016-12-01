require 'spec_helper'

describe LivingDead do
  context "calling `times.map` " do
    it "does not retain in the simple case" do
      out = run("env ruby #{ fixtures('times_map/simple.rb') }")
      expect(out).to match("PASS")
    end

    it "does retain objects when used with a instance variable" do
      out = run("env ruby #{ fixtures('times_map/retained.rb') }")
      expect(out).to match("PASS")
    end

    it "does not retain in a class" do
      out = run("env ruby #{ fixtures('times_map/in_class.rb') }")
      expect(out).to match("PASS")
    end

    it "does not retain in a proc" do
      out = run("env ruby #{ fixtures('times_map/in_proc.rb') }")
      expect(out).to match("PASS")
    end

    it "does not retain in method in proc" do
      out = run("env ruby #{ fixtures('times_map/method_in_proc.rb') }")
      expect(out).to match("PASS")
    end
  end
end
