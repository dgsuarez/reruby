# frozen_string_literal: true

require 'spec_helper'

describe Reruby::ExtractMethod::UndefinedVariablesExtractor do
  before :each do
    # rubocop:disable Layout/HeredocIndentation
    @code = <<~CODE
    class A

      def one_method
        b = other_method
        c = b
      end

      def other_method(param)
        var = 3
        param.each do |something_else|
          something_else.some(var)
        end
      end

      def yet_another_method(one_param:, other_param: 3)
        one_param.each do |required_param:|
          other_param + required_param
        end
      end

      def self.a_class_method
        33
      end

      def reader
        @reader
      end

    end

    CODE
    # rubocop:enable Layout/HeredocIndentation

    @extractor = Reruby::ExtractMethod::UndefinedVariablesExtractor.new
  end

  it 'returns the variables that are defined outside the range' do
    region = build_code_region(@code, '5:4:5:10')

    expect(@extractor.undefined_variables_in_region(region)).to eq ['b']
  end

  it 'returns variables correctly for block arguments' do
    region = build_code_region(@code, '10:4:13:10')

    expect(@extractor.undefined_variables_in_region(region)).to eq %w[param var]
  end

  it 'returns variables correctly for keyword_arguments' do
    region = build_code_region(@code, '16:0:19:10')

    expect(@extractor.undefined_variables_in_region(region)).to eq %w[one_param other_param]
  end

  it "doesn't consider instance variables as undefined" do
    region = build_code_region(@code, '26:0:26:10')

    expect(@extractor.undefined_variables_in_region(region)).to be_empty
  end
end
