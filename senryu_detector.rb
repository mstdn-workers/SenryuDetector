require 'natto'

class SenryuDetector
  def senryu?(text)
    pronunciations(text).each do |pron|
      p pron
    end
  end

  def pronunciations(text)
    pronunciation_nm = Natto::MeCab.new('-F%f[8]')
    pronunciation_nm.enum_parse(text)
  end
end

SenryuDetector.new.senryu?("柿食えば\n　鐘がなるなり\n　　法隆寺")
