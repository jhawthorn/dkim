module Dkim
  class CanonicalizedHeaders
    include Enumerable
    def initialize header_list, signed_headers
      @header_list    = header_list
      @signed_headers = signed_headers.map(&:downcase)
    end
    def each(&block)
      header_hash = Hash.new {|h,k| h[k] = []}
      @header_list.each do |header|
        header_hash[header.relaxed_key] << header
      end

      @signed_headers.each do |key|
        yield header_hash[key].pop
      end
    end
    def to_s(canonicalization)
      map do |header|
        header.to_s(canonicalization) + "\r\n"
      end.join
    end
  end
end
