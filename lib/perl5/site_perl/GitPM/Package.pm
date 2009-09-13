package GitPM::Package;

#*******************************************************************************
#-------------------------------------------------------------------------------
# Imports
#-------------------------------------------------------------------------------

use strict;
use warnings;

use Git;

use GitPM::Display;
use GitPM::Config;

#-------------------------------------------------------------------------------

use constant {

  # Boolean syntactic sugar
  TRUE  => 1,
  FALSE => 0,

  # Files
  PACKAGE_FILE_NAME => '.gitpackage',

  # Public properties ( hash keys )
  REPOSITORY => 'repository',

  DISPLAY => GitPM::Config::DISPLAY,

  # Dependency variables
  VAR_URL    => 'url',
  VAR_PATH   => 'path',
  VAR_BRANCH => 'branch',
  VAR_COMMIT => 'commit',

  # Default values ( hash values )
  BRANCH_MASTER => 'master',
  COMMIT_HEAD   => 'HEAD',

  # Internal properties ( hash keys )
  CONFIG     => 'config',
  DEPENDENCY => 'dependency',
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

  # Pass package config file name into the Config constructor.
  $config{ GitPM::Config::FILE_NAME } = PACKAGE_FILE_NAME;

  my $self = { CONFIG => GitPM::Config->new( %config ) };
  bless( $self, $class );

  $self->set_repository( $config{ REPOSITORY } );

  return $self;
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Accessor / Modifiers
#-------------------------------------------------------------------------------

sub display {
  my ( $self ) = @_;
  return $self->{ CONFIG }->display();
}

#-------------------------------------------------------------------------------

sub set_display {
  my ( $self, $display ) = @_;
  $self->{ CONFIG }->set_display( $display );
}

#-------------------------------------------------------------------------------

sub repository {
  my ( $self ) = @_;
  return $self->{ REPOSITORY };
}

#-------------------------------------------------------------------------------

sub set_repository {
  my ( $self, $repository ) = @_;

  $self->{ REPOSITORY } = $repository;
  $self->{ CONFIG }->set_path( $repository->wc_path() );
}

#-------------------------------------------------------------------------------

sub package_file {
  my ( $self ) = @_;
  return $self->{ CONFIG }->file();
}

#-------------------------------------------------------------------------------

sub dependencies {
  my ( $self ) = @_;
  return $self->{ CONFIG }->settings( DEPENDENCY );
}

#-------------------------------------------------------------------------------

sub dependency {
  my ( $self, $path ) = @_;
  return $self->{ CONFIG }->settings( DEPENDENCY, $path );
}

#-------------------------------------------------------------------------------

sub dependency_setting {
  my ( $self, $path, $variable ) = @_;
  return $self->{ CONFIG }->named_setting( DEPENDENCY, $path, $variable );
}

#-------------------------------------------------------------------------------

sub set_dependency {
  my ( $self, $repo_url, %config ) = @_;

  my $path = (
      $config{ VAR_PATH }
    ? $config{ VAR_PATH }
    : $self->parse_path( $repo_url )
  );

  $self->{ CONFIG }->set_named_setting( DEPENDENCY,
    $path,
    {
      VAR_URL    => $repo_url,
      VAR_PATH   => $path,
      VAR_BRANCH => (
          $config{ VAR_BRANCH }
        ? $config{ VAR_BRANCH }
        : BRANCH_MASTER
      ),

      VAR_COMMIT => (
          $config{ VAR_COMMIT }
        ? $config{ VAR_COMMIT }
        : COMMIT_HEAD
      ),
    },
    TRUE
  );
}

#-------------------------------------------------------------------------------

sub remove_dependencies {
  my ( $self, @paths ) = @_;

  foreach my $path ( @paths ) {
    $self->{ CONFIG }->remove_named_setting( DEPENDENCY, $path );
  }
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Display
#-------------------------------------------------------------------------------

sub render_dependency_list {
  my ( $self ) = @_;

  my $display        = $self->display();
  my $display_length = 0;

  my @packages = $self->dependencies();

  foreach my $package ( @packages ) {
    my $package_length = length $package;

    $display_length = (
        $package_length > $display_length
      ? $package_length
      : $display_length
    );
  }

  if ( @packages ) {
    $display->normal();

    foreach my $package ( @packages ) {
      my $variables = $self->dependency( $package );
      my $repo_url  = $variables->{ VAR_URL };

      $display->normal( sprintf " %-${display_length}s  [  %s  ]",
        $package, $repo_url );
      $display->normal();

      while ( my ( $variable, $value ) = each %$variables ) {
        $display->normal( sprintf " %${display_length}s     %s = %s",
          '', $variable, $value );
      }

      $display->normal();
    }
  }
  else {
    $display->normal( 'No dependencies registered.' );
  }
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# File storage
#-------------------------------------------------------------------------------

sub load {
  my ( $self ) = @_;
  $self->{ CONFIG }->load();
}

#-------------------------------------------------------------------------------

sub store {
  my ( $self ) = @_;
  $self->{ CONFIG }->store();
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Git dependent
#-------------------------------------------------------------------------------

sub commit_package_file {
  my ( $self, $message ) = @_;
  my $repo = $self->{ REPOSITORY };

  # Add the package file to the staged changes.
  $repo->command( 'add', $self->package_file() );

  # Commit changes.
  if ( $message ) {
    $repo->command( 'commit', "-m $message" );
  }
  else {

    # Run this through system, since it is an interactive command.
    system( 'git commit' );
  }
}

#*******************************************************************************
#-------------------------------------------------------------------------------
# Utilities
#-------------------------------------------------------------------------------

sub parse_path {
  my ( $self, $repo_url ) = @_;
  my @repo_parts = split( /\//, $repo_url );

  # Remove everything but the file name.
  my $path = pop( @repo_parts );

  # Remove anything before the last dash in the file name.
  $path =~ s/^([^-]*-)*//;

  # Remove the git extension from the file.
  $path =~ s/\.git$//i;

  # Replace dot separators with forward slashes.
  $path =~ s/\./\//g;

  return $path;
}

#-------------------------------------------------------------------------------

# Return true.
1;
