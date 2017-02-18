module Reruby
  class Namespace

    def initialize(const_groups)
      @const_groups = const_groups.map { |cg| cg.split("::") }
    end

    def can_resolve_to?(other_namespace)
      same_last_const?(other_namespace) &&
      all_consts_from_other?(other_namespace) &&
        const_groups_resolve?(other_namespace)
    end

    def flat_namespace
      const_groups.flatten
    end

    def ==(other)
      flat_namespace == other.flat_namespace
    end

    def eql?(other)
      flat_namespace.eql?(other.flat_namespace)
    end

    def hash
      flat_namespace.hash
    end

    protected

    attr_reader :const_groups

    def const_groups_resolve?(other_namespace)
      my_const_groups = const_groups.reverse
      his_namespace = other_namespace.flat_namespace.reverse

      my_const_groups.each do |const_group|
        reversed_const_group = const_group.reverse
        could_consume, his_namespace = consume_const_group(reversed_const_group, his_namespace)
        return false unless could_consume
      end

      true
    end


    def consume_const_group(const_group, his_namespace)
      consumed_until_me = his_namespace.drop_while do |his_const|
        his_const != const_group.first
      end

      return [true, []] if const_group.size == 1 && consumed_until_me.empty?

      const_group.zip(consumed_until_me) do |my_const, his_const|
        if my_const != his_const
          return [false, consumed_until_me]
        end

        consumed_until_me.pop
      end

      [true, consumed_until_me]
    end

    def same_last_const?(other)
      other.flat_namespace.last == flat_namespace.last
    end

    def all_consts_from_other?(other)
      mine_until_his = flat_namespace
      other.flat_namespace.each do |his_const|
        mine_until_his = mine_until_his.drop_while do |my_const|
          my_const != his_const
        end

        return false if mine_until_his.empty?
        mine_until_his.slice(1)
      end

      true
    end
  end
end
