# encoding: utf-8

module Torigoya
  module ProcProfileGen
    class Config
      def initialize(proc_profiles_root_dir, available_package_table, install_path)
        @proc_profiles_root_dir = proc_profiles_root_dir
        @available_package_table = available_package_table
        @install_path = install_path
      end
      attr_reader :proc_profiles_root_dir, :available_package_table, :install_path
    end
  end # module ProcProfileGen
end # module Torigoya
