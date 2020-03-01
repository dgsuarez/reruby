# frozen_string_literal: true

require 'spec_helper'

describe Reruby::ExtractMethod::ExtractedMethod do
  before :each do
    @code = <<~CODE
      def old_method
        a = 3
        puts a
      end

      def other_method
        a = 3
        b = puts a
      end
    CODE
    @region = build_code_region(@code, '3:0:3:100')
  end

  context 'with regular arguments' do

    before :each do
      @method = Reruby::ExtractMethod::ExtractedMethod.new(
        name: 'extracted',
        code_region: @region,
        keyword_arguments: false
      )
    end

    it 'returns the invocation' do
      expected_invocation = 'extracted(a)'

      expect(@method.invocation).to eq expected_invocation
    end

    it 'returns the method definition' do
      expected_source = "def extracted(a)\n  puts a\nend"

      expect(@method.source).to eq expected_source
    end

    it 'can create class methods' do
      allow(@region).to receive(:scope_type) { 'class' }
      expected_definition_start = 'def self.extracted(a)'

      expect(@method.source).to include expected_definition_start
    end

    it 'removes last assignment' do

    end
  end

  context 'with keyword arguments' do

    before :each do
      @method = Reruby::ExtractMethod::ExtractedMethod.new(
        name: 'extracted',
        code_region: @region,
        keyword_arguments: true
      )
    end

    it 'returns the invocation' do
      expected_invocation = 'extracted(a: a)'

      expect(@method.invocation).to eq expected_invocation
    end

    it 'returns the body' do
      expected_source = "def extracted(a: )\n  puts a\nend"

      expect(@method.source).to eq expected_source
    end

  end

  context 'with a last assignment' do
    before :each do
      region = build_code_region(@code, '8:0:8:100')

      @method = Reruby::ExtractMethod::ExtractedMethod.new(
        name: 'extracted',
        code_region: region,
        keyword_arguments: false
      )
    end

    it 'assigns the invocation to the same var' do
      expected_invocation = 'b = extracted(a)'

      expect(@method.invocation).to eq expected_invocation
    end

    it 'just adds the rvalue to the extracted method last node' do
      expected_source = "def extracted(a)\n  puts a\nend"

      expect(@method.source).to eq expected_source
    end

  end

end
