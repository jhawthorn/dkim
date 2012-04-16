
require 'dkim/header'

module Dkim
  class DkimHeader < Header
    def initialize values={}
      self.key = 'DKIM-Signature'
      @keys = values.keys
      @values = values.dup
    end
    def value
      @keys.map do |k|
        v = @values[k]
        " #{k}=#{v}"
      end.join(';')
    end
    def [] k
      @values[k]
    end
    def []= k, v
      @keys << k unless self[k]
      @values[k] = v
    end
  end
end
