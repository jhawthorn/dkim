
require 'dkim/header'
require 'dkim/tag_value_list'

module Dkim
  class DkimHeader < Header
    def initialize values={}
      self.key = 'DKIM-Signature'
      @list = TagValueList.new values
    end
    def value
      " #{@list.to_s}"
    end
    def [] k
      @list[k]
    end
    def []= k, v
      @list[k] = v
    end
  end
end
