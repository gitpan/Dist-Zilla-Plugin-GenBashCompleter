package Dist::Zilla::Plugin::GenBashCompleter;

our $DATE = '2014-11-14'; # DATE
our $VERSION = '0.01'; # VERSION

use 5.010001;
use strict;
use warnings;

use Moose;
with (
	'Dist::Zilla::Role::FileFinderUser' => {
		default_finders => [ ':ExecFiles' ],
	},
        'Dist::Zilla::Role::FileGatherer',
);

use namespace::autoclean;

use App::GenBashCompleter;

sub gather_files {
    my ($self, $arg) = @_;

    require Dist::Zilla::File::InMemory;

    for my $file (@{ $self->found_files }) {
        my $scriptname = $file->name;

        # XXX currently gen_bash_completer only accept path (instead of
        # content), so we don't yet support dynamically generated scripts
        my $res = App::GenBashCompleter::gen_bash_completer(path=>$scriptname);

        if ($res->[0] != 200) {
            $self->log("Can't generate bash completer for $scriptname: ".
                           "$res->[1]");
            next;
        }
        if (!$res->[2]) {
            $self->log_debug("No bash completer can be generated ".
                                 "$scriptname: ".$res->[3]{'func.reason'});
            next;
        }

        my $compname = $file->name; $compname =~ s!(.+[/\\])(.+)!${1}_$2!;
        (my $compname_file = $compname) =~ s!.+[/\\]!!;
        (my $scriptname_file = $scriptname) =~ s!.+[/\\]!!;
        my $content = $res->[2];
        $content =~ s/^(#!.+)/$1 .
            "# ABSTRACT: Bash completer script for $scriptname_file\n" .
            "# PODNAME: $compname_file\n"
                /em;
        my $compfile = Dist::Zilla::File::InMemory->new(
            name => $compname, content => $content);
        $self->log("Creating bash completer script $compname for $scriptname");
        $self->add_file($compfile);
    }
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Create bash completer script for your scripts using App::GenBashCompleter

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::GenBashCompleter - Create bash completer script for your scripts using App::GenBashCompleter

=head1 VERSION

This document describes version 0.01 of Dist::Zilla::Plugin::GenBashCompleter (from Perl distribution Dist-Zilla-Plugin-GenBashCompleter), released on 2014-11-14.

=head1 SYNOPSIS

In C<dist.ini>:

 [GenBashCompleter]

After build, if there are any of your scripts (e.g. C<bin/foo>) which
L<App::GenBashCompleter> can generate bash completer script for, it will be
generated (e.g. C<bin/_foo>) and added to your build.

=head1 DESCRIPTION

=for Pod::Coverage .+

=head1 SEE ALSO

L<App::GenBashCompleter>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Dist-Zilla-Plugin-GenBashCompleter>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Dist-Zilla-Plugin-GenBashCompleter>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-GenBashCompleter>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
