#
# Cookbook Name:: unix_bin_test
# Recipe:: default
#

begin
  (unix_bin "test_nonexistant_bin" do
    action :nothing
  end).run_action(:require)
rescue ::Chef::Exceptions::FileNotFound => e
  node.override["unix_bin_test"]["action_require_passed"] = true
end


################################################################################
## centos ##
################################################################################

if platform?("centos")
  {
      "/usr/sbin/yum-complete-transaction" => "yum-utils",
      "/usr/bin/nslookup"   => "bind-utils",
      "/bin/zsh"            => "zsh",
      "/usr/bin/mysqldump"  => "mysql"
  }.each do |bin_path,pkg_name|

    bin_name = File.basename(bin_path)

    if File.exists?(bin_path)
      pkg_res = package pkg_name do
        action :nothing
      end
      pkg_res.run_action(:remove)

      if node.platform_version.to_i == 5 and pkg_name == "mysql"
        # workaround for package oddity
        File.unlink(bin_path)
      end
    end

    if File.exists?(bin_path)
      raise RuntimeError, "Failed to uninstall #{bin_name} to prepare for testing."
    end

    if pkg_name == "zsh"
      package pkg_name do
        action :install
        not_if unix_bin_available("bash")
      end
      next
    end

    unix_bin bin_name do
      action :install

      if pkg_name == "mysql"
        with_devel true
      end
    end

  end  # /each
end


################################################################################
## ubuntu ##
################################################################################

if platform?("ubuntu")
  {
      "/usr/bin/vim.basic" => "vim",
      "/usr/bin/ncat"      => "nmap",
      "/usr/bin/mysqldump" => "mysql-client"
  }.each do |bin_path,pkg_name|
  
    bin_name = File.basename(bin_path)

    if File.exists?(bin_path)
      pkg_res = package String(`dpkg -S #{bin_path} | awk -F: '{print $1;}'`).chomp do
        action :nothing
      end
      pkg_res.run_action(:remove)
    end

    if File.exists?(bin_path)
      raise RuntimeError, "Failed to uninstall #{bin_name} to prepare for testing."
    end

    unix_bin bin_name do
      action :install
    end

  end  # /each
end