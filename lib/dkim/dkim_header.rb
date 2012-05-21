
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
      " #{@list}"
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
  end
end
