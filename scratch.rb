$LOAD_PATH.unshift(File.expand_path(File.join(__FILE__, "../lib")))

load File.expand_path(File.join(__FILE__, "../lib/living_dead.rb"))

def run
  obj = Object.new
  LivingDead.trace(obj)


  return obj
end

retained_here = run


puts LivingDead.tracing_hash
puts LivingDead.freed_hash

puts LivingDead.traced_objects.inspect
puts LivingDead.freed_objects.inspect
