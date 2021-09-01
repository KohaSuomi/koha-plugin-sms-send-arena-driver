package SMS::Send::Arena::Driver;
#use Modern::Perl; #Can't use this since SMS::Send uses hash keys starting with _
use SMS::Send::Driver ();
use LWP::Curl;
use URI::Escape;
use Encode;
use Koha::Notice::Messages;
use Koha::Libraries;

use Try::Tiny;

use vars qw{$VERSION @ISA};
BEGIN {
        $VERSION = '0.01';
        @ISA     = 'SMS::Send::Driver';
}


#####################################################################
# Constructor

sub new {
        my $class = shift;
        my $params = {@_};

        my $username = $params->{_login} ? $params->{_login} : $params->{_user};
        my $password = $params->{_password} ? $params->{_password} : $params->{_passwd};
        my $baseUrl = $params->{_baseUrl};

        if (! defined $username ) {
            warn "->send_sms(_login) must be defined!";
            return;
        }
        if (! defined $password ) {
            warn "->send_sms(_password) must be defined!";
            return;
        }

        if (! defined $baseUrl ) {
            warn "->send_sms(_baseUrl) must be defined!";
            return;
        }

        #Prevent injection attack
        $self->{_login} =~ s/'//g;
        $self->{_password} =~ s/'//g;

        # Create the object
        my $self = bless {}, $class;

        $self->{_login} = $username;
        $self->{_password} = $password;
        $self->{_baseUrl} = $baseUrl;
        $self->{_deliveryUrl} = $params->{_deliveryUrl};
        $self->{_clientId} = $params->{_clientId};

        return $self;
}

sub _get_arena_clientId {
    my ($config, $message_id) = @_;
    my $clientid;

    if (ref($config) eq "HASH") {
        my $notice = Koha::Notice::Messages->find($message_id);
        my $library = Koha::Libraries->find({branchemail => $notice->{from_address}});
        my %clientIds = %{$config};
        foreach $key (keys %clientIds) {
            if ($key eq $library->branchcode) {
                $clientid = $clientIds{$key};
                last;
            }
        }
    } else {
        $clientid = $config;
    }
    return $clientid;
}

sub send_sms {
    my $self    = shift;
    my $params = {@_};
    my $message = $params->{text};
    my $recipientNumber = $params->{to};

    my $clientid = _get_arena_clientId($self->{_clientId}, $params->{_message_id});
    

    if (! defined $message ) {
        warn "->send_sms(text) must be defined!";
        return;
    }
    if (! defined $recipientNumber ) {
        warn "->send_sms(to) must be defined!";
        return;
    }

    if (! defined $clientid ) {
        warn "->send_sms(clientid) must be defined!";
        return;
    }

    #Prevent injection attack!
    $recipientNumber =~ s/'//g;
    $message =~ s/(")|(\$\()|(`)/\\"/g; #Sanitate " so it won't break the system( iconv'ed curl command )

    my $base_url = $self->{_baseUrl};
    my $parameters = {
        'l'         => $self->{_login},
        'p'         => $self->{_password},
        'msisdn'    => $recipientNumber,
        'msg'       => Encode::encode( "utf8", $message),
        'clientid'  => $clientid,
    };

    if ($self->{_deliveryUrl}) {
        $parameters->{'dlrurl'} = $self->{_deliveryUrl};
    }

    my $lwpcurl = LWP::Curl->new();
    my $return;
    try {
        $return = $lwpcurl->post($base_url, $parameters);
    } catch {
        if ($_ =~ /Couldn't resolve host name \(6\)/) {
            die "Connection failed";
        }
        die $_;
    };

    if ($lwpcurl->{retcode} == 6) {
        die "Connection failed";
    }

    my $delivery_note = $return;

    return 1 if ($return =~ m/<accepted>+/);

    # remove everything except the delivery note
    $delivery_note =~ s/^(.*)message\sfailed:\s*//g;

    # pass on the error by throwing an exception - it will be eventually caught
    # in C4::Letters::_send_message_by_sms()
    die $delivery_note;
}
1;
