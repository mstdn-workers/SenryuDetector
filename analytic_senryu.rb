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
  posids = Array.new(69){ { num: 0, word: [] } } # Mecabのposidは69個ある

  senryus.each do |senryu|
    analyticing_flag = true # 川柳の開始と空白の後を調べる = 上五中七下五の先頭を調べる
    begin
      nm.parse(senryu) do |parsed|
        if analyticing_flag
          posids[parsed.posid][:num] += 1
          posids[parsed.posid][:word] << parsed.surface
          analyticing_flag = false
        elsif parsed.surface == '　'
          analyticing_flag = true
        end
      end
    rescue
      # puts senryu
    end
  end
  posids
end

def save_posids(posids)
  posid_names = %w(その他 フィラー 感動詞 アルファベット 一般記号 括弧開 括弧閉 句点 空白 読点 自立形容詞 接尾形容詞 非自立形容詞 一般格助詞 引用格助詞 連語格助詞 係助詞 終助詞 接続助詞 特殊助詞 副詞化助詞 副助詞 副助詞／並列助詞／終助詞 並立助詞 連体化助詞 助動詞 接頭詞 形容詞接続接頭詞 数接続接頭詞 動詞接続接頭詞 名詞接続接頭詞 自立動詞 接尾動詞 非自立動詞 一般副詞 助詞類接続動詞 サ変接続名詞 ナイ形容詞語幹名詞 一般名詞 引用文字列名詞 形容動詞語幹名詞 一般固有名詞 人名一般固有名詞 姓 名 組織 一般地域 国 数名詞 接続詞的名詞 サ変接続接尾名詞 一般接尾名詞 形容動詞語幹接尾名詞 助数詞接尾名詞 助動詞語幹接尾名詞 人名接尾名詞 地域接尾名詞 特殊接尾名詞 副詞可能接尾名詞 一般代名詞 縮約代名詞 動詞非自立的名詞 助動詞語幹特殊名詞 一般非自立名詞 形容動詞語幹非自立名詞 助動詞語幹非自立名詞 副詞可能非自立名詞 副詞可能名詞 連体詞)

  File.open('senryu_initial_posids.txt', "w") do |f|
    69.times do |i|
      f.puts "#{i}\t#{posid_names[i]}\t#{posids[i][:num]}\t#{posids[i][:word].join('	')}"
      puts "#{"　" * (12 - posid_names[i].length)}#{posid_names[i]} : #{posids[i][:num]}(ex.#{posids[i][:word].sample})" unless posids[i][:num].zero?
    end
  end
end

result_posids = analyze_senryus(extract_senryus(senryu_page)) # senryu_page |> extract_senryus |> analytics_senryus
save_posids(result_posids)
