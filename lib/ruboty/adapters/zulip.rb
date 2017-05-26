require "zulip/client"

module Ruboty
  module Adapters
    class Zulip < Base

      env :ZULIP_SITE, "Zulip site URL"
      env :ZULIP_USERNAME, "Zulip username (email address)"
      env :ZULIP_API_KEY, "Zulip API key"
      env :ZULIP_STREAM, "Zulip stream name to monitor", optional: true
      env :ZULIP_TOPIC, "Zulip topic name to monitor", optional: true
      env :ZULIP_USE_SSL, "Use SSL/TLS to access Zulip ", optional: true

      def run
        listen
      end

      def say(message)
        message_type = message.dig(:original, :type).to_sym
        client.send_message(
          type: message_type,
          to: message.dig(:original, :to),
          subject: message.dig(:original, :subject),
          content: message[:body]
        )
      end

      private

      def client
        options = {}
        options[:ssl] = { verify: use_ssl? }
        @client ||= ::Zulip::Client.new(site: site, username: username, api_key: api_key, **options)
      end

      def site
        ENV["ZULIP_SITE"]
      end

      def username
        ENV["ZULIP_USERNAME"]
      end

      def api_key
        ENV["ZULIP_API_KEY"]
      end

      def stream_name
        ENV["ZULIP_STREAM"]
      end

      def topic
        ENV["ZULIP_TOPIC"]
      end

      def use_ssl?
        /true|yes/i === ENV.fetch("ZULIP_USE_SSL", "true")
      end

      def listen
        client.stream_message do |message|
          message[:body] = message[:content]
          robot.receive(
            body: message[:content],
            from: message[:sender_email],
            from_name: message[:sender_full_name],
            to: display_recipient(message),
            type: message[:type],
            subject: message[:subject],
          )
        end
      rescue Zulip::ResponseError => ex
        Ruboty.logger.warn("#{ex.class}: #{ex.message}\n#{ex.backtrace.join("\n")}")
        retry
      end

      def display_recipient(message)
        case message[:type].to_sym
        when :stream
          message[:display_recipient]
        when :private
          message[:display_recipient].map {|recipient| recipient[:email] }
        end
      end
    end
  end
end
