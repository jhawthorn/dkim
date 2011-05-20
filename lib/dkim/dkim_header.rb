
require 'dkim/header'

module Dkim
  class DkimHeader < Header
    def initialize values={}
      self.key = 'DKIM-Signature'
      @values = values.flatten.each_slice(2).to_a
    end
    def value
      @values.map do |(k, v)|
        " #{k}=#{v}"
      end.join(';')
    end
    def [] k
      value = @values.detect {|(a,b)| a == k }
      value && value[1]
    end
    def []= k, v
      value = @values.detect {|(a,b)| a == k }
      if !value
        value = [k, nil]
        @values << value
      end
      value[1] = v
    end
  end
end
