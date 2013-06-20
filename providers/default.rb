#
# Cookbook Name:: unix_bin
# Provider:: default
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

require 'chef/mixin/command'


# Installs system packages which provide given binary.
# \/
action :install do
  extend ::UnixBin::Utility

  bin_name = new_resource.binary
  devel = new_resource.with_devel

  # Checks search path or defined search paths for existance of a bin.
  # \/
  def test_install
    bin_name = new_resource.binary

    if new_resource.in_shell_path
      test_result = unix_bin_available(bin_name)
    else
      search_paths = node.unix_bin.search_paths
      test_result = unix_bin_search(bin_name, search_paths)
    end

    test_result
  end  # /def

  if not test_install

    ::Chef::Log.info "Unix binary (#{bin_name}) is required but missing. Attempting to install."

    pkg_resource = unix_bin_package bin_name do
      action :nothing
      with_devel devel
      if new_resource.package
        package new_resource.package
      end
    end
    pkg_resource.run_action(:install)
    new_resource.updated_by_last_action(true) if pkg_resource.updated_by_last_action?

    # Retest.
    if not test_install
      raise RuntimeError, "Could not locate installed unix binary (#{bin_name}). Please check installation."
    end

  else  # tests ok, binary located

    # Caveat: If action requires devel package, we must still trigger the package handler
    #         even though the binary is already installed. This is because we do not know
    #         the package name, and there is no other universal way to match an installed
    #         binary to its devel package.
    if devel
      pkg_resource = unix_bin_package bin_name do
        action :nothing
        with_devel devel
      end
      pkg_resource.run_action(:install)
      new_resource.updated_by_last_action(true) if pkg_resource.updated_by_last_action?
    end

  end  # /if
end  # /action


# Abort Chef run if binary is not installed.
# \/
action :require do
  extend ::UnixBin::Utility

  if new_resource.with_devel
    raise ArgumentError, "Cannot require unix binary with devel flag, must use install action."
  end

  bin_name = new_resource.binary

  if new_resource.in_shell_path
    test_result = unix_bin_available(bin_name)
  else
    search_paths = node.unix_bin.search_paths
    test_result = unix_bin_search(bin_name, search_paths)
  end

  if not test_result
    raise ::Chef::Exceptions::FileNotFound, "Missing required unix binary (#{bin_name}). Please check installation."
  end

  new_resource.updated_by_last_action(false)
end  # /action
