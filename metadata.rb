name              "unix_bin"
maintainer        "BinaryBabel OSS"
maintainer_email  "projects@binarybabel.org"
license           "Apache License, Version 2.0"

description       "Provides LWRPs for installing/requiring unix command-line executables "\
                  "with package name auto-detection."
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version           "0.2.1"

recipe            "unix_bin", "Automatically install executables specified via node attribute."

%w{centos ubuntu}.each do |os|
  supports os
end
