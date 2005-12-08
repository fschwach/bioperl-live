=head1 NAME

Bio::DB::Expression::geo - DESCRIPTION of Class

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

Describe the object here

=head1 FEEDBACK

=head2 Mailing Lists

=head2 Reporting Bugs

=head1 AUTHOR

Allen Day E<lt>allenday@ucla.eduE<gt>

=head1 SEE ALSO


=head1 COPYRIGHT AND LICENSE

FIXME

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a '_'.  Methods are
in alphabetical order for the most part.

=cut


# Let the code begin...

package Bio::DB::Expression::geo;
use strict;
use base qw(Bio::DB::Expression);
our $VERSION = '0.01';

use Bio::DB::Taxonomy;
use Bio::Expression::Contact;
use Bio::Expression::DataSet;
use Bio::Expression::Platform;
use Bio::Expression::Sample;

use constant URL_PLATFORMS => 'http://www.ncbi.nlm.nih.gov/geo/query/browse.cgi?pgsize=100000&mode=platforms&submitter=-1&filteron=0&filtervalue=-1&private=1&sorton=pub_date&sortdir=1&start=1';
use constant URL_PLATFORM => 'http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?form=text&view=full&acc=';
use constant URL_DATASET => 'http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?form=text&view=full&acc=';
use constant URL_SAMPLE => 'http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?form=text&view=full&acc=';

=head2 _initialize()

=over

=item Usage

  $obj->_initialize(%arg);

=item Function

Internal method to initialize a new Bio::DB::Expression::geo object

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

  $self->taxdb( Bio::DB::Taxonomy->new(-source => 'entrez') );

  return 1;
}

=head2 get_platforms()

 Usage   :
 Function:
 Example :
 Returns : a list of Bio::Expression::Platform objects
 Args    :

=cut

sub get_platforms {
  my ($self,@args) = @_;

  my $doc = $self->_get_url( URL_PLATFORMS );
  $doc =~ s!^.+?>Release date<.+?</tr>(.+)</table>!$1!gs;

  my @platforms = ();
  my @records = split m!</tr>\s+<tr>!, $doc;

  foreach my $record ( @records ) {
    my ($platform_acc,$name,$tax_acc,$contact_acc) =
      $record =~ m!acc\.cgi\?acc=(.+?)".+?<td.+?>(.+?)<.+?<td.+?>.+?<.+?<td.+?>.+?href=".+?id=(.+?)".+?<td.+?OpenSubmitter\((\d+?)\).+?!s;
    next unless $platform_acc;

    my $platform = Bio::Expression::Platform->new(
                                                  -accession => $platform_acc,
                                                  -name => $name,
#                                                  -taxon => $self->taxdb->get_Taxonomy_Node( $tax_acc ),
                                                  -contact => Bio::Expression::Contact->new( -source => 'geo', -accession => $contact_acc, -db => $self ),
                                                  -db => $self,
                                                 );
    push @platforms, $platform;
  }

  return @platforms;
}

=head2 get_samples()

 Usage   :
 Function:
 Example :
 Returns : a list of Bio::Expression::Sample objects
 Args    :

=cut

sub get_samples {
  my ($self,@args) = @_;
  $self->throw_not_implemented();
}

=head2 get_contacts()

 Usage   :
 Function:
 Example :
 Returns : a list of Bio::Expression::Contact objects
 Args    :

=cut

sub get_contacts {
  my ($self,@args) = @_;
  $self->throw_not_implemented();
}

=head2 get_datasets()

 Usage   : $db->get_datasets('accession');
 Function:
 Example :
 Returns : a list of Bio::Expression::DataSet objects
 Args    :

=cut

sub get_datasets {
  my ($self,$platform) = @_;

  my @lines = split /\n/, $self->_get_url( URL_PLATFORM . $platform->accession );

  my @datasets = ();

  foreach my $line ( @lines ) {
    my ($dataset_acc) = $line =~ /^\!Platform_series_id = (\S+)/;
    next unless $dataset_acc;

    my $dataset = Bio::Expression::DataSet->new(
                                                -accession => $dataset_acc,
                                                -platform => $platform,
                                                -db => $self,
                                               );

    push @datasets, $dataset;
  }

  return @datasets;
}

sub fill_sample {
  my ( $self, $sample ) = @_;

  my @lines = split /\n/, $self->_get_url( URL_SAMPLE. $sample->accession );

  foreach my $line ( @lines ) {
    if ( my ($name) = $line =~ /^\!Sample_title = (\S+)/ ) {
      $sample->name( $name );
    }
    elsif ( my ($desc) = $line =~ /^\!Sample_characteristics.*? = (\S+)/ ) {
      $sample->description( $desc );
    }
    elsif ( my ($source_name) = $line =~ /^\!Sample_source_name.*? = (\S+)/ ) {
      $sample->source_name( $source_name );
    }
    elsif ( my ($treatment_desc) = $line =~ /^\!Sample_treatment_protocol.*? = (\S+)/ ) {
      $sample->treatment_description( $treatment_desc );
    }
  }
  return 1;
}

sub fill_dataset {
  my ( $self, $dataset ) = @_;

  my @lines = split /\n/, $self->_get_url( URL_DATASET . $dataset->accession );

  my @samples = ();

  foreach my $line ( @lines ) {
    if ( my ($sample_acc) = $line =~ /^\!Series_sample_id = (\S+)/ ) {
      my $sample = Bio::Expression::Sample->new(
                                                -accession => $sample_acc,
                                                -dataset => $dataset,
                                                -db => $self,
                                               );
      push @samples, $sample;
    }
    elsif ( my ($pubmed_acc) = $line =~ /^\!Series_pubmed_id = (\S+)/ ) {
      $dataset->pubmed_id( $pubmed_acc );
    }
    elsif ( my ($web_link) = $line =~ /^\!Series_web_link = (\S+)/ ) {
      $dataset->web_link( $web_link );
    }
    elsif ( my ($contact) = $line =~ /^\!Series_contact_name = (\S+)/ ) {
      $dataset->contact( $contact );
    }
    elsif ( my ($name) = $line =~ /^\!Series_title = (.+)$/ ) {
      $dataset->name( $name );
    }
    elsif ( my ($desc) = $line =~ /^\!Series_summary = (.+)$/ ) {
      $dataset->description( $desc );
    }
    elsif ( my ($design) = $line =~ /^\!Series_type = (.+)$/ ) {
      $dataset->design( $design );
    }
    elsif ( my ($design_desc) = $line =~ /^\!Series_overall_design = (.+)$/ ) {
      $dataset->design_description( $design_desc );
    }
  }

  $dataset->samples(\@samples);
}







#################################################

=head2 taxdb()

 Usage   : $obj->taxdb($newval)
 Function: 
 Example : 
 Returns : a Bio::DB::Taxonomy object
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub taxdb {
  my($self,$val) = @_;
  $self->{'taxdb'} = $val if defined($val);
  return $self->{'taxdb'};
}



=head2 _platforms_doc()

 Usage   :
 Function:
 Example :
 Returns : an HTML document containing a table of all platforms
 Args    :


=cut

sub _get_url {
  my ($self,$url) = @_;

  my $response;
  eval {
    $response = $self->get( $url );
  };
  if( $@ ) {
    $self->warn("Can't query website: $@");
    return;
  }
  $self->debug( "resp is $response\n") if( $self->verbose > 0); 

  return $response;
}


1;