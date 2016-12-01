require 'spec_helper'

describe LivingDead do
  context "calling `singleton_class.instance_eval` " do
    it "does not retain in the simple case" do
      out = run("env ruby #{ fixtures('singleton_class_instance_eval/simple.rb') }")
      expect(out).to match("PASS")
    end

    it "does retain objects when used with a instance variable" do
      out = run("env ruby #{ fixtures('singleton_class_instance_eval/retained.rb') }")
      expect(out).to match("PASS")
    end

    it "does not retain in a class" do
      out = run("env ruby #{ fixtures('singleton_class_instance_eval/in_class.rb') }")
      expect(out).to match("PASS")
    end

    it "does not retain in a proc" do
      out = run("env ruby #{ fixtures('singleton_class_instance_eval/in_proc.rb') }")
      expect(out).to match("PASS")
    end

    it "does not retain in method in proc" do
      out = run("env ruby #{ fixtures('singleton_class_instance_eval/method_in_proc.rb') }")
      expect(out).to match("PASS")
    end
  end
end
