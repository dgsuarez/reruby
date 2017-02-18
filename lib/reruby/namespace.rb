module Reruby
  class Namespace

    def initialize(const_groups)
      @const_groups = const_groups.map { |cg| cg.split("::") }
    end

    def can_resolve_to?(other_namespace)
      conditions = [
        all_consts_from_other?(other_namespace),
        last_const_group_resolves?(other_namespace)
      ]
      conditions.all?
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

    private

    attr_reader :const_groups

    def last_const_group_resolves?(other_namespace)
      const_group = const_groups.last.reverse
      his_namespace = other_namespace.flat_namespace.reverse

      consumed_until_me = his_namespace.drop_while do |his_const|
        his_const != const_group.first
      end

      const_group.zip(consumed_until_me).all? do |my_const, his_const|
        my_const == his_const
      end
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
