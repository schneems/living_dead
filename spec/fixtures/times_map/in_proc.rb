$LOAD_PATH.unshift(File.expand_path(File.join(__FILE__, "../../../../lib")))

require 'living_dead'

def run
  -> {
    array = 1.times.map {
      obj = Object.new
      LivingDead.trace(obj)
      obj
    }
    array = nil
  }.call

  return nil
end

run

alive_count = LivingDead.traced_objects.select { |tracer| tracer.retained? }.length

expected = Integer(ENV["EXPECTED_OUT"] || 0)
actual = alive_count
result = expected == actual ? "PASS" : "FAIL"
puts "#{result}: expected: #{expected}, actual: #{actual}"
