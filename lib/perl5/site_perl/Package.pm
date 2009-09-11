package Package;

#*******************************************************************************
#-------------------------------------------------------------------------------
# Imports
#-------------------------------------------------------------------------------

use strict;
use warnings;

use constant {
	# Boolean syntactic sugar
	TRUE  => 1,
	FALSE => 0,
	
	# Files
	PACKAGE_FILE_NAME => '.gitpackage',
	
	# Properties ( hash keys )
	REPO_PATH      => 'repo_path',
	
	DISPLAY        => 'display',
	
	PACKAGE_FILE   => 'package_file',
	
	SETTINGS       => 'settings',
	SECTIONS       => 'sections',
	
	DEPENDENCY_MAP => 'dependency',
	DEFAULT_NAME   => 'default_name',
};

require Exporter;

use Display;

#*******************************************************************************
#-------------------------------------------------------------------------------
# Globals
#-------------------------------------------------------------------------------

our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);


$VERSION = '0.1';

@ISA = qw(Exporter);

@EXPORT    = qw();
@EXPORT_OK = qw();

#*******************************************************************************
#-------------------------------------------------------------------------------
# Constructor
#-------------------------------------------------------------------------------

sub new {
	my ($class, %config) = @_;
	
	my $self = {
		DISPLAY      => Display->new(%config),
		PACKAGE_FILE => ($config{REPO_PATH} ? $config{REPO_PATH} : '') 
					 					. PACKAGE_FILE_NAME,
		SETTINGS     => {},
		SECTIONS     => [],		
	};
	
	return bless($self, $class);
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Accessor / Modifiers
#-------------------------------------------------------------------------------

sub set_display {
	my ($self, $display) = @_;
	
	$self->{DISPLAY} = $display;	
}

#-------------------------------------------------------------------------------

sub dependencies {
	my ($self) = @_;
	
	if (wantarray) {
		return sort keys %{$self->{SETTINGS}{DEPENDENCY_MAP}};	
	}
	
	return $self->{SETTINGS}{DEPENDENCY_MAP};
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# File storage
#-------------------------------------------------------------------------------

sub load {
	my ($self)  = @_;
	my $display = $self->{DISPLAY};	
		
	$display->verbose('Loading package file : ' . $self->{PACKAGE_FILE});
	
	unless (open(HANDLE, $self->{PACKAGE_FILE})) {
		$display->normal('Package file open failed with error : ' . $!);
		return;	
	}
	
	$display->debug('Package file opened successfully.');
	
	# Import package section configurations.
	my ($section, $name);
	
	while (<HANDLE>) {
		
		# Strip whitespace.
		s/\s*//g;
		
		next unless ($_);
			
		if (/^\[([^"\]]+)"?([^"\]]+)*"?\]$/) {
			$section = $1;
			$name    = ($2 ? $2 : DEFAULT_NAME);
			
			$display->debug('Loading section : ' . $section . " [ $name ]");
			
			push(@{$self->{SECTIONS}}, $section);	
		}
		elsif ($section) {
				
			# Split variable and value on equals sign.
			my ($variable, $value) = split(/\=/);
			
			$display->debug("Setting variable [ $variable ]"
											. " to value [ $value ]");
			
			$self->{SETTINGS}{$section}{$name}{$variable} = $value; 
		}	
	}
	
	$display->verbose('Dependencies loaded successfully.');	
	close(HANDLE);	
}

#-------------------------------------------------------------------------------

sub store {
	my ($self) = @_;
	
}

#-------------------------------------------------------------------------------

# Return true.
1;