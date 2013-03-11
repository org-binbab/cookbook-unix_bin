#
# This definition is used to assign the providers to their resources.
#
# Definition files are loaded after providers and resources, but
# before recipies. (and are not run-list sensitive like receipes)
#
Chef::Platform.platforms[:centos][:default][:unix_bin_package] = Chef::Provider::UnixBinPackageYum
Chef::Platform.platforms[:ubuntu][:default][:unix_bin_package] = Chef::Provider::UnixBinPackageApt