require 'spec_helper'

describe Dotyaml do
  let(:manifests) { [
    {
      :platform=>"Rubygems",
      :path=>"tmp/125/Gemfile",
      :dependencies=>[
        {
          :name=>"rails",
          :requirement=>"= 4.2.6",
          :type=>:runtime
        }
      ]
    }
  ] }

  it 'has a version number' do
    expect(Dotyaml::VERSION).not_to be nil
  end

  it 'runs tests with empty config' do
    config = {}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"fail",
              :deprecated=>"fail",
              :unmaintained=>"fail",
              :unlicensed=>"fail",
              :outdated=>"warn"}}]}])
  end

  it 'skips all of one kind of test' do
    config = {"tests"=>{"removed"=>'skip'}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"fail",
              :unlicensed=>"fail",
              :outdated=>"warn"}}]}])
  end

  it 'skips all of one kind of test for a file' do
    config = {"files"=> {"Gemfile"=>{"tests"=>{"removed"=>"skip"}}}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"fail",
              :unlicensed=>"fail",
              :outdated=>"warn"}}]}])
  end

  it 'skips all of one kind of test for a platform' do
    config = {"platforms"=>{"Rubygems"=>{"tests"=>{"removed"=>"skip"}}}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"fail",
              :unlicensed=>"fail",
              :outdated=>"warn"}}]}])
  end

  it 'skips all of one kind of test for a project' do
    config = {"platforms" => {"Rubygems"=>{"rails" => {"tests"=>{"removed"=>"skip"}}}}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"fail",
              :unlicensed=>"fail",
              :outdated=>"warn"}}]}])
  end

  it 'skips all of one kind of test for a runtime' do
    config = {"types"=>{"runtime" => {"tests"=>{"removed"=>"skip"}}}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"fail",
              :unlicensed=>"fail",
              :outdated=>"warn"}}]}])
  end
end
