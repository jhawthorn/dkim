
require 'test/unit'
require 'dkim'

class String
  # Parse the format used in rfc4871
  #
  # In the following examples, actual whitespace is used only for
  # clarity.  The actual input and output text is designated using
  # bracketed descriptors: "<SP>" for a space character, "<HTAB>" for a
  # tab character, and "<CRLF>" for a carriage-return/line-feed sequence.
  # For example, "X <SP> Y" and "X<SP>Y" represent the same three
  # characters.
  def rfc_format
    str = self.dup
    str.gsub!(/\s/,'')
    str.gsub!(/<SP>/i,' ')
    str.gsub!(/<CR>/i,"\r")
    str.gsub!(/<LF>/i,"\n")
    str.gsub!(/<CRLF>/i,"\r\n")
    str.gsub!(/<HTAB>/i,"\t")
    str
  end
end

# examples used in rfc
Dkim::domain = 'example.com'


