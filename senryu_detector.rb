require 'natto'

class Array
  def has?(item)
    !count(item).zero?
  end
end

class SenryuArray < Array
  def text
    text = []
    each do |item|
      text << item[:parsed].surface
    end
    text.join
  end
  def yomi
    yomi = []
    each do |item|
      yomi << item[:yomi]
    end
    yomi.join
  end
end

class SenryuDetector
  attr_accessor :ignore_words, :delete_words, :permission_posids
  def initialize
    @delete_words, @ignore_words = read_file('exclude_word.tsv')
    @permission_posids, * = read_file('permission.tsv')
    @permission_posids.map!(&:to_i)
  end

  def senryu?(text)
    safe_text = delete_excludes(text)
    senryu_elements = SenryuArray.new

    pronunciations(safe_text).each do |parsed|
      break if parsed.is_bos? || parsed.is_eos?
      senryu_elements << {
        parsed: parsed,
        yomi: ignore?(parsed.surface) ? '' : remove_not_pronucation(parsed.feature)
      }

      senryu_elements.shift while senryu_elements.yomi.length > 18

      if (ret_val = _senryu?(senryu_elements))
        return ret_val
      end

      if senryu_elements[1..-1].yomi.length == 17 && (ret_val = _senryu?(senryu_elements[1..-1]))
        return ret_val
      end
    end

    return false
  end

  private

  def _senryu?(elements)
    return false unless elements.yomi.length == 17 || elements.yomi.length == 18
    checking = :kami
    checking_length = { kami: 5, naka: elements.yomi.length - 10, shimo: 5 }
    pre_checking = { kami: :kami, naka: :kami, shimo: :naka }

    result = Hash.new('')
    yomi = ''

    elements.each do |elm|

      if special_ignore?(elm[:parsed].surface) && yomi.empty?
        result[pre_checking[checking]] += elm[:parsed].surface
        next
      end

      return false if yomi.empty? && !be_permission?(elm[:parsed].posid)

      result[checking] += elm[:parsed].surface
      yomi += elm[:yomi]

      if (tmp = check_format(yomi, checking_length[checking], checking))
        yomi, checking = tmp
      else
        return false
      end
    end

    return result.values
  end

  def check_format(yomi, length, checking)
    checking_ref = { kami: :naka, naka: :shimo, shimo: nil }

    if yomi.length == length
      return true if checking == :shimo
      return ['', checking_ref[checking]]
    elsif yomi.length > length
      return false
    end
    return [yomi, checking]
  end

  def read_file(filename)
    reading_line = []
    File.open(filename) do |f|
      f.each_line do |line|
        reading_line << line.split[1..-1]
      end
    end
    reading_line
  end

  def delete_excludes(text)
    dump = text.dup
    @delete_words.each do |excluded|
      dump.delete!(excluded)
    end
    dump
  end

  def ignore?(word)
    @ignore_words.has?(word)
  end

  # 終端となる記号は特別な動きをする
  def special_ignore?(word)
    special_ignore = ['］', '」', '＞','｝']
    special_ignore.has?(word)
  end

  def be_permission?(posid)
    @permission_posids.has?(posid)
  end

  def pronunciations(text)
    pronunciation_nm = Natto::MeCab.new('-F%f[8]')
    pronunciation_nm.enum_parse(text)
  end

  def remove_not_pronucation(text)
    text.gsub(/ャ|ュ|ョ|ァ|ィ|ゥ|ェ|ォ|、|/, '')
  end
end

Detector = SenryuDetector.new
loop do
  text = gets.chomp
  p Detector.senryu?(text)
end
