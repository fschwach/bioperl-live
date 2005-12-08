# $Id$
#
# BioPerl module for Bio::Expression::Platform
#
# Cared for by Allen Day <allenday@ucla.edu>
#
# Copyright Allen Day
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Expression::Platform - DESCRIPTION of Object

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

Describe the object here

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org              - General discussion
  http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
the web:

  http://bugzilla.bioperl.org/

=head1 AUTHOR - Allen Day

Email allenday@ucla.edu

Describe contact details here

=head1 CONTRIBUTORS

Additional contributors names and emails here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::Expression::Platform;
use strict;
use base qw(Bio::Root::Root);

=head2 new()

 Usage   : my $obj = new Bio::Expression::Platform();
 Function: Builds a new Bio::Expression::Platform object 
 Returns : an instance of Bio::Expression::Platform
 Args    :


=cut

sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);
  $self->_initialize(@args);
  return $self;
}

=head2 _initialize()

=over

=item Usage

  $obj->_initialize(%arg);

=item Function

Internal method to initialize a new Bio::Expression::Platform object

=item Returns

true on success

=item Arguments

Arguments passed to L</new()>

=back

=cut

sub _initialize {
  my($self,%arg) = @_;

  foreach my $arg (keys %arg){
    my $marg = $arg;
    $marg =~ s/^-//;
    $self->$marg($arg{$arg}) if $self->can($marg);
  }

  return 1;
}





=head2 get_datasets()

 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub get_datasets {
  my ($self,@args) = @_;
  my $db = $self->db();

  my @datasets = $db->get_datasets( $self );

  return @datasets;
}














=head2 accession()

 Usage   : $obj->accession($newval)
 Function: 
 Example : 
 Returns : value of accession (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub accession {
  my($self,$val) = @_;
  $self->{'accession'} = $val if defined($val);
  return $self->{'accession'};
}

=head2 name()

 Usage   : $obj->name($newval)
 Function: 
 Example : 
 Returns : value of name (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub name {
  my($self,$val) = @_;
  $self->{'name'} = $val if defined($val);
  return $self->{'name'};
}

=head2 taxon()

 Usage   : $obj->taxon($newval)
 Function: 
 Example : 
 Returns : value of taxon (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub taxon {
  my($self,$val) = @_;
  $self->{'taxon'} = $val if defined($val);
  return $self->{'taxon'};
}

=head2 contact()

 Usage   : $obj->contact($newval)
 Function: 
 Example : 
 Returns : a Bio::Expression::Contact object
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub contact {
  my($self,$val) = @_;
  $self->{'contact'} = $val if defined($val);
  return $self->{'contact'};
}

=head2 db()

 Usage   : $obj->db($newval)
 Function: 
 Example : 
 Returns : value of db (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub db {
  my($self,$val) = @_;
  $self->{'db'} = $val if defined($val);
  return $self->{'db'};
}


1;