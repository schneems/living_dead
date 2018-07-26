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
    clear_garbage!
    tracing_hash.map do |_, trace|
      trace
    end
  end

  def self.freed_objects
    traced_objects.select { |x| x.freed? }
  end

private
  # Here's the deal: Running GC.start does NOT guarantee
  # that all "dead" objects will be cleared. Which is sad
  # because this gem would have been really simple if that was
  # the case.
  #
  # The way to work around that is by creating an object that is
  # not retained and tracing it with ObjectTrace. We then
  # must get Ruby to clear objects in the (object) heap and the stack
  # to do that we iteratively create new objects and block objects
  # until we can determine that the val that we made and traced is
  # no longer retained by Ruby.
  #
  # When this happens we assume that any other dead objects that the
  # user was watching are cleared as well.
  #
  # This is still not 100% guaranteed, but it's a good place to start.
  #
  # Some more context:
  #   https://github.com/schneems/heap_problem/pull/1
  def self.clear_garbage!
    val       = Object.new
    obj_trace = ObjectTrace.new(val)
    val = nil

    n = 100
    while obj_trace.retained?
      n += 1
      block_stack_flush(n)
      object_stack_flush(n)
    end

    GC.start
  end

  def self.block_stack_flush(n)
    1.times { block_stack_flush(n - 1) if n > 0 }
  end

  def self.object_stack_flush(n)
    val = Object.new
    val = nil
    object_stack_flush(n - 1) if n > 0
    nil
  end
end
