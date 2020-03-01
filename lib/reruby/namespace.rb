# frozen_string_literal: true

module Reruby
  module Namespace

    def self.from_source(source)
      Absolute.new(source.split('::'))
    end

    def self.from_list(list)
      absolutes = list.map do |source|
        from_source(source)
      end

      Relative.new(absolutes)
    end

    def self.from_require_path(require_path)
      parts = require_path.split('/').map(&:camelize)

      Absolute.new(parts)
    end

    class Base
      extend Forwardable

      def_delegators :flat_namespace, :length, :empty?, :hash

      def relative_path
        "#{as_require}.rb"
      end

      def as_require
        flat_namespace.join('/').underscore
      end

      def as_source
        flat_namespace.join('::')
      end

      def nested_one_level_in?(other_namespace)
        nesting_level = nesting_level_in(other_namespace)
        nesting_level == 1
      end

      def nested_in_or_same_as?(other_namespace)
        nesting_level_in(other_namespace)
      end

      def relativize
        Namespace.from_list(flat_namespace)
      end

      def ==(other)
        flat_namespace == other.flat_namespace
      end
      alias eql? ==

      def adding(new_part)
        if new_part.is_a?(Root)
          Relative.new([new_part])
        else
          Relative.new(parts + [new_part])
        end
      end

      def parent
        Namespace.from_list(flat_namespace.slice(0..-2))
      end

      def last_const
        flat_namespace.last
      end

      protected

      def subnamespaces_of_size(size)
        possibles = flat_namespace.each_with_index.map do |_, index|
          flat_namespace.slice(index, size)
        end

        possibles.select { |slice| slice.length == size }
      end

      private

      def nesting_level_in(other_namespace)
        other_namespace.flat_namespace.zip(flat_namespace).each do |mine, other|
          return nil if mine != other
        end
        length - other_namespace.length
      end
    end

    class Absolute < Base

      def initialize(consts)
        @consts = consts
      end

      def can_resolve_to?(other_namespace)
        included?(other_namespace)
      end

      def flat_namespace
        consts
      end

      def to_s
        "#{self.class.name} #{as_source}"
      end

      def parts
        [self]
      end

      def index_in(other_namespace)
        reversed_sub_consts = other_namespace.subnamespaces_of_size(consts.length).reverse
        remaining_consts = reversed_sub_consts.drop_while do |other_consts|
          other_consts != consts
        end

        if remaining_consts.empty?
          nil
        else
          remaining_consts.flatten.count - 1
        end
      end

      def included?(other_namespace)
        index_in(other_namespace)
      end

      # :reek:UncommunicativeParameterName N as in math
      def take_n_consts(n)
        self.class.new(consts.take(n))
      end

      private

      attr_reader :consts
    end

    class Root < Absolute

      def as_source
        '::' + super
      end

      def index_in(other_namespace)
        beginning_of_other = other_namespace.subnamespaces_of_size(consts.length).first
        0 if beginning_of_other == consts
      end

      def included?(other_namespace)
        index_in(other_namespace)
      end

    end

    class Relative < Base

      attr_reader :parts

      def initialize(parts)
        @parts = parts
      end

      def to_s
        "#{self.class} #{parts.map(&:to_s)}"
      end

      def flat_namespace
        parts.flat_map(&:flat_namespace)
      end

      def can_resolve_to?(other_namespace)
        has_all_consts_from?(other_namespace) && last_part_resolves?(other_namespace)
      end

      def has_all_consts_from?(other_namespace)
        ns_to_check = self

        other_namespace.parts.reverse_each do |part|
          part_idx = part.index_in(ns_to_check)
          return false unless part_idx

          ns_to_check = ns_to_check.take_n_consts(part_idx)
        end
      end

      # :reek:UncommunicativeParameterName: N as in math
      # :reek:FeatureEnvy
      def take_n_consts(n)
        ret = Relative.new([])
        parts.each do |part|
          max_consts_to_take = n - ret.length
          return ret if max_consts_to_take <= 0

          ret = ret.adding(part.take_n_consts(max_consts_to_take))
        end
        ret
      end

      def last_part_resolves?(other_namespace)
        flat_namespace.last == other_namespace.flat_namespace.last &&
          parts.last.included?(other_namespace)
      end

    end

    class Tracker

      attr_reader :namespace

      def initialize
        @namespace = Relative.new([])
      end

      def open_namespace(ns_to_open)
        old_namespace = namespace
        @namespace = namespace.adding(ns_to_open)

        yield

        @namespace = old_namespace
      end

    end

  end
end
