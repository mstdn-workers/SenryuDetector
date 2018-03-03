require 'eventmachine'
require 'faye/websocket'

class MstdnStream
  STREAMING_PATH = 'wss://mstdn-workers.com/api/v1/streaming'.freeze
  TOKEN_FILE_NAME = '.access_token'.freeze
  ACCESS_TOKEN = File.read(TOKEN_FILE_NAME).chomp.freeze

  class << self
    def set_stream
      p 'begin'
      EM.run do
        url = "#{STREAMING_PATH}?access_token=#{ACCESS_TOKEN}&stream=public:local"
        p url
        conn = Faye::WebSocket::Client.new(url)

        conn.on :open do
          puts 'connection success.'
        end

        conn.on :error do |e|
          p e
        end

        conn.on :close do
          puts 'connection close.'
        end

        conn.on :message do |msg|
          yield msg
        end
      end
    end
  end
end
