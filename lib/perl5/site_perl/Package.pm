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
  REPO_PATH    => 'repo_path',
  PACKAGE_FILE => 'package_file',

  DISPLAY => 'display',

  SETTINGS  => 'settings',
  NAMED_MAP => 'named_map',
  DATA      => 'data',

  DEPENDENCY_MAP => 'dependency',
};

require Exporter;

use Display;

#*******************************************************************************
#-------------------------------------------------------------------------------
# Globals
#-------------------------------------------------------------------------------

our ( $VERSION, @ISA, @EXPORT, @EXPORT_OK );

$VERSION = '0.1';

#@ISA = qw(Exporter);

#@EXPORT    = qw();
#@EXPORT_OK = qw();

#*******************************************************************************
#-------------------------------------------------------------------------------
# Constructor
#-------------------------------------------------------------------------------

sub new {
  my ( $class, %config ) = @_;

  my $self = {
    SETTINGS => {
      NAMED_MAP => {},
      DATA      => {},
    },
  };

  bless( $self, $class );

  $self->set_display(
    ( $config{ DISPLAY } ? $config{ DISPLAY } : Display->new( %config ) ) );

  $self->set_repository_path(
    ( $config{ REPO_PATH } ? $config{ REPO_PATH } : '' ) );

  return $self;
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Accessor / Modifiers
#-------------------------------------------------------------------------------

sub display {
  my ( $self ) = @_;
  return $self->{ DISPLAY };
}

#-------------------------------------------------------------------------------

sub set_display {
  my ( $self, $display ) = @_;

  $self->{ DISPLAY } = $display;

  $display->debug( 'Resetting Package display object.' );
}

#-------------------------------------------------------------------------------

sub repository_path {
  my ( $self ) = @_;
  return $self->{ REPO_PATH };
}

#-------------------------------------------------------------------------------

sub package_file {
  my ( $self ) = @_;
  return $self->{ PACKAGE_FILE };
}

#-------------------------------------------------------------------------------

sub set_repository_path {
  my ( $self, $repo_path ) = @_;
  my $display = $self->display();

  # Check if the path ends with a trailing slash.
  unless ( !$repo_path || $repo_path =~ /\/$/ ) {
    $repo_path .= '/';
  }

  $self->{ REPO_PATH }    = $repo_path;
  $self->{ PACKAGE_FILE } = $repo_path . PACKAGE_FILE_NAME;

  $display->debug( 'Setting package file to : ' . $self->package_file() );
}

#-------------------------------------------------------------------------------

sub is_named {
  my ( $self, $section ) = @_;
  return $self->{ SETTINGS }{ NAMED_MAP }{ $section };
}

#-------------------------------------------------------------------------------

sub settings {
  my ( $self, $section, $name ) = @_;

  my $data = $self->{ SETTINGS }{ DATA };

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

  $self->{ SETTINGS }{ DATA }      = {};
  $self->{ SETTINGS }{ NAMED_MAP } = {};
}

#-------------------------------------------------------------------------------

sub set_setting {
  my ( $self, $section, $variable, $value ) = @_;

  $self->{ SETTINGS }{ DATA }{ $section }{ $variable } = $value;
}

#-------------------------------------------------------------------------------

sub set_named_setting {
  my ( $self, $section, $name, $variable, $value ) = @_;

  $self->{ SETTINGS }{ DATA }{ $section }{ $name }{ $variable } = $value;
  $self->{ SETTINGS }{ NAMED_MAP }{ $section } = TRUE;
}

#-------------------------------------------------------------------------------

sub remove_settings {
  my ( $self, $section, $variable ) = @_;
  my $keep_section = FALSE;

  if ( $variable ) {
    delete $self->{ SETTINGS }{ DATA }{ $section }{ $variable };

    if ( keys %{ $self->{ SETTINGS }{ DATA }{ $section } } ) {
      $keep_section = TRUE;
    }
  }

  unless ( $keep_section ) {
    delete $self->{ SETTINGS }{ DATA }{ $section };
    delete $self->{ SETTINGS }{ NAMED_MAP }{ $section };
  }
}

#-------------------------------------------------------------------------------

sub remove_named_settings {
  my ( $self, $section, $name, $variable ) = @_;
  my ( $keep_name, $keep_section );

  if ( $variable ) {
    delete $self->{ SETTINGS }{ DATA }{ $section }{ $name }{ $variable };

    if ( keys %{ $self->{ SETTINGS }{ DATA }{ $section }{ $name } } ) {
      $keep_name = TRUE;
    }
  }

  if ( $name && !$keep_name ) {
    delete $self->{ SETTINGS }{ DATA }{ $section }{ $name };

    if ( keys %{ $self->{ SETTINGS }{ DATA }{ $section } } ) {
      $keep_section = TRUE;
    }
  }

  unless ( $keep_section ) {
    $self->remove_settings( $section );
  }
}

#-------------------------------------------------------------------------------

sub dependencies {
  my ( $self ) = @_;
  my $dependencies = $self->settings( DEPENDENCY_MAP );

  if ( wantarray ) {
    return sort keys %$dependencies;
  }

  return $dependencies;
}

#-------------------------------------------------------------------------------

sub add_dependency {
  my ( $self, $repo_url, %config ) = @_;

  # TODO
}

#-------------------------------------------------------------------------------

sub remove_dependency {
  my ( $self, $repo_path ) = @_;

  # TODO
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# File storage
#-------------------------------------------------------------------------------

sub load {
  my ( $self ) = @_;
  my $display = $self->display();

  $self->clear_settings();

  $display->verbose( 'Loading package file : ' . $self->package_file() );

  # Import package section configurations.
  unless ( open( HANDLE, $self->package_file() ) ) {
    $display->debug( 'Package file open failed with error : ' . $! );
    return;
  }
  $display->debug( 'Package file opened successfully.' );

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
        $self->set_setting( $section, $variable, $value );
      }
    }
  }

  $display->verbose( 'Dependencies loaded successfully.' );
  close( HANDLE );
}

#-------------------------------------------------------------------------------

sub store {
  my ( $self ) = @_;

  my $display = $self->display();

  my $package_file = $self->package_file();
  my @sections     = $self->settings();

  if ( !@sections ) {
    $display->verbose( "Removing package file : $package_file" );
    unlink $package_file;
    return;
  }

  $display->verbose( "Writing package file : $package_file" );
  open( HANDLE, ">$package_file" ) or die $!;

  $display->debug( "Package file opened successfully." );

  # Always write in same order. (for versioning)
  foreach my $section ( @sections ) {

    if ( $self->is_named( $section ) ) {
      foreach my $name ( @{ $self->settings( $section ) } ) {
        my $variables = $self->settings( $section, $name );

        print HANDLE "[$section \"$name\"]\n";

        # TODO

      }
    }
    else {

      # TODO
    }
  }
  $display->verbose( 'Dependencies saved successfully.' );
  close( HANDLE );
}

#-------------------------------------------------------------------------------

# Return true.
1;
