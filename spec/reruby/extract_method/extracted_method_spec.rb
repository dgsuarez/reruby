require 'spec_helper'

describe Reruby::ExtractMethod::ExtractedMethod do

  before :each do
    @region = instance_double(
      Reruby::ParserWrappers::CodeRegion,
      source: "a = 3; puts a",
      undefined_variables: ["a"],
      scope_type: "method"
    )

    @method = Reruby::ExtractMethod::ExtractedMethod.new(
      name: "extracted",
      code_region: @region,
      keyword_arguments: false
    )
  end

  it "returns the invocation" do
    expected_invocation = "extracted(a)"

    expect(@method.invocation).to eq expected_invocation
  end

  it "returns the method definition" do
    expected_source = "def extracted(a)\n  a = 3; puts a\nend"

    expect(@method.source).to eq expected_source
  end

  it "can use keyword arguments" do
    with_named = Reruby::ExtractMethod::ExtractedMethod.new(
      name: "extracted",
      code_region: @region,
      keyword_arguments: true
    )

    expected_invocation = "extracted(a: a)"

    expect(with_named.invocation).to eq expected_invocation
  end

  it "can create class methods" do
    allow(@region).to receive(:scope_type) { 'class' }
    expected_definition_start = "def self.extracted(a)"

    expect(@method.source).to include expected_definition_start
  end

end
