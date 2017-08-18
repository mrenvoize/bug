package Test;
use Mojo::Base 'Mojolicious';

use Mojo::Pg;

has pg => sub {
  my $app = shift;
  my $pg_connect
    = "postgresql://"
    . $app->config->{dbi}->{username} . ":"
    . $app->config->{dbi}->{password} . "@"
    . $app->config->{dbi}->{host} . ":"
    . $app->config->{dbi}->{port} . "/"
    . $app->config->{dbi}->{database};
  state $pg = Mojo::Pg->new($pg_connect)->search_path(['list', 'minion', 'public']);
  return $pg;
};

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');

  # Add Mojo::Pg helper
  $self->helper(pg => sub { $self->pg });

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  # WebSocket route
  $r->websocket('/socket')->to('socket#start');

  # Message API route
  $r->post('/send')->to('send#message');
}

1;
