require 'spec_helper'

describe Reruby::Config do

  it "returns a multi key by using paths with dot separations" do
    conf = Reruby::Config.new(options: {"a" => {"b" => "c"}})

    expect(conf.get("a.b")).to eq("c")
  end

  it "returns nil when the key is not there" do
    conf = Reruby::Config.new(options: {"a" => {"b" => "c"}})

    expect(conf.get("j.b")).to be_nil
  end

  it "tries to get from the next config if given" do
    fallback_config = Reruby::Config.new(options: {"j" => {"b" => "h"}})
    conf = Reruby::Config.new(fallback_config: fallback_config,
                              options: {"a" => {"b" => "c"}})

    expect(conf.get("j.b")).to eq("h")
  end

end
