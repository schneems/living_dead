require 'weakref'

module LivingDead
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