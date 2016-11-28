$LOAD_PATH.unshift(File.expand_path(File.join(__FILE__, "../lib")))

load File.expand_path(File.join(__FILE__, "../lib/living_dead.rb"))

# Start object tracing, emit a memory address to STDOUT when object is freed
LivingDead.start

def run
  obj = Object.new
  puts "OBJECT ADDRESS TO BE FREED: 0x#{ (obj.object_id << 1).to_s(16) }"
  obj = nil

  nil
end

run

GC.start
