module Dkim
  class HeaderList
    include Enumerable
    def initialize headers
      @headers = Header.parse headers
    end
    def [](key)
      @headers.detect do |header|
        header.relaxed_key == key
      end
    end
    def each(&block)
      @headers.each(&block)
    end
  end
end
