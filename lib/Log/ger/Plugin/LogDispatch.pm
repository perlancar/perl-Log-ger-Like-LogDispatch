package Log::ger::Plugin::LogDispatch;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

sub get_hooks {
    my %conf = @_;

    return {
        create_formatter => [
            __PACKAGE__, # key
            50,          # priority
            sub {        # hook
                my %hook_args = @_; # see Log::ger::Manual::Internals/"Arguments passed to hook"

                my $formatter = sub {
                    my %log_args = @_;

                };
                [$formatter];
            }],
    };
}

1;
# ABSTRACT: Log like Log::Dispatch

=for Pod::Coverage ^(.+)$
