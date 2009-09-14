package GitPM::Param;

#*******************************************************************************
#-------------------------------------------------------------------------------
# Imports
#-------------------------------------------------------------------------------

use strict;
use warnings;

use Getopt::OO;

#-------------------------------------------------------------------------------

use constant {

  # Boolean syntactic sugar
  TRUE  => 1,
  FALSE => 0,

  # Settings
  HELP => 'help',
};

#*******************************************************************************
#-------------------------------------------------------------------------------
# Globals
#-------------------------------------------------------------------------------

our ( $VERSION, @ISA ); #, @EXPORT, @EXPORT_OK );

$VERSION = '0.1';

# require Exporter;

@ISA = qw( Getopt::OO ); #, Exporter);

# @EXPORT    = qw();
# @EXPORT_OK = qw();

#*******************************************************************************
#-------------------------------------------------------------------------------
# Constructor
#-------------------------------------------------------------------------------

sub new {
  my ( $class, $argv, %template ) = @_;

  my $self = Getopt::OO->new( $argv, %template );

  return bless( $self, $class );
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Accessors / Modifiers
#-------------------------------------------------------------------------------



#*******************************************************************************
#-------------------------------------------------------------------------------
# Utilities
#-------------------------------------------------------------------------------

sub build_help {
  my ( $self, $template ) = @_;
  
  print 'Im here!';
  
  if ( $template->{ &HELP } ) {
    return $template->{ &HELP };  
  }
  return $self->SUPER::build_help;  
}

#-------------------------------------------------------------------------------

# Return true.
1;