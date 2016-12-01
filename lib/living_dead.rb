require "living_dead/version"
require "living_dead/living_dead"

require 'stringio'

module LivingDead

  @string_io = StringIO.new

  def self.trace(*args)
    self.start
    trace = ObjectTrace.new(*args)

    self.tracing_hash[trace.key] = trace
    self.freed_hash[trace.key]   = false
  end

  def self.traced_objects
    gc_start
    tracing_hash.map do |_, trace|
      trace
    end
  end

  private
    # GIANT BALL OF HACKS || THERE BE DRAGONS
    #
    # There is so much I don't understand on why I need to do the things
    # I'm doing in this method.
    def self.gc_start
      # During debugging I found calling "puts" made some things
      # mysteriously work, I have no idea why. If you remove this line
      # then (more) tests fail. Maybe it has something to do with the way
      # GC interacts with IO? I seriously have no idea.
      #
      @string_io.puts "=="

      # Calling flush so we don't create a memory leak.
      # Funny enough maybe calling flush without `puts` also works?
      # IDK
      #
      @string_io.flush

      # Why do we need this? Well I'll tell you...
      # LivingDead calling `singleton_class.instance_eval` does not retain in the simple case
      # fails without this.
      #
      LivingDead.freed_hash

      # Calling GC multiple times fixes a different class of things
      # Specifically the singleton_class.instance_eval tests.
      # It might also be related to calling GC in a block, but changing
      # to 1.times brings back failures.
      #
      # Calling 2 times results in eventual failure https://twitter.com/schneems/status/804369346910896128
      # Calling 5 times results in eventual failure https://twitter.com/schneems/status/804382968307445760
      # Trying 10 times
      #
      10.times { GC.start }
    end
  public

  def self.freed_objects
    gc_start
    freed_hash.map do |key, _|
      tracing_hash[key]
    end
  end

  class ObjectTrace
    def initialize(obj = nil, object_id: nil, to_s: nil)
      @object_id = object_id || obj.object_id
      @to_s      = to_s&.dup || obj.to_s.dup
    end

    def to_s
      "#<LivingDead::ObjectTrace:#{ "0x#{ (object_id << 1).to_s(16) }" } @object_id=#{@object_id} @to_s=#{ @to_s.inspect }, @freed=#{ freed? }>"
    end

    def inspect
      to_s
    end

    def retained?
      !freed?
    end

    def freed?
      !!LivingDead.freed_hash[@object_id]
    end

    def key
      @object_id
    end
  end
end
