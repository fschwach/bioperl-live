# $Id$

#
# BioPerl module for Bio::SearchDist
#
# Cared for by Ewan Birney <birney@sanger.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SearchDist - A perl wrapper around Sean Eddy's histogram object

=head1 SYNOPSIS

  $dis = Bio::SearchDist->new();
  foreach $score ( @scores ) {
     $dis->add_score($score);
  }

  if( $dis->fit_evd() ) {
    foreach $score ( @scores ) {
      $evalue = $dis->evalue($score);
      print "Score $score had an evalue of $evalue\n";
    }
  } else {
    warn("Could not fit histogram to an EVD!");
  }

=head1 DESCRIPTION

The Bio::SearchDist object is a wrapper around Sean Eddy's excellent
histogram object. The histogram object can bascially take in a number
of scores which are sensibly distributed somewhere around 0 that come
from a supposed Extreme Value Distribution. Having add all the scores
from a database search via the add_score method you can then fit a
extreme value distribution using ->fit_evd(). Once fitted you can then
get out the evalue for each score (or a new score) using
->evalue($score).

The fitting procedure is better described in Sean Eddy's own code
(available from http://hmmer.wustl.edu, or in the histogram.h header
file in Compile/SW). Bascially it fits a EVD via a maximum likelhood
method with pruning of the top end of the distribution so that real
positives are discarded in the fitting procedure. This comes from
an orginally idea of Richard Mott's and the likelhood fitting
is from a book by Lawless [should ref here].


The object relies on the fact that the scores are sensibly distributed
around about 0 and that integer bins are sensible for the
histogram. Scores based on bits are often ideal for this (bits based
scoring mechanisms is what this histogram object was originally
designed for).


=head1 CONTACT

The original code this was based on comes from the histogram module as
part of the HMMer2 package. Look at http://hmmer.wustl.edu/

Its use in Bioperl is via the Compiled XS extension which is cared for
by Ewan Birney (birney@sanger.ac.uk). Please contact Ewan first about
the use of this module

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org          - General discussion
  http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via email
or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::SearchDist;
use vars qw(@ISA);
use strict;

use Bio::Root::RootI;

BEGIN {
    eval {
	require Bio::Ext::Align;
    };
    if ( $@ ) {
print $@;
	print STDERR ("\nThe C-compiled engine for histogram object (Bio::Ext::Align) has not been installed.\n Please install the bioperl-ext package\n\n");
	exit(1);
    }
}


@ISA = qw(Bio::Root::RootI);

sub new {
  my($class,@args) = @_;
  my $self = $class->SUPER::new(@args);
  my($min, $max, $lump) = 
	$self->_rearrange([qw(MIN MAX LUMP)], @args);

  if( !  $min ) {
    $min = -100;
  }

  if( !  $max ) {
    $max = +100;
  }

  if( ! $lump ) {
    $lump = 50;
  }

  $self->_engine(&Bio::Ext::Align::new_Histogram($min,$max,$lump));

  return $self;
}

=head2 add_score

 Title   : add_score
 Usage   : $dis->add_score(300);
 Function: Adds a single score to the distribution
 Returns : nothing
 Args    : 


=cut

sub add_score{
   my ($self,$score) = @_;
   my ($eng);
   $eng = $self->_engine();
   #$eng->AddToHistogram($score);
   $eng->add($score);
}

=head2 fit_evd

 Title   : fit_evd
 Usage   : $dis->fit_evd();
 Function: fits an evd to the current distribution
 Returns : 1 if it fits successfully, 0 if not
 Args    :


=cut

sub fit_evd{
   my ($self,@args) = @_;

   #return $self->_engine()->ExtremeValueFitHistogram(10000);
   return $self->_engine()->fit_EVD(10000);
}

=head2 evalue

 Title   : evalue
 Usage   : $eval = $dis->evalue($score)
 Function: Returns the evalue of this score 
 Returns : float 
 Args    :


=cut

sub evalue{
   my ($self,$score) = @_;

   return $self->_engine()->evalue($score);

}



=head2 _engine

 Title   : _engine
 Usage   : $obj->_engine($newval)
 Function: underlyine bp_sw:: histogram engine
 Returns : value of _engine
 Args    : newvalue (optional)


=cut

sub _engine{
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{'_engine'} = $value;
    }
    return $self->{'_engine'};
}


## End of Package

1;
__END__

