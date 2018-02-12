require 'spec_helper'

describe Reruby::ParserWrappers::CodeRegion do

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

    end

    CODE
  end

  it "gets the nodes inside a region" do
    region = Reruby::ParserWrappers::CodeRegion.new(@code, "4:1:5:10")

    expect(region.source).to eq "b = other_method\n    c = b"
  end

  it "gets the nodes for non-full lines" do
    region = Reruby::ParserWrappers::CodeRegion.new(@code, "4:6:5:10")

    expect(region.source).to eq "other_method\nc = b"
  end

  it "returns the variables that are defined outside the range" do
    region = Reruby::ParserWrappers::CodeRegion.new(@code, "5:4:5:10")

    expect(region.undefined_variables).to eq ["b"]
  end

  it "returns variables correctly for block params" do
    region = Reruby::ParserWrappers::CodeRegion.new(@code, "10:4:13:10")

    expect(region.undefined_variables).to eq %w[param var]
  end

end
