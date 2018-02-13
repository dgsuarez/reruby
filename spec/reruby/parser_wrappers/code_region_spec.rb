require 'spec_helper'

describe Reruby::ParserWrappers::CodeRegion do

  # :reek:UtilityMethod
  def build_region(code, range_expression)
    Reruby::ParserWrappers::CodeRegion.new(code, Reruby::TextRange.parse(range_expression))
  end

  before :each do
    @code = <<-CODE.strip_heredoc
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

    end

    CODE
  end

  it "gets the nodes inside a region" do
    region = build_region(@code, "4:1:5:10")

    expect(region.source).to eq "b = other_method\n    c = b"
  end

  it "gets the nodes for non-full lines" do
    region = build_region(@code, "4:6:5:10")

    expect(region.source).to eq "other_method\nc = b"
  end

  it "returns the variables that are defined outside the range" do
    region = build_region(@code, "5:4:5:10")

    expect(region.undefined_variables).to eq ["b"]
  end

  it "returns variables correctly for block arguments" do
    region = build_region(@code, "10:4:13:10")

    expect(region.undefined_variables).to eq %w[param var]
  end

  it "returns variables correctly for keyword_arguments" do
    region = build_region(@code, "16:0:19:10")

    expect(region.undefined_variables).to eq %w[one_param other_param]

  end

end
