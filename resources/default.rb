#
# Cookbook Name:: unix_bin
# Resource:: default
#

actions :install, :require
default_action :require

attribute :binary, :name_attribute => true
attribute :in_shell_path, :kind_of => [ TrueClass, FalseClass], :default => true
attribute :with_devel, :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :package, :kind_of => String, :default => nil
