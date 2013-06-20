require 'minitest/autorun'
require 'minitest/spec'
require 'chef'

client = Chef::Client.new
client.run_ohai
$platform_family = client.ohai.data[:platform_family]

def package_installed?(pkgname)
  case $platform_family
    when "rhel"
      return system("rpm --quiet -q #{pkgname}")
    when "debian"
      return system("dpkg -s #{pkgname} > /dev/null 2>&1")
    else
      raise Exception, "Unknown platform family. (#{$platform_family})"
  end
end

describe "asked to install fc-list" do
  it "installs the package fontconfig" do
    package_installed?("fontconfig").must_equal true
  end
end

describe "asked to install zsh only if bash was not installed" do
  it "should not have installed zsh" do
    package_installed?("zsh").must_equal false
  end
end

if "rhel" == $platform_family
  describe "asked to install devel package matching mysqldump" do
    it "installs the package mysql-devel" do
      package_installed?("mysql-devel").must_equal true
    end
  end
end
