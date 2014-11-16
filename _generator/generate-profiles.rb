#!/usr/bin/env ruby
# encoding: utf-8
require 'optparse'
require_relative 'src/config'
require_relative 'src/profile_generator'

proc_profiles_root_dir = File.join(File.dirname(File.expand_path(__FILE__)), "../")
available_package_table = nil

#
opt = OptionParser.new
opt.on('-l [VAL]') do |v|
  available_package_table = if v.nil?
                              File.join(File.dirname(File.expand_path(__FILE__)), "../../torigoya_factory/apt_repository/available_package_table")
                            else
                              v
                            end
end

opt.on('-r [VAL]') do |v|
  unless v == 'false'
    r = system("wget -r -np http://packages.sc.yutopp.net/available_package_table/")
    unless r
      puts "Failed to download remote files"
      exit -2
    end
  end

  available_package_table = File.join(File.dirname(File.expand_path(__FILE__)), "/packages.sc.yutopp.net/available_package_table")
end

opt.parse!(ARGV)

if available_package_table.nil?
  puts "Please specify one of these options."
  puts "  -l [PATH=defaul] : Read local files"
  puts "  -r [WITH_UPDATE]  : Read remote files(false: use cache)"
  exit -1
end

# specify proc_profiles_root_dir, available_package_table
config = Torigoya::ProcProfileGen::Config.new(proc_profiles_root_dir,
                                              available_package_table,
                                              "/usr/local/torigoya"
                                              )

# make generator
gen = Torigoya::ProcProfileGen::Generator.new(config)
gen.remove_dirs()
gen.generate()
