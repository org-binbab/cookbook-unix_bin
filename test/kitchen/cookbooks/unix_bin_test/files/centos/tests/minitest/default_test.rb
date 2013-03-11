require 'minitest/spec'

describe_recipe "unix_bin::default" do

  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources

  describe "asked to install yum-complete-transaction" do
    it "installs the package yum-utils" do
      package("yum-utils").must_be_installed
      file("/usr/sbin/yum-complete-transaction").must_exist
    end
  end

  describe "asked to install nslookup" do
    it "installs the package bind-utils" do
      package("bind-utils").must_be_installed
      file("/usr/bin/nslookup").must_exist
    end
  end

  describe "asked to install mysqldump" do
    it "installs the package mysql" do
      package("mysql").must_be_installed
      file("/usr/bin/mysqldump").must_exist
    end
  end

  describe "asked to install devel package matching mysqldump" do
    it "installs the package mysql-devel" do
      package("mysql-devel").must_be_installed
    end
  end

  describe "asked to require non-esistant binary" do
    it "raises an exception (which sets a test flag)" do
      node[:unix_bin_test][:action_require_passed] == true
    end
  end

  describe "asked to install zsh only if bash was not installed" do
    it "should not have installed zsh" do
      package("zsh").wont_be_installed
    end
  end

end