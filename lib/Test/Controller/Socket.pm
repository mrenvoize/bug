package Test::Controller::Socket;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::JSON;

sub start {
  my $c = shift;
  #$c->inactivity_timeout(3600);

  my $connection = $c->tx->connection;

  # Set Pg PubSub to json
  $c->pg->pubsub->json('updates');

  # Forward messages from PostgreSQL to the browser
  my $updates_cb = sub {
    my ($pubsub, $payload) = @_;
    $c->app->log->debug(
      $connection . " Received payload on 'updates' subscription: " . Mojo::JSON::encode_json($payload));
    $c->send({json => $payload});
  };
  $c->pg->pubsub->listen('updates' => $updates_cb);
  $c->app->log->debug($connection . " PubSub listened to 'updates' ");

  # WebSocket cleanup
  $c->on(
    finish => sub {
      my ($s, $code) = @_;
      $c->app->log->debug($connection . " WebSocket closed with status $code.");

      # Unlisten to 'notifications' pubsub
      $c->pg->pubsub->unlisten('updates' => $updates_cb);
      $c->app->log->debug($connection . " PubSub unlistened to 'updates' ");

      return 1;
    }
  );
}

1;
