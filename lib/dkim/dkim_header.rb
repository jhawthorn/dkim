
require 'dkim/header'
require 'dkim/tag_value_list'
require 'dkim/encodings'

module Dkim
  class DkimHeader < Header
    attr_reader :list
    def initialize values={}
      self.key = 'DKIM-Signature'
      @list = TagValueList.new values
    end
    def value
      wrap " #{@list}", key.size + 2
    end
    def [] k
      encoder_for(k).decode(@list[k])
    end
    def []= k, v
      @list[k] = encoder_for(k).encode(v)
    end

    private
    def encoder_for key
      case key
      when *%w{v a c d h l q s t x}
        Encodings::PlainText
      when *%w{i z}
        Encodings::DkimQuotedPrintable
      when *%w{b bh}
        Encodings::Base64
      else
        raise "unknown key: #{key}"
      end.new
    end

    def wrap(raw, prepend=0) # :nodoc:
      words = raw.split(/[ \t]/)
      custom_split_words = []
      words.each do |word|
        if word.start_with?('h=')
          # header field list can be folded at ":"
          custom_split_words.concat(word.split(/(?<=:)/))
        elsif word.start_with?('b=') || word.start_with?('bh=')
          # base64 encoded fields can be folded anywhere. Use fixed
          # length substrings
          offset = 0
          len = 60
          until word[offset].nil?
            custom_split_words <<= word[offset, len]
            offset += len
          end
        else
          custom_split_words <<= word
        end
      end

      # Simplified ASCII-only version of wrap from Fields::UnstructuredField
      folded_lines = []
      until custom_split_words.empty?
        limit = 78 - prepend
        line = String.new
        first_word = true
        until custom_split_words.empty?
          break unless word = custom_split_words.first.dup
          break if !line.empty? && (line.length + word.length + 1 > limit)

          # Remove the word from the queue ...
          custom_split_words.shift
          # Add word separator
          if first_word
            first_word = false
          else
            line << ' '
          end
          # ... add it in encoded form to the current line
          line << word
        end
        # Add the line to the output and reset the prepend
        folded_lines << line
        prepend = 0
      end
      folded_lines.join("\r\n    ")
    end
  end
end
