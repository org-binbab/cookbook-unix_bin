#
# Cookbook Name:: unix_bin
# Provider:: package_apt
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

require 'chef/mixin/shell_out'
require 'shellwords'

apt_core_refreshed = false
apt_file_refreshed = false

# Searches for, and attempts to install, a named binary application via
#   the apt package repository. This is accomplished through the use of
#   the command "apt-file".
# \/
action :install do

  extend Chef::Mixin::ShellOut

  bin_name     = new_resource.binary
  search_paths = node.unix_bin.search_paths.to_a
  package_name = new_resource.package  # usually nil
  cmd_aptfile  = '/usr/bin/apt-file'
  cmd_aptget   = '/usr/bin/apt-get'

  # Refresh apt-get cache (if needed).
  unless apt_core_refreshed
    Chef::Log.info "Refreshing apt-get cache..."
    shell_out!("#{cmd_aptget} update")
    apt_core_refreshed = true
  end

  # Install the apt-file tool if needed.
  unless ::File.exists?(cmd_aptfile) or package_name
    pkg_resource = package "apt-file" do
      action :nothing
    end
    pkg_resource.run_action(:install)
    pkg_resource = nil
  end

  # The package_name can be provided as an override, but usually
  # we need to search for through the "apt-file" tool.
  unless package_name
    search_list = search_paths.map do |path|
      "#{path}/#{bin_name}"
    end
    search_args = search_list.map do |path|
      ::Shellwords.escape(path)
    end

    # Refresh apt-file cache (if needed).
    unless apt_file_refreshed
      Chef::Log.info "Refreshing apt-file cache..."
      shell_out!("#{cmd_aptfile} update --non-interactive")
      apt_file_refreshed = true
    end

    Chef::Log.info "Searching apt-file for a package which provides binary (#{bin_name})..."

    search = shell_out!("#{cmd_aptfile} search #{search_args.join(' ')}")
    pattern = Regexp.new("^(.+): (#{search_args.join('|')})$")

    search.stdout.split("\n").each do |line|
      line.chomp!
      next if line.empty?

      pattern.match(line) do |m|
        package_name = m[1]
      end

      # It is preferable to avoid packages with numbers in their name as often these
      # are for alternate (higher) versions than would typically be installed with
      # a more generically named package. I.E. We want the more generic package,
      # and will assume that a supporting package without an alpha-numeric title
      # is the most generic package available.
      break if package_name and not package_name.match(/[0-9]/)
    end
  end  # /if not package_name

  if not package_name
    raise RuntimeError, "Could not determine a package name for unix binary (#{bin_name})."
  end

  Chef::Log.info "Located package (#{package_name}) providing unix binary (#{bin_name}). Installing..."

  # Install the package providing this binary (unless it already is).
  pkg_resource = package package_name do
    action :nothing
  end
  pkg_resource.run_action(:install)
  new_resource.updated_by_last_action(true) if pkg_resource.updated_by_last_action?

  # Install the devel package (if requested).
  if new_resource.with_devel
    Chef::Log.warn("The ability to installing matching devel packages is not available for unix_bin on apt based systems.")
  end

end  # /action
