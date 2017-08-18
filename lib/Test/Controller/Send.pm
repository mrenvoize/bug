package Test::Controller::Send;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON;

sub message {
  my $c = shift;

  # Set Pg PubSub to json
  $c->pg->pubsub->json('updates');

  # Notify via PubSub
  my $json = $c->req->json;
  $c->pg->pubsub->notify('updates' => {username => $json->{'username'}, message => $json->{'message'}});
  $c->app->log->debug("PubSub notify of message on 'updates'");

  # Complete
  return $c->render(json => {accepted => 1});
}

1;
