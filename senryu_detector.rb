require 'natto'

class Array
  def has?(item)
    !count(item).zero?
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
    pronunciations(safe_text).each do |parsed|
      break if parsed.is_bos? || parsed.is_eos?
      puts "#{parsed.posid}(#{be_permission?(parsed.posid) ? "Permission Exist" : "Permission Denied"}): #{parsed.surface}(#{parsed.feature})"
    end
  end

  private

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

  def be_permission?(posid)
    @permission_posids.has?(posid)
  end

  def pronunciations(text)
    pronunciation_nm = Natto::MeCab.new('-F%f[8]')
    pronunciation_nm.enum_parse(text)
  end
end

text = "今日もどったんばったん大騒ぎ"
SenryuDetector.new.senryu?(text)
