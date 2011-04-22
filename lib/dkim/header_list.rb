module Dkim
  class HeaderList
    include Enumerable
    def initialize headers
      @headers = headers.split(/\r?\n(?!([ \t]))/).map do |header|
        key, value = header.split(':', 2)
        Header.new(key, value)
      end
    end
    def [](key)
      @headers.detect do |header|
        header.key == key
      end
    end
    def each(&block)
      @headers.each(&block)
    end
  end
end
