package GitPM::Display;

#*******************************************************************************
#-------------------------------------------------------------------------------
# Imports
#-------------------------------------------------------------------------------

use strict;
use warnings;

#-------------------------------------------------------------------------------

use constant {

  # Boolean syntactic sugar
  TRUE  => 1,
  FALSE => 0,

  # Settings
  VERBOSE => 'verbose',
  DEBUG   => 'debug',
};

#*******************************************************************************
#-------------------------------------------------------------------------------
# Globals
#-------------------------------------------------------------------------------

our ( $VERSION );    #, @ISA, @EXPORT, @EXPORT_OK );

$VERSION = '0.1';

# require Exporter;

# @ISA = qw(Exporter);

# @EXPORT    = qw();
# @EXPORT_OK = qw();

#*******************************************************************************
#-------------------------------------------------------------------------------
# Constructor
#-------------------------------------------------------------------------------

sub new {
  my ( $class, %config ) = @_;

  my $self = {};  
  bless( $self, $class );
  
  $self->set_verbose( $config{ &VERBOSE } );
  $self->set_debug( $config{ &DEBUG } );

  return $self;
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Accessors / Modifiers
#-------------------------------------------------------------------------------

sub is_verbose {
  my ( $self ) = @_;
  return $self->{ &VERBOSE } || $self->is_debug();
}

#-------------------------------------------------------------------------------

sub set_verbose {
  my ( $self, $flag ) = @_;

  $self->{ &VERBOSE } = $flag;
}

#-------------------------------------------------------------------------------

sub is_debug {
  my ( $self ) = @_;
  return $self->{ &DEBUG };
}

#-------------------------------------------------------------------------------

sub set_debug {
  my ( $self, $flag ) = @_;

  $self->{ &DEBUG } = $flag;
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Display functions
#-------------------------------------------------------------------------------

sub normal {
  my ( $self, @text ) = @_;

  # If no input given, assume newline.
  unless ( @text ) {
    print "\n";
    return;
  }
  
  my $spacer = '';

  if ( $self->is_debug() ) {
    print "\n";
    $spacer = '  ';
  }

  # Print all lines.
  foreach my $line ( @text ) {
    print $spacer . $line . "\n";
  }
}

#-------------------------------------------------------------------------------

sub verbose {
  my ( $self, @text ) = @_;
  my ( $package, $filename, $line ) = caller;

  # Only print if debug or verbose flag was set.
  if ( $self->is_verbose() ) {
    
    if ( $self->is_debug() ) {
      $package = ( $package ? $package : '' );
      $self->normal( "\nVERBOSE : $package [ '$filename' ( $line ) ]" );  
    }
    
    $self->normal( @text );
  }
}

#-------------------------------------------------------------------------------

sub debug {
  my ( $self, @text ) = @_;
  my ($package, $filename, $line) = caller;

  # Only print if debug flag was set.
  if ( $self->is_debug() ) {
    $package = ( $package ? $package : '' );
    
    $self->normal( "\nDEBUG : $package [ '$filename' ( $line ) ]" );
    $self->normal( @text );
  }
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Utilities
#-------------------------------------------------------------------------------

sub dump {
  my ( $self, $data, $spacer ) = @_;
  
  if ( ! defined $data ) {
    return ( $spacer . '<UNDEFINED>' );
  }  
  elsif ( ref $data eq 'HASH' ) {
    return $self->dump_hash( $data, $spacer );
  }
  elsif ( ref $data eq 'ARRAY' ) {
    return $self->dump_array( $data, $spacer );
  }
  elsif ( ! ref $data ) {
    return ( $spacer . $data );  
  }
    
  return ( $spacer . "<UNKNOWN> ( $data )" );
}

#-------------------------------------------------------------------------------

sub dump_hash {
  my ( $self, $hash, $spacer ) = @_;
  my @values = ();
  my $max_key_length = 0;
    
  $spacer = ( defined $spacer ? $spacer : '  ' );
  
  foreach ( keys %$hash ) {
    my $key_length = length $_;
    $max_key_length = (
      $key_length > $max_key_length 
      ? $key_length 
      : $max_key_length
    );
  }
        
  while ( my ( $key, $value ) = each %$hash ) {
    
    my $variable = $spacer . sprintf "%-${max_key_length}s", $key;
    
    if ( ! defined $value ) {
      push @values, "$variable  =  <UNDEFINED>";
    }
    elsif ( ref $value eq 'HASH' ) {
      push @values, "$variable  =  $value\n";
      @values = ( @values, $self->dump_hash( $value, $spacer . '  ' ), ( '' ) );  
    }
    elsif ( ref $value eq 'ARRAY' ) {
      push @values, "$variable  =  $value\n";
      @values = ( @values, $self->dump_array( $value, $spacer . '  ' ), ( '' ) );  
    }
    elsif ( ! ref $value ) {
      push @values, "$variable  =  '$value'";  
    }
    else {
      push @values, "$variable  =  <UNKNOWN> ( $value )";  
    }
  }   
  
  return @values;
}

#-------------------------------------------------------------------------------

sub dump_array {
  my ( $self, $array, $spacer ) = @_;
  my @values = ();
  
  $spacer = ( defined $spacer ? $spacer : '  ' );
  
  my $max_index_length = length( @$array - 1 );
  
  for ( my $index = 0; $index < @$array; $index++ ) {
    
    my $element = $spacer . sprintf "[ %${max_index_length}d ]", $index;
    my $value   = $array->[ $index ]; 
    
    if ( ! defined $value ) {
      push @values, "$element  =  <UNDEFINED>";
    }
    elsif ( ref $value eq 'HASH' ) {
      push @values, "$element  =  $value\n";
      @values = ( @values, $self->dump_hash( $value, $spacer . '  ' ), ( '' ) );  
    }
    elsif ( ref $value eq 'ARRAY' ) {
      push @values, "$element  =  $value\n";
      @values = ( @values, $self->dump_array( $value, $spacer . '  ' ), ( '' ) );  
    }
    elsif ( ! ref $value ) {
      push @values, "$element  =  '$value'";  
    }
    else {
      push @values, "$element  =  <UNKNOWN> ( $value )";  
    }    
  }
  
  return @values;
}

#-------------------------------------------------------------------------------

sub dump_if_verbose {
  my ( $self, $data, $spacer ) = @_;
  my @values = ();
  
  if ( $self->is_verbose() ) {    
    push @values, $self->dump( $data, $spacer );
  }
  
  return @values;
}

#-------------------------------------------------------------------------------

sub dump_if_debug {
  my ( $self, $data, $spacer ) = @_;
  my @values = ();
  
  if ( $self->is_debug() ) {
    push @values, $self->dump( $data, $spacer );
  }
  
  return @values;
}

#-------------------------------------------------------------------------------

# Return true.
1;
