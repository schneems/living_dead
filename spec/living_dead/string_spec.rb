require 'spec_helper'

describe LivingDead do
  context "tracing strings" do
    it "determines objects are NOT retained" do
      out = run("env ruby #{ fixtures('string/not_retained.rb') }")
      expect(out).to match("PASS")

      out = run("env ruby #{ fixtures('string/string_in_class.rb') }")
      expect(out).to match("PASS")

      out = run("env ruby #{ fixtures('string/string_in_proc.rb') }")
      expect(out).to match("PASS")

      out = run("env ruby #{ fixtures('string/string_method_in_proc.rb') }")
      expect(out).to match("PASS")
    end

    it "determines objects ARE retained" do
      out = run("env ruby #{ fixtures('string/retained.rb') }")
      expect(out).to match("PASS")
    end
  end
end
