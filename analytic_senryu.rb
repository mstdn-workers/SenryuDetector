require 'natto'
require 'httpclient'

def senryu_page
  client = HTTPClient.new('')
  res = client.get('http://www.q-month.jp/archives/senryu.html')
  res.body
end

def extract_senryus(body)
  body.scan(%r{<p>(.*?)<\/p><p class="gago">}).map(&:first)
end

def analyze_senryus(senryus)
  nm = Natto::MeCab.new
  posids = Array.new(68, 0) # Mecabのposidは68個ある

  senryus.each do |senryu|
    analyticing_flag = true # 川柳の開始と空白の後を調べる = 上五中七下五の先頭を調べる
    begin
      nm.parse(senryu) do |parsed|
        if analyticing_flag
          posids[parsed.posid] += 1
          analyticing_flag = false
        elsif parsed.surface == '　'
          analyticing_flag = true
        end
      end
    rescue
      puts senryu
    end
  end
  posids
end

p analyze_senryus(extract_senryus(senryu_page)) # senryu_page |> extract_senryus |> analytics_senryus
