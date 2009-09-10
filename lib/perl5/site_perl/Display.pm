package Display;

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
	
	# Settings
	VERBOSE => 'verbose',
	DEBUG   => 'debug',
};

require Exporter;

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
		VERBOSE => $config{VERBOSE},
		DEBUG   => $config{DEBUG},
	};
	
	return bless($self, $class);
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Accessors / Modifiers
#-------------------------------------------------------------------------------

sub set_verbose {
	my ($self, $flag) = @_;
	
	$self->{VERBOSE} = $flag;
}

#-------------------------------------------------------------------------------

sub set_debug {
	my ($self, $flag) = @_;
	
	$self->{DEBUG} = $flag;
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Display functions
#-------------------------------------------------------------------------------

sub normal {
	my ($self, @text) = @_;
	
	# If no input given, assume newline.
	unless (@text) {
		print "\n";
		return;
	}
	
	# If more than one parameter, assume multiple line text as array.
	if (@text > 1) {
		foreach my $line (@text) {
			print $line . "\n";
		}
	}
	# If single parameter, print one line.
	else {
		print $text[0] . "\n";
	}	
}

#-------------------------------------------------------------------------------

sub verbose {
	my ($self, @text) = @_;
	
	# Only print if verbose flag was set.
	if ($self->{VERBOSE}) {
		$self->normal(@text);		
	}	
}

#-------------------------------------------------------------------------------

sub debug {
	my ($self, @text) = @_;
	
	# Only print if debug flag was set.
	if ($self->{DEBUG}) {
		$self->normal(@text);
	}
}

#-------------------------------------------------------------------------------

# Return true.
1;
