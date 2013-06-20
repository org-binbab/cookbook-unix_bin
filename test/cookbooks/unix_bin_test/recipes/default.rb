#
# Cookbook Name:: unix_bin_test
# Recipe:: default
#

unix_bin "zsh" do
  action :install
  not_if unix_bin_available("bash")
end

if platform_family?("rhel")

  unix_bin "mysqldump" do
    action :install
    with_devel true
  end

end
