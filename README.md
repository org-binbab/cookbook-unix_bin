# unix_bin cookbook

Cookbook for Opscode Chef.

http://community.opscode.com/cookbooks/unix_bin


## Description

Provides LWRPs for installing/requiring unix command-line executables,
without needing to know or specify the OS package that provides it.

For supported platforms and operating systems, see below.


## Example Usage

### You want an executable whose package doesn't match its name

Ex. we want **nslookup** (which is really provided by _bind-utils_)

    unix_bin "nslookup" do
      action :install
    end

    ##--  instead of  --##

    package "bind-utils" do
      action :install
    end

### The package name is different between operating systems

Ex. we want **mysqldump** (which can be in _mysql_ or _mysql-client_ depending)

    unix_bin "mysqldump" do
      action :install
    end

    ##--  instead of  --##

    case node[:platform]
      when "ubuntu","debian"
        package "mysql-client" do
          action :install
        end
      when "centos"
        package "mysql" do
          action :install
        end
      end
    end

### You want the "mail" command and don't care where it comes from

The **sendmail** binary could come from _postfix_, _sendmail_, or _exim_.
Demanding a specific package is an unnecessary headache if any of them meet your needs.

You can specify a default preference if the command is missing,
or the first package offered will be selected automatically

    # Install sendmail, only if no mail command already installed.

    unix_bin "mail" do
      action :install
      package "sendmail"     # OPTIONAL, default preference
    end


    ##--  instead of  --##


    # Assuming sendmail, causing your recipe to fail on exim or postfix.

    package "sendmail" do
      action :install
    end

    # Assuming the path is the same across all operating systems,
    # and with more verbose code.

    package "sendmail" do
      action :install
      not_if { ::File.exists?("/usr/sbin/sendmail") }
    end


### You want to require any "java", but not attempt to install it.

Since java can come from many sources, requiring a package is problematic.
In this case your recipe will error out at runtime if java is not installed.

    unix_bin "java" do
      action :require
    end

    ##--  instead of  --##

    extend ::Chef::Mixin::ShellOut
    shell_out!("/usr/bin/which mail")

Your cookbook's user can solve the requirement by adding a Java recipe to the server's run_list,
or by installing manually via the operating system.


## Rationale and Benefits

**Increased portability**

An install action works in any OS this cookbook does, even if the required package is different.

**Increased readability**

Clarity in what resource you need even if the executable is part of a larger package.

**Simplified cookbook prep**

Ensure the command-line tools you need are in-place, and optionally try to install missing ones, without extensive
testing and/or causing more obscure errors later in your recipe.


## LWRP Documentation

### Requiring an executable

An exception will be raised if the executable is not available, no attempt will be made to install it.
(**This is the default action.**)

As an example, we want to ensure **ifconfig** is available.

    unix_bin "ifconfig"

If you don't want to require the executable be available in the system's shell PATH, but are satisfied with it only
being installed (in one of the configured paths), you can use:

    unix_bin "ifconfig"
      action :require
      in_shell_path false
    end

### Installing an executable (if it is missing)

This also requires the executable in general, so a failure to install will lead to an exception.

Say we want to use the **convert** utility, which is actually part of ImageMagick:

    unix_bin "convert"
      action :install
    end

On **redhat** platforms you can also request the matching development package be installed.
(**This generates a warning on debian.**)

    unix_bin "convert"
      action :install
      with_devel true
    end

Which would install the packages:

  * ImageMagic
  * ImageMagic-devel

### Bulk syntax

As a convenience you can also use the following helper definition:

    unix_binaries do
      install [ "nslookup", "ncat", "wget" ]
      require [ "ifconfig" ]
    end

It also accepts the `in_shell_path` and `with_devel` flags (which are applied uniformly).


## Recipes

The default recipe is not required to use the LWRPs, however adding it to your `run_list` will automatically install
any executables listed in an array under `node['unix_bin']['install']`. (**By default this list is empty.**)


## Attributes

* `node['unix_bin']['search_paths']` - An array of paths to check (non-recursively) that an executable is already installed.
* `node['unix_bin']['install']` - An array of executable names to automatically install, if the default recipe is run.


## Resource add-ons

This cookbook also provides a helper for use with `only_if` and `not_if` clauses in Chef resources.

    cookbook_file "/etc/skel/.vimrc" do
      source "vimrc"
      only_if unix_bin_available("vim")
    end


## Platforms

Compatibility is largely dependent on the underlying OS package manager.

### Current Platforms

At present **yum** and **apt** are supported -- by extension most redhat and debian distros.

There are subtleties with every operating system however, we welcome bug reports.

### Future Platforms

Support is already planned for zypper and thereby OpenSUSE and SLED.

Feel free to open a ticket (see below) to request any platforms that are missing.


## Test-Kitchen

This package is **test-kitchen** enabled and automatically tested against:

- CentOS 5 and 6
- Ubuntu 10 and 12

## Detection method

Testing whether or not an executable is available is consistent across each OS.

The executable is determined to be **INSTALLED** if it exists in one of the paths specified in the configuration
`node['unix_bin']['search_paths']`, which defaults to: `/usr/bin : /usr/sbin : /bin : /sbin`.

It is determined to be **AVAILABLE** if it can be invoked from the system's shell PATH.

By default the `:require` action ensures that a given executable be AVAILABLE, but this can be changed.

However, no attempt will be made to install an executable that is either AVAILABLE or INSTALLED.

As such, if you :install an excutable that is installed in a search path, but not available via the shell PATH,
an exception will be raised (unless the `in_shell_path` attribute is false).


## Development and Maintenance

* Found a bug?
* Need some help?
* Have a suggestion?
* Want to contribute?

Please visit: [code.binbab.org](http://code.binbab.org)


## Authors and License

  * Author:: BinaryBabel OSS (<projects@binarybabel.org>)
  * Copyright:: 2013 `sha1(OWNER) = df334a7237f10846a0ca302bd323e35ee1463931`
  * License:: Apache License, Version 2.0

----

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
