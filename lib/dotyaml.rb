require "dotyaml/version"
require 'active_support/core_ext/hash/indifferent_access'

module Dotyaml
  class Test
    attr_accessor :manifests
    attr_accessor :config

    def initialize(manifests, config)
      @manifests = manifests.map{|m| m.deep_transform_keys{ |key| key.to_s.downcase } }
      @config = config.deep_transform_keys{ |key| key.to_s.downcase }
    end

    def setup
      manifests.map do |manifest|
        map_manifest(manifest)
      end
    end

    def map_manifest(manifest)
      {
        :platform => manifest['platform'],
        :path => manifest['path'],
        :kind => manifest['kind'],
        :dependencies => manifest['dependencies'].map do |dependency|
          map_dependency(manifest, dependency)
        end
      }
    end

    def map_dependency(manifest, dependency)
      {
        :name => dependency['name'],
        :requirement => dependency['requirement'],
        :type => dependency['type'],
        :tests => tests.map do |test_name, default_value|
          map_test(manifest, dependency, test_name, default_value.downcase)
        end.to_h
      }
    end

    def map_test(manifest, dependency, test_name, default_value)
      should_run = default_value
      test_name_key = test_name.to_s.downcase

      # test name
      test_name_config = config.fetch('tests', {}).fetch(test_name_key, nil)
      should_run = test_name_config if test_name_config

      # type
      type_config = config.fetch('type', {}).fetch(dependency['type'].to_s.downcase, {}).fetch('tests', {}).fetch(test_name_key, nil)
      should_run = type_config if type_config

      # types
      type_config = config.fetch('types', {}).fetch(dependency['type'].to_s.downcase, {}).fetch('tests', {}).fetch(test_name_key, nil)
      should_run = type_config if type_config

      # filename
      filename_config = config.fetch('files', {}).fetch(remove_tmp_path(manifest['path'].to_s.downcase), {}).fetch('tests', {}).fetch(test_name_key, nil)
      should_run = filename_config if filename_config

      # platform
      platform_config = config.fetch('platform', {}).fetch(manifest['platform'].to_s.downcase, {}).fetch('tests', {}).fetch(test_name_key, nil)
      should_run = platform_config if platform_config

      # platforms
      platform_config = config.fetch('platforms', {}).fetch(manifest['platform'].to_s.downcase, {}).fetch('tests', {}).fetch(test_name_key, nil)
      should_run = platform_config if platform_config

      # project name
      project_config = config.fetch('platform', {}).fetch(manifest['platform'].to_s.downcase, {}).fetch(dependency['name'].to_s.downcase, {}).fetch('tests', {}).fetch(test_name_key, nil)
      should_run = project_config if project_config

      # project name
      project_config = config.fetch('platforms', {}).fetch(manifest['platform'].to_s.downcase, {}).fetch(dependency['name'].to_s.downcase, {}).fetch('tests', {}).fetch(test_name_key, nil)
      should_run = project_config if project_config

      [test_name, should_run.to_s]
    end

    def remove_tmp_path(manifest_path)
      match = manifest_path.match(/tmp\/\d+\/(.+)/)
      match ? match[1] : manifest_path
    end

    def tests
      {
        :removed      => "fail",
        :deprecated   => "fail",
        :unmaintained => "fail",
        :unlicensed   => "fail",
        :outdated     => "warn",
        :vulnerable   => "fail",
        :broken       => "fail"
      }
    end
  end
end
