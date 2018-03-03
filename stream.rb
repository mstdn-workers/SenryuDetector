require 'websocket-client-simple'

class MstdnStream
  STREAMING_PATH = 'https://mstdn-workers.com/api/v1/streaming'.freeze
  TOKEN_FILE_NAME = '.access_token'.freeze
  ACCESS_TOKEN = File.read(TOKEN_FILE_NAME).chomp.freeze

  def stream
    url = "#{STREAMING_PATH}?access_token=#{ACCESS_TOKEN}&stream=public:local"
    WebSocket::Client::Simple.connect(url)
  end
end
