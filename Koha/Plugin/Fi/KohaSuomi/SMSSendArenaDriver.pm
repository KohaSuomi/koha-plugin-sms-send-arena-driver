package Koha::Plugin::Fi::KohaSuomi::SMSSendArenaDriver;

## It's good practice to use Modern::Perl
use Modern::Perl;

## Required for all plugins
use base qw(Koha::Plugins::Base);

## We will also need to include any Koha libraries we want to access
use C4::Context;
use utf8;
use C4::Languages;

## Here we set our plugin version
our $VERSION = "1.0";

## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name            => 'SMS::Send::Arena::Driver',
    author          => 'Johanna Räisä',
    date_authored   => '2021-08-27',
    date_updated    => "2021-08-27",
    minimum_version => '17.05.00.000',
    maximum_version => undef,
    version         => $VERSION,
    description     => 'Send SMS messages to Arena interface. (Paikalliskannat, jos Arena käytössä)',
};

sub get_localized_metadata {
    my ($self) = @_;
    my $lang = C4::Languages::getlanguage() || 'en';
    my ($name, $description);

    if ($lang eq 'sv-SE') {
        $name = "SMS::Send::Arena::Driver";
        $description = "Skicka SMS-meddelanden till Arena-gränssnittet. (Lokala databaser, om Arena används)";
    
    } elsif ($lang eq 'fi-FI' ) {
        $name = "SMS::Send::Arena::Driver";
        $description = "Lähetä SMS-viestejä Arena-liittymään. (Paikalliskannat, jos Arena käytössä)";
    } else {
        $name = "SMS::Send::Arena::Driver";
        $description = "Send SMS messages to Arena interface. (Local databases, if Arena is used)";
    }
    return ($name, $description);
}

## This is the minimum code required for a plugin's 'new' method
## More can be added, but none should be removed
sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    my ($name, $description) = $self->get_localized_metadata();
    $self->{'metadata'}->{'name'} = $name;
    $self->{'metadata'}->{'description'} = $description;

    return $self;
}

## This is the 'upgrade' method. It will be triggered when a newer version of a
## plugin is installed over an existing older version of a plugin
sub upgrade {
    my ( $self, $args ) = @_;

    return 1;
}

1;
