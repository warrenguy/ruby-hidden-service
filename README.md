# Tor::HiddenService

Bring up a Tor hidden service from within your Ruby app.

You might find this useful to run a hidden service in your Heroku/Dokku or
other containerised infrastructure.

## Usage

Add the gem to your Gemfile:

```ruby
gem 'ruby-hidden-service'
```

and start the hidden service during startup of your web backend, probably
in `config.ru`, for example:

```ruby
require 'tor/hidden-service'

hidden_service = Tor::HiddenService.new(
  private_key: ENV['HIDDEN_SERVICE_PRIVATE_KEY'],
  server_port: ENV['PORT'] || 5000
)

hidden_service.start
```
### Options

All configuration options and their defaults:
```ruby
tor_executable:      (Tor.available? ? Tor.program_path : nil),
temp_dir:            "#{ENV['PWD']}/tmp" || nil,
private_key:         nil,
server_host:         'localhost',
server_port:         ENV['PORT'],
hidden_service_port: 80,
tor_control_port:    rand(10000..65000)
```

### Tor executable

This relies on Tor being in your path, or otherwise having the path to the
Tor binary specified in the options hash. If you're running on Heroku or
Dokku, you can use the [heroku-buildpack-apt](https://github.com/ddollar/heroku-buildpack-apt) and [heroku-buildpack-multi](https://github.com/ddollar/heroku-buildpack-multi)
buildpacks to install the `tor` package. This will place the Tor binary in
the path where this library can discover it.

## License

MIT license. See [LICENSE](https://github.com/warrenguy/ruby-hidden-service/blob/master/LICENSE).

## Author

Warren Guy <warren@guy.net.au>

https://warrenguy.me
