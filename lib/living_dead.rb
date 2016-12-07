require "living_dead/version"
require "living_dead/living_dead"

require 'stringio'
require 'objspace'
require 'weakref'

module LivingDead

  @string_io = StringIO.new
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

  class ObjectTrace
    def initialize(obj = nil, object_id: nil, to_s: nil)
      @object_id = object_id || obj.object_id
      @to_s      = to_s&.dup || obj.to_s.dup
      @weakref   = WeakRef.new(obj)
    end

    def to_s
      "#<LivingDead::ObjectTrace:#{ "0x#{ (object_id << 1).to_s(16) }" } @object_id=#{@object_id} @to_s=#{ @to_s.inspect }, @freed=#{ freed? }>"
    end

    def inspect
      to_s
    end

    def retained?
      @weakref.weakref_alive?
    end

    def freed?
      !retained?
    end

    def key
      @object_id
    end
  end
end
