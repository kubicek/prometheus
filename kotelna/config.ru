require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require './kotelna_middleware.rb'

use Rack::Deflater, if: ->(_, _, _, body) { body.any? && body[0].length > 512 }
use Prometheus::Middleware::KotelnaCollector
use Prometheus::Middleware::Exporter

run ->(_) { [200, {'Content-Type' => 'text/html'}, ['OK']] }
