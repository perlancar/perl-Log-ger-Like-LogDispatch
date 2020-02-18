package Log::ger::Like::LogDispatch;

# AUTHORITY
# DATE
# DIST
# VERSION

our %composite_outputs;

sub new {
    my ($class, %args) = @_;

    my %attrs;
    if (my $outputs = delete $args{outputs}) {
        %composite_outputs = ();
        for my $output (@$outputs) {
            $composite_outputs{LogDispatchOutput} ||= [];
            my ($output_name, %output_args) = @{ $output };
            push @{ $composite_outputs{LogDispatchOutput} }, {
                conf => {output=>$output_name, args=>$output_args},
            };
        }
    }
    if (keys %args) {
        die "Unknown/unsupported attribute(s): ".join(", ", sort keys %args).
            ", currently supported attributes: outputs";
    }

    $_logger = Log::ger->get_logger;
    bless \%attrs, $class;
}

sub add {
    my ($self, $output_obj) = @_;
    $composite_outputs{LogDispatchOutput} ||= [];
    push @{ $composite_outputs{LogDispatchOutput} }, {
        conf => {_output=>$output_obj},
    };
}

sub log {
    my $self = shift;
    my $caller = caller;
    $caller->log(@_);
}

sub import {
    my $pkg = shift;

    # export $TRACE, ...
    my $caller = caller(0);
    {
        no warnings 'once';
        for (keys %Log::ger::Levels) {
            *{"$caller\::".uc($_)} = \$Log::ger::Levels{$_};
        }
    }

    require Log::ger;
    require Log::ger::Plugin;
    Log::ger::Plugin->set({
        name       => 'LogDispatch',
        target     => 'package',
        target_arg => $caller,
    });
    Log::ger::add_target(package => $caller, {});
    Log::ger::init_target(package => $caller, {});
}

1;
# ABSTRACT: Mimic Log::Dispatch

=for Pod::Coverage ^(get_logger|add)$

=head1 SYNOPSIS

 use Log::ger::Like::LogDispatch;

 my $log = Log::ger::Like::LogDispatch->new(
     outputs => [
         [ 'File',   min_level => 'debug', filename => 'logfile' ],
         [ 'Screen', min_level => 'warning' ],
     ],
 );

 $log->info("Blah, blah");

More verbose API:

 my $log = Log::ger::Like::LogDispatch->new;
 $log->add(
     Log::Dispatch::File->new(
         name      => 'file1',
         min_level => 'debug',
         filename  => 'logfile'
     )
 );
 $log->add(
     Log::Dispatch::Screen->new(
         name      => 'screen',
         min_level => 'warning',
     )
 );

 $log->log( level => 'info', message => 'Blah, blah' );


=head1 DESCRIPTION

EXPERIMENTAL. This module does the following to mimic L<Log::Dispatch> to a
certain extent:

=over

=item * Log::Dispatch-like formatting

 $log->log(level => 'info', message => 'Blah, blah!')

...

=back

...


=head1 SEE ALSO

L<Log::ger>

L<Log::Dispatch>
