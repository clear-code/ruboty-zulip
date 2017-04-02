require "zulip/client"

module Ruboty
  module Adapters
    class Zulip < Base

      env :ZULIP_SITE, "Zulip site URL"
      env :ZULIP_USERNAME, "Zulip username (email address)"
      env :ZULIP_API_KEY, "Zulip API key"
      env :ZULIP_STREAM, "Zulip stream name"

      def run
        listen
      end

      def say(message)
        to = case message.dig(:original, :type)
             when :stream
               message.dig(:original, :display_recipient)
             when :private
               message.dig(:original, :display_recipient).map do |recipient|
                 recipient[:email]
               end
             end
        client.send_message(
          type: message[:original][:type],
          to: to,
          subject: message[:subject],
          content: message[:content]
        )
      end

      private

      def client
        @client ||= Zulip::Client.new(site: site, username: username, api_key: api_key)
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

      def listen
        client.each_message do |event|
          robot.receive(event[:message])
        end
      end
    end
  end
end
