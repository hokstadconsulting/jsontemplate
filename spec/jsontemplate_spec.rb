require 'spec_helper'

describe JsonTemplate do
  let (:basicjson) { '{"foo": "bar"}' }

  it 'has a version number' do
    expect(JsonTemplate::VERSION).not_to be nil
  end

  it 'returns an identical JSON structure if passed a simple JSON document with no directives' do
    expect(JsonTemplate.new(StringIO.new(basicjson)).process_dict).to eq(JSON.load(basicjson))
  end

  describe '$Flookup' do
    it 'allows key lookup and expansion from another JSON file' do
      expect(JsonTemplate.new(StringIO.new('{"foo": {"$FLookup": ["parameters.json","key1"]}}')).process_dict).to eq({"foo" => "value1"})
    end

    it 'uses the base path of the original JSON file as the base path for lookup of the parameter expansion' do
      expect(JsonTemplate.new("spec/fixtures/files/flookup.json").process).to eq({"foo" => "value1"})
    end
  end


  it 'can be nested within an array' do
    expect(JsonTemplate.new(StringIO.new('{"foo": [{"$FLookup": ["parameters.json","key1"]}]}')).process_dict).to eq({"foo" => ["value1"]})
  end

  it 'can be nested within an array multiple times' do
    expect(JsonTemplate.new(StringIO.new('{"foo": [[{"$FLookup": ["parameters.json","key1"]}]]}')).process_dict).to eq({"foo" => [["value1"]]})
  end

  describe '$Prop' do
    it 'allows key lookup and expansion from a specified properties file' do
      expect(JsonTemplate.new(StringIO.new('{"foo": {"$Prop": "key1"}}')).process_dict).to eq({"foo" => "value1"})
    end
  end

  describe '$Secret' do
    it 'allows key lookup and expansion from a specified "secret" properties file' do
      expect(JsonTemplate.new(StringIO.new('{"foo": {"$Secret": "password"}}')).process_dict).to eq({"foo" => "pre$ident"})
    end
  end
  
  describe '$DirMerge' do
    it 'merges the contents of a subdirectory' do
      expect(JsonTemplate.new("spec/fixtures/files/dirmerge.json").process).to eq({"subfile"=>{"SomeKey1"=>"SomeValue"}, "subfile2"=>{"SomeKey2"=>"SomeValue"}})
    end
  end
end
