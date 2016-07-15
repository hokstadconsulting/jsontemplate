require 'spec_helper'

describe JsonTemplate do
  let (:basicjson) { '{"foo": "bar"}' }

  it 'has a version number' do
    expect(JsonTemplate::VERSION).not_to be nil
  end

  it 'returns an identical JSON structure if passed a simple JSON document with no directives' do
    expect(JsonTemplate.new(StringIO.new(basicjson)).process_dict).to eq(JSON.load(basicjson))
  end

  it 'allows key lookup and expansion from another JSON file' do
    expect(JsonTemplate.new(StringIO.new('{"foo": {"$FLookup": ["parameters.json","key1"]}}')).process_dict).to eq({"foo" => "value1"})
  end
end
