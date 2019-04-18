require 'spec_helper'

describe Reruby::ParserWrappers::CodeRegion do

  def region_to_source(code_region)
    sources = code_region.nodes.map do |node|
      node.loc.expression.source
    end

    sources.join("\n")
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

      def self.a_class_method
        33
      end

      def reader
        @reader
      end

    end

    CODE
  end

  describe '#nodes' do
    it 'gets the nodes inside a region' do
      region = build_code_region(@code, '4:1:5:10')

      expect(region_to_source(region)).to eq "b = other_method\n    c = b"
    end

    it 'gets the nodes for non-full lines' do
      region = build_code_region(@code, '4:6:5:10')

      expect(region_to_source(region)).to eq "other_method\nc = b"
    end

    it 'gets parts of a single line' do
      region = build_code_region(@code, '4:8:4:19')

      expect(region_to_source(region)).to eq 'other_method'
    end
  end

  describe '#scope_type' do
    it 'is method if all the code is inside a regular method' do
      region = build_code_region(@code, '4:1:5:10')

      expect(region.scope_type).to eq 'method'
    end

    it 'is class if all the code is inside a class method' do
      region = build_code_region(@code, '22:4:22:6')

      expect(region.scope_type).to eq 'class'
    end

    it 'is global for code in the global scope' do
      code = <<-CODE
        some
        global
        code
      CODE

      region = build_code_region(code, '1:1:2:100')

      expect(region.scope_type).to eq 'global'
    end
  end
end
