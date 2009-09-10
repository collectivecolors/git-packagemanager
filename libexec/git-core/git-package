#!/usr/bin/perl

# Git package manager plugin.
#
# Command syntax
#-----------------
#
# git-package add [ -c | --commit ] [ -m | --message {message} ] [ -d | --dir {source_directory} ] {repository} ...
#             list
#             update [ -c | --commit ] [ -m | --message {message} ] [ -R | --recursive ] [ {path} ... ]
#             remove [ -c | --commit ] [ -m | --message {message} ] [ -R | --recursive ] [ {path} ... ]
#
# Description
#--------------
#
#  This git command provides a package manager interface to the git submodule
#  command structure.  Packages are libraries that are included in application
#  source directories.  Some packages depend upon other packages.  But the 
#  packages that are depended upon do not reside in a sub directory of the
#  original package.  Packages are treated as submodules, but due to limitations
#  with the handling of dependencies in the submodule commands, this command
#  library was written.
#
# Command overview
#
# [ add {repository} [ {source_directory} ] ]
#
#  The add package command includes a git package in your application source
#  directory.  As the package is added and pulled, this script checks if a 
#  .gitpackage file exists, and if so, adds and pulls all of the dependent
#  packages into the source directory.  It performs this add in a recursive
#  manner until all dependent packages have been added and pulled.  After it
#  pulls all of the packages needed by the specified package, it initializes
#  the submodules.
#
#    Parameters
#    ------------
#    1. {repository}       - Url or path of the git submodule repository.
#    2. {source_directory} - Optional source directory to create packages under.
#
# [ list ]
#
#  The list package command lists all of the packages currently included in the
#  git repository.
#
# [ update [ -R --recursive ] [ {repository} ... ] ]
#
#   The update package command pulls the latest changes of the included
#   git packages into the application source. 