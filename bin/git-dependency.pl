#!/usr/bin/perl

# Git package manager plugin.
#
# Command syntax
#-----------------
#
# git-dependency add [ -c | --commit ] [ -m | --message {message} ] {repository} ...
#                list
#                remove [ -c | --commit ] [ -m | --message {message} ] [ {path} ... ]
#
# Repository files
#-------------------
#
# .gitpackage
#
#  Contains package information for the repository.
#
#  [dependency "dependency/path"]
#    url = ??/repository.git
#    path = dependency/path
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
# [ add {repository} ]
#
#  The add dependency command includes a git package in your application source
#  directory.  As the package is added and pulled, this script checks if a 
#  .gitpackage file exists, and if so, adds and pulls all of the dependent
#  packages into the source directory.  It performs this add in a recursive
#  manner until all dependent packages have been added and pulled.  After it
#  pulls all of the packages needed by the specified package, it initializes
#  the submodules.
#
#    Parameters
#    ------------
#    1. {repository} - Url or path of the git submodule repository.
#
# [ list ]
#
#  The list package command lists all of the packages currently included in the
#  git repository.
#
# [ remove [ {path} ... ] ]
#
#   The remove dependency command removes a dependency from this submodule 
#   repository.

#*******************************************************************************
#-------------------------------------------------------------------------------
# Command imports
#-------------------------------------------------------------------------------

use strict;
use warnings;

use constant {
	# Boolean syntactic sugar
	TRUE       => 1,
	FALSE      => 0,
	# Commands
	CMD_ADD    => 'add',
	CMD_LIST   => 'list',
	CMD_REMOVE => 'remove',
	# Settings
	COMMAND     => 'command',
	REPO_PATH   => 'repoPath',
	VERBOSE     => 'verbose',
	COMMIT_FLAG => 'commit',
	COMMIT_MSG  => 'message',
	INPUT       => 'input',	
};

use Switch;

# CPAN modules

use Getopt::OO;

# Git modules.

use Git;

#*******************************************************************************
#-------------------------------------------------------------------------------
# Command variables
#-------------------------------------------------------------------------------

# Repository information. ( Dies if no repository! )
our $REPO = Git->repository();

# Command settings.
our %SETTINGS = (
	COMMAND    => shift @ARGV,
	PARAMETERS => \@ARGV,
	REPO_PATH  => $REPO->wc_path(),
);

#*******************************************************************************
#-------------------------------------------------------------------------------
# Command initialization
#-------------------------------------------------------------------------------

