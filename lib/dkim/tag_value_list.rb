module Dkim
  class TagValueList
    def initialize values={}
      @keys = values.keys
      @values = values.dup
    end
    def to_s
      @keys.map do |k|
        "#{k}=#{@values[k]}"
      end.join('; ')
    end
    def [] k
      @values[k]
    end
    def []= k, v
      @keys << k unless self[k]
      @values[k] = v
    end
    def self.parse string
      list = new
      string.split(';').each do |keyval|
        key, value = keyval.split('=', 2)
        list[key.strip] = value.strip
      end
      list
    end
  end
end
