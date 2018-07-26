require "living_dead/version"
require "living_dead/living_dead"
require "living_dead/object_trace"

require 'stringio'
require 'objspace'

module LivingDead
  @tracing_hash = {}

  def self.tracing_hash
    @tracing_hash
  end

  def self.trace(*args)
    obj_trace = ObjectTrace.new(*args)
    self.tracing_hash[obj_trace.key] = obj_trace
  end

  def self.traced_objects
    gc_start
    tracing_hash.map do |_, trace|
      trace
    end
  end

  private
    def self.stack_flush(n = 100)
       1.times { stack_flush(n-1) if n > 0 }
    end

    # https://github.com/schneems/heap_problem/pull/1
    def self.gc_start
      stack_flush
      GC.start
    end
  public

  def self.freed_objects
    traced_objects.select {|x| x.freed? }
  end




    end

  end
end
