require 'spec_helper'

describe Reruby::ParserWrappers::CodeRegion do

  before :each do
    @code = <<-CODE.strip_heredoc
    class A

      def one_method
        b = other_method
        c = b
      end

      def other_method

      end

    end

    CODE
  end

  it "gets the nodes inside a region" do
    region = Reruby::ParserWrappers::CodeRegion.new(@code, "4:1:5:10")
    inner_code = region.inner_nodes.map { |node| node.loc.expression.source.strip }
    expect(inner_code).to eq ["b = other_method\n    c = b"]
  end

  it "gets the nodes for non-full lines" do
    region = Reruby::ParserWrappers::CodeRegion.new(@code, "4:6:5:10")
    inner_code = region.inner_nodes.map { |node| node.loc.expression.source.strip }
    expect(inner_code).to eq ["other_method", "c = b"]

  end

end
