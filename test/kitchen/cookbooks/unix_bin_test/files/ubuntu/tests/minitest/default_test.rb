require 'minitest/spec'

describe_recipe "unix_bin::default" do

  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources

  describe "asked to install vim.basic" do
    it "installs the package vim" do
      package("vim").must_be_installed
      file("/usr/bin/vim.basic").must_exist
    end
  end

  describe "asked to install ncat" do
    it "installs the package nmap" do
      package("nmap").must_be_installed
      file("/usr/bin/ncat").must_exist
    end
  end

  describe "asked to install mysqldump" do
    it "installs the file" do
      # The generic mysql-client package in ubuntu only installs mysqldump by
      # sub-requirement, so it wouldn't be installed, and the actual package
      # name can vary. So we won't test for it here.
      file("/usr/bin/mysqldump").must_exist
    end
  end

  describe "asked to require non-esistant binary" do
    it "raises an exception (which sets a test flag)" do
      node[:unix_bin_test][:action_require_passed] == true
    end
  end

end