#
# Cookbook Name:: unix_bin
# Provider:: package_yum
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

# Searches for, and attempts to install, a named binary application via
#   the yum package repository. This is accomplished through the use of
#   the command "yum provides".
# \/
action :install do

  extend Chef::Mixin::ShellOut

  bin_name     = new_resource.binary
  search_arch  = node.kernel.machine
  search_paths = node.unix_bin.search_paths.to_a
  package_name = new_resource.package  # usually nil
  cmd_yum      = '/usr/bin/yum'
  cmd_rpm      = '/bin/rpm'

  # The package_name can be provided as an override, but usually
  # we need to search for through the "yum provides" tool.
  unless package_name
    search_list = search_paths.map do |path|
      "#{path}/#{bin_name}"
    end
    search_args = search_list.map do |path|
      ::Shellwords.escape(path)
    end

    Chef::Log.info "Searching YUM for a package which provides binary (#{bin_name})."

    search = shell_out!("#{cmd_yum} provides #{search_args.join(' ')}")
    pattern = Regexp.new("^([0-9]+:)?(.+?)-[0-9]+\\..+(#{search_arch}|noarch) : ")

    search.stdout.split("\n").each do |line|
      line.chomp!
      next if line.empty?

      if line == "No Matches Found"
        break
      end

      pattern.match(line) do |m|
        package_name = m[2]
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
    devel_package_name = new_resource.devel_package

    if not devel_package_name
      devel_package_name = "#{package_name}-devel"

      devel_pkg_resource = package devel_package_name do
        action :nothing
      end
      test = shell_out("#{cmd_rpm} -q #{::Shellwords.escape(devel_package_name)}")
      unless test.exitstatus == 0  # speed enhancement
        devel_pkg_resource.run_action(:install)
        new_resource.updated_by_last_action(true) if devel_pkg_resource.updated_by_last_action?
      end
    end
  end

end  # /action
