# encoding: utf-8
require 'time'
require 'yaml'
require 'torigoya_kit'
require_relative 'template_holder'


module Torigoya
  module ProcProfileGen
    class Generator
      #
      def initialize( config )
        @config = config
      end
      attr_reader :config


      #
      def generate()
        template_holders = make_package_tags().map{|tag| TemplateHolder.new( @config, tag ) }

        # collect patchs
        patch_templates = []
        template_holders.each do |holder|
          holder.templates.each do |template|
            patch_templates << template if template['is_patch']
          end
        end

        # sort by order of applying
        # -1 => a / 1 => b comes first
        ale = ['=', '<', '<=']
        ag = ['>=', '>']
        patch_templates.sort! do |a, b|
          if a['target_version_op'].nil?
            1
          elsif b['target_version_op'].nil?
            -1
          else
            if ale.include?( a['target_version_op'] )
              if ale.include?( b['target_version_op'] )
                cmp = b['target_version'] <=> a['target_version']
                if cmp == 0
                  ale.index( b['target_version_op'] ) <=> ale.index( a['target_version_op'] )
                else
                  cmp
                end
              else
                -1
              end

            else
              if ag.include?( b['target_version_op'] )
                cmp = a['target_version'] <=> b['target_version']
                if cmp == 0
                  ag.index( a['target_version_op'] ) <=> ag.index( b['target_version_op'] )
                else
                  cmp
                end
              else
                1
              end
            end
          end
        end

        # make profiles
        template_holders.each do |holder|
          holder.templates.each do |template|
            next if template['is_patch']

            out_path = "#{@config.proc_profiles_root_dir}/#{template['name']}"

            puts '', '#' * 60
            puts template['target_name']
            puts "name              : #{holder.tag.name}"
            puts "version           : #{holder.tag.version}"
            puts "display_version   : #{holder.tag.display_version}"
            puts "package_name      : #{holder.tag.package_name}"
            puts "writing config    -> #{out_path}"

            data = template['data']

            # patching
            patch_templates.each do |pt|
              if pt['target_name'] == template['target_name']
                applicable = false
                applicable |= pt['target_version_op'].nil?
                unless pt['target_version_op'].nil?
                  applicable |= case pt['target_version_op']
                                when '<'
                                  holder.tag.version < pt['target_version']
                                when '<='
                                  holder.tag.version <= pt['target_version']
                                when '='
                                  holder.tag.version == pt['target_version']
                                when '>='
                                  holder.tag.version >= pt['target_version']
                                when '>'
                                  holder.tag.version > pt['target_version']
                                end
                end

                puts "#{holder.tag.version} #{pt['target_version_op']} #{pt['target_version']} => #{applicable}"

                unless pt['data']['overwrite'].nil?
                  value_overwrite( nil, data, pt['data']['overwrite'] )
                end

                unless pt['data']['push_back'].nil?
                  value_push_pack( nil, data, pt['data']['push_back'] )
                end

              end
            end

            validate_and_format( data )

            str_data = YAML.dump( data )
            puts str_data

            # write down
            unless File.exists?(File.dirname(out_path))
              FileUtils.mkdir_p(File.dirname(out_path))
            end
            File.open( out_path, "wb" ) do |f|
              f.write( str_data )
            end
          end
        end

        return template_holders
      end


      private


      #
      def make_package_tags
        package_profiles = make_package_profiles_list().sort_by{|x| x.built_date }

        return package_profiles.map{|profile| TorigoyaKit::Package::Tag.new( profile.package_name ) }
      end


      # similar to the function in env_updater
      def make_package_profiles_list
        package_profiles = []

        #
        if File.exists?( @config.available_package_table )
          # glob
          Dir.chdir( @config.available_package_table ) do
            Dir.glob( "*.yml" ) do |filename|
              puts "=> pick package profiles #{filename}"
              package_profiles << TorigoyaKit::Package::AvailableProfile.load_from_yaml( filename )
            end
          end
        else
          puts "There is no History Dir [#{@config.available_package_table}]"
        end # if

        return package_profiles
      end


      #
      def value_overwrite( key, oldval, newval )
        if key.nil?
          return oldval.merge!( newval ) {|*args| value_overwrite( *args ) }
        end

        if oldval.instance_of?( Hash ) && newval.instance_of?( Hash )
          return oldval.merge( newval ) {|*args| value_overwrite( *args ) }
        else
          newval
        end
      end


      #
      def value_push_pack( key, oldval, newval )
        if key.nil?
          return oldval.merge!( newval ) {|*args| value_push_pack( *args ) }
        end

        if oldval.instance_of?( Hash ) && newval.instance_of?( Hash )
          return oldval.merge( newval ) {|*args| value_push_pack( *args ) }
        else
          if oldval.nil?
            newval
          else
            oldval + newval
          end
        end
      end


      #
      def validate_and_format( data )
        raise "nil" if data.nil?

        raise "varsion missed" if data["version"].nil?

        raise "is_build_required missed" if data["is_build_required"].nil?
        raise "is_build_required should be Boolean" if !( data["is_build_required"].instance_of?(TrueClass) || data["is_build_required"].instance_of?(FalseClass) )

        raise "is_link_independent missed" if data["is_link_independent"].nil?
        raise "is_link_independent should be Boolean" if !( data["is_link_independent"].instance_of?(TrueClass) || data["is_link_independent"].instance_of?(FalseClass) )

        validate_and_format_section( data, "source" )
        validate_and_format_section( data, "compile" )
        validate_and_format_section( data, "link" )
        validate_and_format_section( data, "run" )

        return nil
      end


      def validate_and_format_section( data, name )
        raise "nil" if data.nil?

        unless data[name].nil?
          r = data[name].each_key.reject do |k|
            k == "file" ||
            k == "extension" ||
            k == "command" ||
            k == "env" ||
            k == "allowed_command_line" ||
            k == "fixed_command_line"
          end
          if r.size != 0
            p r
            raise "these keys are rejected [#{name}]"
          end

          unless data[name]["allowed_command_line"].nil?
            data[name]["allowed_command_line"].each do |key, value|
              unless value.nil?
                unless value['default'].nil?
                  raise "default command line shoulr be Array [#{name}]" unless value['default'].instance_of?(Array)
                end

                unless value['select'].nil?
                  raise "select command line shoulr be Array [#{name}]" unless value['select'].instance_of?(Array)
                end
              end
            end
          end

          unless data[name]["fixed_command_line"].nil?
            raise "fixed_command_line should be Array [#{name}]" if !data[name]["fixed_command_line"].instance_of?(Array)
            arrays = []
            data[name]["fixed_command_line"].each do |v|
              raise "only one k/v can be includes" if v.size != 1
              arrays << v.to_a[0]
            end
            data[name]["fixed_command_line"] = arrays
          end
        end
      end

    end # class Generator
  end # module ProcProfileGen
end # module Torigoya
