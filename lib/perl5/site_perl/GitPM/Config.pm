package GitPM::Config;

#*******************************************************************************
#-------------------------------------------------------------------------------
# Imports
#-------------------------------------------------------------------------------

use strict;
use warnings;

use Data::Dump qw( dump );

use GitPM::Display;

#-------------------------------------------------------------------------------

use constant {

  # Boolean syntactic sugar
  TRUE  => 1,
  FALSE => 0,

  # Public properties ( hash keys )
  PATH      => 'path',
  FILE_NAME => 'file_name',

  DISPLAY => 'display',

  # Internal properties ( hash keys )
  INITIALIZED => 'initialized',
  
  SETTINGS => 'settings',

  NAMED_MAP => 'named_map',
  DATA      => 'data',
};

#*******************************************************************************
#-------------------------------------------------------------------------------
# Globals
#-------------------------------------------------------------------------------

our ( $VERSION );    #, @ISA, @EXPORT, @EXPORT_OK );

$VERSION = '0.1';

# require Exporter;
#
# @ISA = qw(Exporter);
#
# @EXPORT    = qw();
# @EXPORT_OK = qw();

#*******************************************************************************
#-------------------------------------------------------------------------------
# Constructor
#-------------------------------------------------------------------------------

sub new {
  my ( $class, %config ) = @_;

  my $self = {
    &SETTINGS => {
      &NAMED_MAP => {},
      &DATA      => {},
    },
  };

  bless( $self, $class );

  $self->set_display(
    (
        $config{ &DISPLAY }
      ? $config{ &DISPLAY }
      : GitPM::Display->new( %config )
    )
  );

  $self->set_path( $config{ &PATH } );
  $self->set_file_name( $config{ &FILE_NAME } );

  return $self;
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Accessor / Modifiers
#-------------------------------------------------------------------------------

sub display {
  my ( $self ) = @_;
  return $self->{ &DISPLAY };
}

#-------------------------------------------------------------------------------

sub set_display {
  my ( $self, $display ) = @_;

  $self->{ &DISPLAY } = $display;

  $display->debug( 'Resetting Package display object.' );
}

#-------------------------------------------------------------------------------

sub file_name {
  my ( $self ) = @_;
  return $self->{ &FILE_NAME };
}

#-------------------------------------------------------------------------------

sub set_file_name {
  my ( $self, $file_name ) = @_;

  $self->{ &FILE_NAME } = $file_name;
}

#-------------------------------------------------------------------------------

sub path {
  my ( $self ) = @_;
  return $self->{ &PATH };
}

#-------------------------------------------------------------------------------

sub set_path {
  my ( $self, $path ) = @_;
  my $display = $self->display();

  $path = ( $path ? $path : '' );

  # Check if the path ends with a trailing slash.
  unless ( !$path || $path =~ /\/$/ ) {
    $path .= '/';
  }

  $self->{ &PATH } = $path;

  $display->debug( 'Setting path to : ' . $self->path() );
}

#-------------------------------------------------------------------------------

sub file {
  my ( $self ) = @_;
  return $self->path() . $self->file_name();
}

#-------------------------------------------------------------------------------

sub is_named {
  my ( $self, $section ) = @_;
  
  $self->initialize();
  
  return $self->{ &SETTINGS }{ &NAMED_MAP }{ $section };
}

#-------------------------------------------------------------------------------

# INTERNAL USE ONLY.

sub set_named {
  my ( $self, $section ) = @_;

  $self->{ &SETTINGS }{ &NAMED_MAP }{ $section } = TRUE;
}

#-------------------------------------------------------------------------------

# INTERNAL USE ONLY.

sub remove_named {
  my ( $self, $section ) = @_;

  delete $self->{ &SETTINGS }{ &NAMED_MAP }{ $section };
}

#-------------------------------------------------------------------------------

sub settings {
  my ( $self, $section, $name ) = @_;
  
  $self->initialize();

  my $data = $self->{ &SETTINGS }{ &DATA };

  if ( $section ) {
    if ( $name && $self->is_named( $section ) ) {
      if ( wantarray ) {
        return sort keys %{ $data->{ $section }{ $name } };
      }
      return $data->{ $section }{ $name };
    }

    if ( wantarray ) {
      return sort keys %{ $data->{ $section } };
    }
    return $data->{ $section };
  }

  if ( wantarray ) {
    return sort keys %$data;
  }
  return $data;
}

#-------------------------------------------------------------------------------

sub clear_settings {
  my ( $self ) = @_;

  $self->{ &SETTINGS }{ &DATA }      = {};
  $self->{ &SETTINGS }{ &NAMED_MAP } = {};
}

#-------------------------------------------------------------------------------

sub core_setting {
  my ( $self, $section, $variable ) = @_;
  
  $self->initialize();
  
  return $self->{ &SETTINGS }{ &DATA }{ $section }{ $variable };
}

#-------------------------------------------------------------------------------

sub set_core_setting {
  my ( $self, $section, $variable, $value ) = @_;
  
  $self->initialize();
  
  if ( ref $variable eq 'HASH' ) {

    # If value is true, then overwrite existing variables.
    if ( $value ) {
      $self->{ &SETTINGS }{ &DATA }{ $section } = $variable;
    }

    # Else, set specified variables to values given.
    else {
      while ( my ( $key, $value ) = each %$variable ) {
        $self->{ &SETTINGS }{ &DATA }{ $section }{ $key } = $value;
      }
    }
  }

  # Set specified valiable to this value.
  else {
    $self->{ &SETTINGS }{ &DATA }{ $section }{ $variable } = $value;
  }
}

#-------------------------------------------------------------------------------

sub remove_core_setting {
  my ( $self, $section, $variable ) = @_;
  my $keep_section = FALSE;

  $self->initialize();

  if ( $variable ) {
    delete $self->{ &SETTINGS }{ &DATA }{ $section }{ $variable };

    if ( keys %{ $self->{ &SETTINGS }{ &DATA }{ $section } } ) {
      $keep_section = TRUE;
    }
  }

  unless ( $keep_section ) {
    delete $self->{ &SETTINGS }{ &DATA }{ $section };

    # remove_named_setting() calls this function.
    $self->remove_named( $section );
  }
}

#-------------------------------------------------------------------------------

sub named_setting {
  my ( $self, $section, $name, $variable ) = @_;
  
  $self->initialize();
  
  return $self->{ &SETTINGS }{ &DATA }{ $section }{ $name }{ $variable };
}

#-------------------------------------------------------------------------------

sub set_named_setting {
  my ( $self, $section, $name, $variable, $value ) = @_;

  $self->initialize();

  if ( ref $variable eq 'HASH' ) {

    # If value is true, then overwrite existing variables.
    if ( $value ) {
      $self->{ &SETTINGS }{ &DATA }{ $section }{ $name } = $variable;
    }

    # Else, set specified variables to values given.
    else {
      while ( my ( $key, $value ) = each %$variable ) {
        $self->{ &SETTINGS }{ &DATA }{ $section }{ $name }{ $key } = $value;
      }
    }
  }

  # Set specified valiable to this value.
  else {
    $self->{ &SETTINGS }{ &DATA }{ $section }{ $name }{ $variable } = $value;
  }

  $self->set_named( $section );
}

#-------------------------------------------------------------------------------

sub remove_named_setting {
  my ( $self, $section, $name, $variable ) = @_;
  my ( $keep_name, $keep_section );

  $self->initialize();

  if ( $variable ) {
    delete $self->{ &SETTINGS }{ &DATA }{ $section }{ $name }{ $variable };

    if ( keys %{ $self->{ &SETTINGS }{ &DATA }{ $section }{ $name } } ) {
      $keep_name    = TRUE;
      $keep_section = TRUE;
    }
  }

  if ( $name && !$keep_name ) {
    delete $self->{ &SETTINGS }{ &DATA }{ $section }{ $name };

    if ( keys %{ $self->{ &SETTINGS }{ &DATA }{ $section } } ) {
      $keep_section = TRUE;
    }
  }

  unless ( $keep_section ) {
    $self->remove_core_setting( $section );
  }
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# File storage
#-------------------------------------------------------------------------------

# INTERNAL USE ONLY.

sub initialize {
  my ( $self ) = @_;
  
  if ( ! $self->{ &INITIALIZED } ) {
    $self->load();
  }
}

#-------------------------------------------------------------------------------

sub load {
  my ( $self ) = @_;
  my $display = $self->display();

  $display->verbose( 'Loading configuration file : ' . $self->file() );

  # Import package section configurations.
  unless ( open( HANDLE, $self->file() ) ) {
    $display->debug( 'File open failed with error : ' . $! );
    return;
  }
  $display->debug( 'File opened successfully.' );

  $self->clear_settings();

  my ( $section, $name );

  while ( <HANDLE> ) {
    s/\s*//g;
    next unless ( $_ );

    if ( /^\[([^"\]]+)"?([^"\]]+)*"?\]$/ ) {
      $section = $1;
      $name    = $2;

      $display->debug(
        "Loading section : $section" . ( $name ? " [ $name ]" : '' ) );
    }
    elsif ( $section ) {
      my ( $variable, $value ) = split( /\=/ );

      $display->debug( "Setting variable [ $variable ] to value [ $value ]" );

      if ( $name ) {
        $self->set_named_setting( $section, $name, $variable, $value );
      }
      else {
        $self->set_core_setting( $section, $variable, $value );
      }
    }
  }
  
  $self->{ &INITIALIZED } = TRUE;

  $display->verbose( 'Configuration file loaded successfully.' );
  close( HANDLE );
}

#-------------------------------------------------------------------------------

sub store {
  my ( $self ) = @_;

  my $display = $self->display();

  my $file     = $self->file();
  my @sections = $self->settings();

  if ( !@sections ) {
    $display->verbose( "Removing configuration file : $file" );
    unlink $file;
    return;
  }

  $display->verbose( "Writing configuration file : $file" );
  open( HANDLE, ">$file" ) or die $!;

  $display->debug( "File opened successfully." );

  # Always write in same order. (for versioning)
  foreach my $section ( @sections ) {

    if ( $self->is_named( $section ) ) {
      foreach my $name ( $self->settings( $section ) ) {
        print HANDLE "[$section \"$name\"]\n";

        foreach my $variable ( $self->settings( $section, $name ) ) {
          my $value = $self->named_setting( $section, $name, $variable );
          print HANDLE "  $variable = $value\n";
        }
      }
    }
    else {
      print HANDLE "[$section]\n";

      foreach my $variable ( $self->settings( $section ) ) {
        my $value = $self->core_setting( $section, $variable );
        print HANDLE "  $variable = $value\n";
      }
    }
  }
  $display->verbose( 'Configuration file stored successfully.' );
  close( HANDLE );
}

#-------------------------------------------------------------------------------

# Return true.
1;
