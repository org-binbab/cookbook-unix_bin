name              "unix_bin"
maintainer        "BinaryBabel OSS"
maintainer_email  "projects@binarybabel.org"
license           "Apache License, Version 2.0"

description       "Provides LWRPs for installing/requiring unix command-line executables "\
                  "with package name auto-detection."
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version           "0.2.4"

recipe            "unix_bin", "Automatically install executable bins specified via node attribute."

supports "centos", ">= 5.0"
supports "ubuntu", ">= 10.04"
