require "dotyaml/version"
require 'active_support/core_ext/hash/indifferent_access'

module Dotyaml
  class Test
    attr_accessor :manifests
    attr_accessor :config

    def initialize(manifests, config)
      @manifests = manifests
      @config = HashWithIndifferentAccess.new(config)
    end

    def setup
      manifests.map do |manifest|
        map_manifest(manifest)
      end
    end

    def map_manifest(manifest)
      {
        :platform => manifest[:platform],
        :path => manifest[:path],
        :dependencies => manifest[:dependencies].map do |dependency|
          map_dependency(manifest, dependency)
        end
      }
    end

    def map_dependency(manifest, dependency)
      {
        :name => dependency[:name],
        :requirement => dependency[:requirement],
        :type => dependency[:type],
        :tests => tests.map do |test_name, default_value|
          map_test(manifest, dependency, test_name, default_value)
        end.to_h
      }
    end

    def map_test(manifest, dependency, test_name, default_value)
      should_run = default_value

      # test name
      test_name_config = config.fetch('tests', {}).fetch(test_name, nil)
      should_run = test_name_config if test_name_config

      # type
      type_config = config.fetch('types', {}).fetch(dependency[:type], {}).fetch('tests', {}).fetch(test_name, nil)
      should_run = type_config if type_config

      # filename
      filename_config = config.fetch('files', {}).fetch(remove_tmp_path(manifest[:path]), {}).fetch('tests', {}).fetch(test_name, nil)
      should_run = filename_config if filename_config

      # platform
      platform_config = config.fetch('platforms', {}).fetch(manifest[:platform], {}).fetch('tests', {}).fetch(test_name, nil)
      should_run = platform_config if platform_config

      # project name
      project_config = config.fetch('platforms', {}).fetch(manifest[:platform], {}).fetch(dependency[:name], {}).fetch('tests', {}).fetch(test_name, nil)
      should_run = project_config if project_config

      [test_name, should_run.to_s]
    end

    def remove_tmp_path(manifest_path)
      manifest_path.match(/tmp\/\d+\/(.+)/)[1]
    end

    def tests
      {
        :removed      => "fail",
        :deprecated   => "fail",
        :unmaintained => "fail",
        :unlicensed   => "fail",
        :outdated     => "warn"
      }
    end
  end
end