switch ($SETTINGS{COMMAND}) {
	
	case CMD_ADD {
		command_add(); # Launch dependency add command	
	}
	case CMD_LIST {
		command_list(); # Launch dependency list command
	}
	case CMD_REMOVE {
		command_remove(); # Launch dependency remove command
	}
	else {
		display_usage();	
	}	
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Command help display
#-------------------------------------------------------------------------------

sub display_usage {
	display(
		($SETTINGS{COMMAND} ? 'Invalid command specified.' 
												: 'No command specified.'),
		'',
		'Supported dependency commands :',
		'',
		' git dependency add --help',
		' git dependency list --help',
		' git dependency remove --help'
	);
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Dependency ADD command
#-------------------------------------------------------------------------------

# Command syntax
#-----------------
#
# git-dependency add
#  [ -h | --help ]
#  [ -v | --verbose ] 
#  [ -c | --commit ] 
#  [ -m | --message {message} ] 
#  {repository} ...

sub command_add {
	
	# Parse command settings.
	command_add_settings(
		Getopt::OO->new($SETTINGS{PARAMETERS}, command_add_options())
	);
	
	verbose('Starting dependency add command.');
	verbose('Repository path: ' . $SETTINGS{REPO_PATH});
	
	
				
}

#-------------------------------------------------------------------------------

sub command_add_options {
	
	my %options = (
		other_values => {
    	help => 'repository ...',
		},
	);
	
	commit_options(\%options);
	display_options(\%options);
	help_options(\%options);
	
	return %options;	
}

#-------------------------------------------------------------------------------

sub command_add_settings {
	my $parser = shift;
	
	# Abort and show help information if requested.
	parse_help_settings($parser);
	
	# Get command repositories.
	if (!@{$parser->Values('other_values')}) {
		display($parser->Help());
		exit();
	}	
	
	@{$SETTINGS{INPUT}} = $parser->Values('other_values');
	
	# Get extra command options.
	parse_display_settings($parser);
	parse_commit_settings($parser);	
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Dependency LIST command
#-------------------------------------------------------------------------------

# Command syntax
#-----------------
#
# git-dependency list
#  [ -h | --help ]
#  [ -v | --verbose ] 

sub command_list {
	
	# Parse command settings.
	command_list_settings(
		Getopt::OO->new($SETTINGS{PARAMETERS}, command_list_options())
	);
	
	verbose('Starting dependency list command.');
	verbose('Repository path: ' . $SETTINGS{REPO_PATH});
	
			
}

#-------------------------------------------------------------------------------

sub command_list_options {
	
	my %options = ();
			
	display_options(\%options);
	help_options(\%options);
		
	return %options;	
}

#-------------------------------------------------------------------------------

sub command_list_settings {
	my $parser = shift;
	
	# Get extra command options.
	parse_help_settings($parser);
	parse_display_settings($parser);
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Dependency REMOVE command
#-------------------------------------------------------------------------------

# Command syntax
#-----------------
#
# git-dependency remove
#  [ -h | --help ]
#  [ -v | --verbose ]  
#  [ -c | --commit ] 
#  [ -m | --message {message} ] 
#  [ {path} ... ]

sub command_remove {
	
	# Parse command settings.
	command_remove_settings(
		Getopt::OO->new($SETTINGS{PARAMETERS}, command_remove_options())
	);
	
	verbose('Starting dependency remove command.');
	verbose('Repository path: ' . $SETTINGS{REPO_PATH});
	
	
			
}

#-------------------------------------------------------------------------------

sub command_remove_options {
	
	my %options = (
		usage => 'git-dependency remove',
		other_values => {
        	help => 'path ...',
        },
	);
		
	commit_options(\%options);
	display_options(\%options);
	help_options(\%options);
	
	return %options;	
}

#-------------------------------------------------------------------------------

sub command_remove_settings {
	my $parser = shift;
	
	# Abort and show help information if requested.
	parse_help_settings($parser);
	
	# Get command paths.
	if (@{$parser->Values('other_values')}) {
		$SETTINGS{INPUT} = $parser->Values('other_values');
	}
	
	# Get extra command options.
	parse_display_settings($parser);
	parse_commit_settings($parser);	
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Internal utility functions
#-------------------------------------------------------------------------------

sub help_options {
	
	# Add to pre-existing options hash.
	my $options = shift;
	
	$options->{'-h'} = {
		help => 'Display help information.',	
	};
	$options->{'--help'} = {
		help => 'See information for -h option.',
	};
}

#-------------------------------------------------------------------------------

sub parse_help_settings {
	my $parser = shift;
	
	if ($parser->Values('-h') || $parser->Values('--help')) {
		display($parser->Help());
		exit();
	}	
}

#-------------------------------------------------------------------------------

sub display_options {
	
	# Add to pre-existing options hash.
	my $options = shift;
	
	$options->{'-v'} = {
       	help => 'Display more information.',
    };
    $options->{'--verbose'} = {
    	help => 'See information for -v option.',
    };	
}

#-------------------------------------------------------------------------------

sub parse_display_settings {
	my $parser = shift;
	
	unless($parser->Values()) {
		return;
	}
	
	# Parse settings.
	$SETTINGS{VERBOSE} = $parser->Values('-v') || $parser->Values('--verbose');
}

#-------------------------------------------------------------------------------

sub commit_options  {
	
	# Add to pre-existing options hash.
	my $options = shift;
	
	# Commmit flag
	$options->{'-c'} = {
		help => 'Commit after this operation.',
	};
	$options->{'--commit'} = {
		help => 'See information for -c option.'
	};
	
	# Commit message
	$options->{'-m'} = {
		help => 'See information for --message option.',
		n_values => 1,
	};
	$options->{'--message'} = {
		help => [
			'If you are commiting after this add dependency operation,',
			'you may specify the committ message.   If no commit message',
			'is given, then an editor is displayed.',
			'This is similar to the commit command.',
		],
		n_values => 1,
	};	
}

#-------------------------------------------------------------------------------

sub parse_commit_settings {
	my $parser = shift;
	
	unless ($parser->Values()) {
		return;
	}
	
	# Parse settings.
	$SETTINGS{COMMIT_FLAG} = $parser->Values('-c') 
							|| $parser->Values('--commit');
							
	if ($parser->Values('-m')) {
		$SETTINGS{COMMIT_MESSAGE} = $parser->Values('-m');
	}
	elsif ($parser->Values('--message')) {
		$SETTINGS{COMMIT_MESSAGE} = $parser->Values('--message');	
	}	
}

sub display {
	# If no input given, assume newline.
	return "\n" unless (@_);
	
	# If more than one parameter, assume multiple line text as array.
	if (@_ > 1) {
		foreach my $line (@_) {
			print $line . "\n";
		}
	}
	# If single parameter, print one line.
	else {
		print $_[0] . "\n";
	}	
}

sub verbose {
	# Only print if verbose flag was set.
	if ($SETTINGS{VERBOSE}) {
		display(@_);		
	}	
}
