require 'spec_helper'

describe Dotyaml do
  let(:manifests) { [
    {
      :platform=>"Rubygems",
      :path=>"tmp/125/Gemfile",
      :kind=>"manifest",
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
         :kind=>"manifest",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"fail",
              :deprecated=>"fail",
              :unmaintained=>"warn",
              :unlicensed=>"fail",
              :outdated=>"warn",
              :vulnerable=>"fail",
              :broken=>"fail"}}]}])
  end

  it 'skips all of one kind of test' do
    config = {"tests"=>{"removed"=>'skip'}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :kind=>"manifest",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"warn",
              :unlicensed=>"fail",
              :outdated=>"warn",
              :vulnerable=>"fail",
              :broken=>"fail"}}]}])
  end

  it 'skips all of one kind of test for a file' do
    config = {"files"=> {"Gemfile"=>{"tests"=>{"removed"=>"skip"}}}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :kind=>"manifest",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"warn",
              :unlicensed=>"fail",
              :outdated=>"warn",
              :vulnerable=>"fail",
              :broken=>"fail"}}]}])
  end

  it 'skips all of one kind of test for a platform' do
    config = {"platforms"=>{"Rubygems"=>{"tests"=>{"removed"=>"skip"}}}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :kind=>"manifest",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"warn",
              :unlicensed=>"fail",
              :outdated=>"warn",
              :vulnerable=>"fail",
              :broken=>"fail"}}]}])
  end

  it 'skips all of one kind of test for a project' do
    config = {"platforms" => {"Rubygems"=>{"rails" => {"tests"=>{"removed"=>"skip"}}}}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :kind=>"manifest",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"warn",
              :unlicensed=>"fail",
              :outdated=>"warn",
              :vulnerable=>"fail",
              :broken=>"fail"}}]}])
  end

  it 'skips all of one kind of test for a type' do
    config = {"types"=>{"runtime" => {"tests"=>{"removed"=>"skip"}}}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :kind=>"manifest",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"warn",
              :unlicensed=>"fail",
              :outdated=>"warn",
              :vulnerable=>"fail",
              :broken=>"fail"}}]}])
  end


    it 'supports skipping vulnerable test types' do
      config = {"types"=>{"runtime" => {"tests"=>{"vulnerable"=>"skip"}}}}
      tester = Dotyaml::Test.new(manifests, config)
      expect(tester.setup).to eq([
         {
           :platform=>"Rubygems",
           :path=>"tmp/125/Gemfile",
           :kind=>"manifest",
           :dependencies=>
            [{:name=>"rails",
              :requirement=>"= 4.2.6",
              :type=>:runtime,
              :tests=>
               {:removed=>"fail",
                :deprecated=>"fail",
                :unmaintained=>"warn",
                :unlicensed=>"fail",
                :outdated=>"warn",
                :vulnerable=>"skip",
                :broken=>"fail"}}]}])
    end

  it 'is insenstive to case and string/symbols' do
    config = {"platforms"=>{"npm"=>{"jade"=>{"tests"=>{"deprecated"=>"skip"}}}}}
    manifests = [{:platform=>"NPM", :path=>"tmp/1160/npm-shrinkwrap.json", :kind=>"manifest", :dependencies=>[{:name=>"jade", :requirement=>"0.26.3", :type=>"runtime"}]}]
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"NPM",
         :path=>"tmp/1160/npm-shrinkwrap.json",
         :kind=>"manifest",
         :dependencies=>
          [{:name=>"jade",
            :requirement=>"0.26.3",
            :type=>'runtime',
            :tests=>
             {:removed=>"fail",
              :deprecated=>"skip",
              :unmaintained=>"warn",
              :unlicensed=>"fail",
              :outdated=>"warn",
              :vulnerable=>"fail",
              :broken=>"fail"}}]}])
  end

  it 'work with type or types' do
    config = {"type"=>{"development"=>{"tests"=>{"unmaintained"=>"skip"}}}}
    manifests = [{:platform=>"NPM", :path=>"tmp/1160/package.json", :kind=>"manifest", :dependencies=>[{:name=>"grunt-usemin", :requirement=>"~2.0.0", :type=>"development"}]}]
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"NPM",
         :path=>"tmp/1160/package.json",
         :kind=>"manifest",
         :dependencies=>
          [{:name=>"grunt-usemin",
            :requirement=>"~2.0.0",
            :type=>'development',
            :tests=>
             {:removed=>"fail",
              :deprecated=>"fail",
              :unmaintained=>"skip",
              :unlicensed=>"fail",
              :outdated=>"warn",
              :vulnerable=>"fail",
              :broken=>"fail"}}]}])
  end

  it 'work with platform or platforms' do
    config = {"platform" => {"Rubygems"=>{"rails" => {"tests"=>{"removed"=>"skip"}}}}}
    tester = Dotyaml::Test.new(manifests, config)
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"tmp/125/Gemfile",
         :kind=>"manifest",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"skip",
              :deprecated=>"fail",
              :unmaintained=>"warn",
              :unlicensed=>"fail",
              :outdated=>"warn",
              :vulnerable=>"fail",
              :broken=>"fail"}}]}])

  end

  it "works when path isn't in tmp" do
    manifests = [
      {
        :platform=>"Rubygems",
        :path=>"Gemfile",
        :kind=>"manifest",
        :dependencies=>[
          {
            :name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime
          }
        ]
      }
    ]

    tester = Dotyaml::Test.new(manifests, {})
    expect(tester.setup).to eq([
       {
         :platform=>"Rubygems",
         :path=>"Gemfile",
         :kind=>"manifest",
         :dependencies=>
          [{:name=>"rails",
            :requirement=>"= 4.2.6",
            :type=>:runtime,
            :tests=>
             {:removed=>"fail",
              :deprecated=>"fail",
              :unmaintained=>"warn",
              :unlicensed=>"fail",
              :outdated=>"warn",
              :vulnerable=>"fail",
              :broken=>"fail"}}]}])
  end
end
