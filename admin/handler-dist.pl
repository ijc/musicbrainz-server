# Sample handler.pl file.
# Start Mason and define the mod_perl handler routine.
#
package HTML::Mason;
use strict;
use warnings;
no warnings 'portable';
use HTML::Mason::ApacheHandler ( args_method => 'mod_perl' );
use HTML::Mason;    # brings in subpackages: Parser, Interp, etc.

# TODO: Check to make sure this path points to where the cgi-bin stuff is
use lib "/home/httpd/musicbrainz/cgi-bin";
use MusicBrainz;  
use UserStuff;  
use Album;
use Discid;
use TableBase;
use Artist;
use Alias;
use Track;
use Lyrics;
use UserStuff;
use ModDefs;
use FreeDB;
use Moderation;
use ModerationSimple;
use ModerationKeyValue;
use TRM;
use Sql;
use Style;
use QuerySupport;
use TaggerSupport;
use DebugLog;
use Statistic;
use MusicBrainz::Server::Handlers;

{  
   package HTML::Mason::Commands;
   use vars qw(%session);
   use CGI::Cookie;
   use Apache::Session::File;
}

# TODO: Edit the lines below, to indicate the user and group that
# files written by Mason should belong to.
my $apache_user = 'nobody';
my $apache_group = 'nobody';

my $parser = new HTML::Mason::Parser(default_escape_flags=>'h');
my $interp = new HTML::Mason::Interp (parser=>$parser,
            # TODO: This needs to point to the installed htdocs
            comp_root=>'/home/httpd/musicbrainz/htdocs',
            # TODO: This directory needs to be created for mason's internal 
            # use. Its best to create a mason dir in the main apache dir.
            data_dir=>'/home/httpd/musicbrainz/mason',
            allow_recursive_autohandlers=>undef);
my $ah = new HTML::Mason::ApacheHandler (interp=>$interp);
chown ( [getpwnam($apache_user)]->[2], [getgrnam($apache_group)]->[2],
        $interp->files_written );   # chown nobody

sub handler
{
    my ($r) = @_;

    # return "FORBIDDEN" for anyone trying to access comp directory
    return 403 if ($r->uri =~ m|^/comp/|);
    return -1 if (!defined $r->content_type);
    return -1 if $r->content_type && $r->content_type !~ m|^text/html|io;

    my %cookies = parse CGI::Cookie($r->header_in('Cookie'));
    if (exists $cookies{'AF_SID'})
    {
        eval { 
           tie %HTML::Mason::Commands::session, 
              'Apache::Session::File',
              $cookies{'AF_SID'}->value(),
              {
                 Directory => DBDefs::SESSION_DIR,
                 LockDirectory => DBDefs::LOCK_DIR,
              }; 
        };

        my $err = $@;

	my $user = $HTML::Mason::Commands::session{user};
	if (not $err and defined $user and $user ne "")
	{
	    $r->connection->user($user);
	}

        $ah->handle_request($r);

        if (! $err) 
        {   
             # only untie if you've managed to create a tie in the first place
             untie %HTML::Mason::Commands::session;
        }
    }
    else
    {
        $ah->handle_request($r);
    }
}

1;
