require 'yaml'
require 'json'

module Bibliothecary
  module Parsers
    class Go
      include Bibliothecary::Analyser

      def self.parse(filename, path)
        if filename.match(/^glide\.yaml$/)
          file_contents = File.open(path).read
          parse_glide_yaml(file_contents)
        elsif filename.match(/^glide\.lock$/)
          file_contents = File.open(path).read
          parse_glide_lockfile(file_contents)
        elsif filename.match(/^Godeps\/Godeps\.json$/)
          file_contents = File.open(path).read
          parse_godep_json(file_contents)
        elsif filename.match(/^vendor\/manifest$/)
          file_contents = File.open(path).read
          parse_gb_manifest(file_contents)
        else
          []
        end
      end

      def self.match?(filename)
        filename.match(/^glide\.yaml$/) ||
        filename.match(/^glide\.lock$/) ||
        filename.match(/^Godeps\/Godeps\.json$/) ||
        filename.match(/^vendor\/manifest$/)
      end

      def self.parse_godep_json(file_contents)
        manifest = JSON.parse file_contents
        manifest.fetch('Deps',[]).map do |dependency|
          {
            name: dependency['ImportPath'],
            requirement: dependency['Rev'],
            type: 'runtime'
          }
        end
      end

      def self.parse_glide_yaml(file_contents)
        manifest = YAML.load file_contents
        manifest.fetch('import',[]).map do |dependency|
          {
            name: dependency['package'],
            requirement: dependency['version'] || '*',
            type: 'runtime'
          }
        end + manifest.fetch('devImports',[]).map do |dependency|
          {
            name: dependency['package'],
            requirement: dependency['version'] || '*',
            type: 'development'
          }
        end
      end

      def self.parse_glide_lockfile(file_contents)
        manifest = YAML.load file_contents
        manifest.fetch('imports',[]).map do |dependency|
          {
            name: dependency['name'],
            requirement: dependency['version'] || '*',
            type: 'runtime'
          }
        end
      end

      def self.parse_gb_manifest(file_contents)
        manifest = JSON.parse file_contents
        manifest.fetch('dependencies',[]).map do |dependency|
          {
            name: dependency['importpath'],
            requirement: dependency['revision'],
            type: 'runtime'
          }
        end
      end
    end
  end
end
