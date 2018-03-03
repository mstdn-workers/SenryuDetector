require './register'
require './senryu_detector'
require './stream'
require 'json'
require 'pp'

class Main
  include Register

  def initialize
    @client = init_app
    @detector = SenryuDetector.new
    @stream = MstdnStream.new.stream

    set_stream
  end

  private

  def set_stream
    detector = @detector
    @stream.on :message do |msg|
      if msg.data.size > 0
        p msg.data
        begin
          remove_tag = -> (str) { str.gsub(/<([^>]+)>/, '') }
          info = JSON.parse(msg.data)
          if info['event'] == 'update'
            body = JSON.parse(info['payload'])
            p remove_tag.call(body['content'])
            p detector.senryu?(remove_tag.call(body['content']))
          end
        rescue => e
          p e
        end
      end
    end

    @stream.on :open do
      puts "streaming open"
    end

    @stream.on :close do |e|
      puts "close"
      p e
      exit 1
    end

    @stream.on :error do |e|
      p e
    end
  end
end

begin
  Main.new
  loop do
    sleep(1)
  end
rescue => e
  p e
end
