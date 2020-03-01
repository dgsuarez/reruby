# frozen_string_literal: true

require 'spec_helper'

describe Reruby::ParserWrappers::Require do

  # :reek:UtilityFunction
  def build_relative(*args)
    Reruby::ParserWrappers::Require::Relative.new(*args)
  end

  describe 'Relative' do

    describe '#requires_namespace?' do

      it 'knows if a namespace relative to the given file is required' do
        appears_in_path = 'a/b/c.rb'
        required_namespace = namespace(%w[A::B::D])
        req = build_relative(appears_in_path, './d')

        actual = req.requires_namespace?(required_namespace)

        expect(actual).to be_truthy
      end

      it "knows if a namespace relative to the given file isn't required" do
        appears_in_path = 'a/b/c.rb'
        required_namespace = namespace(%w[A::B::D])
        req = build_relative(appears_in_path, './j')

        actual = req.requires_namespace?(required_namespace)

        expect(actual).to be_falsy
      end

      it 'knows how to jump to parent using ..' do
        appears_in_path = 'a/b/c.rb'
        required_namespace = namespace(%w[A::D])
        req = build_relative(appears_in_path, '../d')

        actual = req.requires_namespace?(required_namespace)

        expect(actual).to be_truthy
      end

      it "ignores common prefixes such as 'lib'" do
        appears_in_path = 'lib/a/b/c.rb'
        required_namespace = namespace(%w[A::B::D])
        req = build_relative(appears_in_path, './d')

        actual = req.requires_namespace?(required_namespace)

        expect(actual).to be_truthy
      end

      it "ignores common prefixes such as 'app/models'" do
        appears_in_path = 'app/models/a/b/c.rb'
        required_namespace = namespace(%w[A::B::D])
        req = build_relative(appears_in_path, './d')

        actual = req.requires_namespace?(required_namespace)

        expect(actual).to be_truthy
      end
    end

    describe '#source_replacing_namespace' do
      it 'returns the required file relative to the given file' do
        appears_in_path = 'a/b/c.rb'

        to_replace_namespace = namespace(%w[A::B::D])
        replace_with_namespace = namespace(%w[A::B::J])

        req = build_relative(appears_in_path, './d')

        actual = req.source_replacing_namespace(to_replace_namespace, replace_with_namespace)

        expect(actual).to eq "require_relative 'j'"
      end

      it 'returns the required file relative to the given file jumping to parent' do
        appears_in_path = 'a/b/c.rb'

        to_replace_namespace = namespace(%w[A::B])
        replace_with_namespace = namespace(%w[A::J])

        req = build_relative(appears_in_path, './d')

        actual = req.source_replacing_namespace(to_replace_namespace, replace_with_namespace)

        expect(actual).to eq "require_relative '../j/d'"
      end

      it 'ignores common code roots' do
        appears_in_path = 'lib/a/b/c.rb'

        to_replace_namespace = namespace(%w[A::B])
        replace_with_namespace = namespace(%w[A::J])

        req = build_relative(appears_in_path, './d')

        actual = req.source_replacing_namespace(to_replace_namespace, replace_with_namespace)

        expect(actual).to eq "require_relative '../j/d'"

      end

    end

  end

end
