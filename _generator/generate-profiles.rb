#!/usr/bin/env ruby
# encoding: utf-8
require_relative 'src/config'
require_relative 'src/profile_generator'

# specify proc_profiles_root_dir, available_package_table
config = Torigoya::ProcProfileGen::Config.new(File.join(File.dirname(File.expand_path(__FILE__)), "../"),
                                              File.join(File.dirname(File.expand_path(__FILE__)), "../../torigoya_factory/apt_repository/available_package_table"),
                                              "/usr/local/torigoya"
                                              )

# make generator
gen = Torigoya::ProcProfileGen::Generator.new(config)
gen.generate()
