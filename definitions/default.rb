#
# Cookbook Name:: unix_bin
# Definition:: default
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


# Helper definition for bulk actions. Example:
##   unix_binaries do
##     install [ "nslookup", "wget" ]
##     require "java"
##   end
# \/
define :unix_binaries do

  devel = params[:with_devel] || false
  in_path = params[:in_shell_path] || true

  bin_list = params[:install] || Array.new
  Array(bin_list).each do |bin_name|
    unix_bin bin_name do
      action :install
      in_shell_path in_path
      with_devel devel
    end
  end

  bin_list = params[:require] || Array.new
  Array(bin_list).each do |bin_name|
    unix_bin bin_name do
      action :require
      in_shell_path in_path
      with_devel devel
    end
  end

end # /define