# encoding: utf-8
require 'yaml'


module Torigoya
  module ProcProfileGen

    class TemplateHolder
      #
      def initialize( config, tag )
        @config = config
        @tag = tag
        @templates = make_template()
      end
      attr_reader :tag, :templates


      private

      #
      def make_template
        #
        replace_hash = {
          install_base: @config.install_path,
          version: @tag.version,
          display_version: @tag.display_version
        }

        templates = []

        #
        # make profiles
        Dir.chdir( "#{@config.proc_profiles_root_dir}/templates" ) do
          puts "===> globbing at #{@tag.name}"

          if File.exists?( @tag.name )
            Dir.chdir( @tag.name ) do
              Dir.glob( "*.yml.txt" ) do |pkgname|
                target_name = File.basename( pkgname, ".yml.txt" )

                is_patch = false
                target_version_op = ''
                target_version = ''
                if match = pkgname.match( /^patch\.(.*?)\.:(=|>\=|<\=|>|<)?(.*?):\.yml.txt/ )
                  is_patch = true
                  target_name, target_version_op, target_version = match.captures
                end

                puts "== #{target_name} / is_patch? #{is_patch}"

                File.open( pkgname, "r" ) do |file|
                  value = file.read

                  templates << {
                    'name' => "#{target_name}/#{tag.version}.yml",
                    'data' => value,
                    'replace_hash' => replace_hash,
                    'is_patch' => is_patch,
                    'target_name' => target_name,
                    'target_version_op' => target_version_op,
                    'target_version' => target_version
                  }
                end
              end
            end
          else
            puts "== not found"
          end
        end # Dir.chdir
        return templates
      end

    end # class

  end # module ProcProfileGen
end # module Torigoya
