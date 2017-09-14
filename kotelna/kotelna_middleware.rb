# encoding: UTF-8

require 'prometheus/client'
require 'softplc'
require 'json'

Softplc.configure do |config|
  config.host = "192.168.1.160"
  config.user = "softplc"
  config.pass = "softplc"
end

module Prometheus
  module Middleware
    class KotelnaCollector
      attr_reader :app, :registry

      def initialize(app, options = {})
        @app = app
        @registry = options[:registry] || Client.registry
        init_metrics
      end

      def call(env) # :nodoc:
        get_data(env) { @app.call(env) }
      end

      protected

      def init_metrics
        @sensors={}
        @sensor_groups = JSON.load(File.read("sensors.json"))
        @sensor_groups.each{|group,values|
          @sensors[group]=@registry.gauge(group.to_sym, values["description"])
        }
        @uuids = @sensor_groups.collect{|k,v| v["variables"].collect{|s| s["uuid"] } }.flatten
      end

      def symbolize_keys(hash)
        hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v.is_a?(Hash) ? symbolize_keys(v) : v }
      end

      def get_data(env)
        sensors_data = Softplc::Fetcher.new(@uuids).sensors
        @sensor_groups.each{|group,values|
          values["variables"].each{|sensor|
             @sensors[group].set(symbolize_keys(sensor), sensors_data.detect{|s| s.uuid==sensor["uuid"]}.value.to_f)
          }
        }
        yield
      end

    end
  end
end
