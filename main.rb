# coding: utf-8
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

    MstdnStream.set_stream do |msg|
      if msg.data.size > 0
        begin
          remove_tag = -> (str) { str.gsub(/<([^>]+)>/, '') }
          info = JSON.parse(msg.data)
          if info['event'] == 'update'
            body = JSON.parse(info['payload'])
            p remove_tag.call(body['content'])
            senryu = nil
            senryu = @detector.senryu?(remove_tag.call(body['content'])) unless body['content'].include?('川柳検知bot')
            if senryu
              p senryu
              p @detector.senryu?(senryu.join)
            end
          end
        rescue => e
          p e
        end
      end
    end
  end


end
Main.new

loop do
  sleep 1
end
