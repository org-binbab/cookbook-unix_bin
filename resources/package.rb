#
# Cookbook Name:: unix_bin
# Resource:: package
#

actions :install
default_action :install

attribute :binary, :name_attribute => true
attribute :package, :kind_of => String, :default => nil
attribute :devel_package, :kind_of => String, :default => nil
attribute :with_devel, :kind_of => [ TrueClass, FalseClass ], :default => false