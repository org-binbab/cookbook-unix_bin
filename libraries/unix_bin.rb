#
# Cookbook Name:: unix_bin
# Library:: default
#
# Author:: BinaryBabel OSS (<projects@binarybabel.org>)
# Homepage:: http://www.binarybabel.org
# License:: Apache License, Version 2.0
#
# For bugs, docs, updates:
#
#     http://code.binbab.org
#
# Copyright 2013 sha1(OWNER) = df334a7237f10846a0ca302bd323e35ee1463931
#  
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#  
#     http://www.apache.org/licenses/LICENSE-2.0
#  
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/shell_out'
require 'shellwords'

module UnixBin

  module Utility

    # Checks for binary in the system PATH via 'which'.
    #   Returns true if available, false otherwise.
    # \/
    def unix_bin_available(bin_name, return_cmd_only=false)
      extend ::Chef::Mixin::ShellOut

      unless bin_name.is_a?(String) and bin_name.match('^[a-zA-Z0-9_\.-]+$')
        raise ArgumentError, "Invalid binary name. (#{bin_name.to_s})"
      end

      command = "/usr/bin/which #{::Shellwords.escape(bin_name)}"
      return command if return_cmd_only

      test = shell_out(command)
      return (test.exitstatus == 0)
    end  # /def


    # Searches for binary in provided search paths (non recursive).
    # \/
    def self.unix_bin_search(bin_name, search_paths)
      search_bins = Array.new

      search_paths.each do |path|
        bin_path = "#{path}/#{bin_name}"
        return true if File.exists?(bin_path)
      end

      return false
    end  # /def

  end  # /Utility


  module Chef
    module Resource
      def unix_bin_available(bin_name)
        extend ::UnixBin::Utility
        unix_bin_available(bin_name, true)
      end
    end
  end

end  # /UnixBin

Chef::Resource.send(:include, ::UnixBin::Chef::Resource)
