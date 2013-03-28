require 'test_helper'

module Dkim
  class OptionsTest < MiniTest::Unit::TestCase
    def setup
      klass = Class.new
      klass.send :include, Options
      @options = klass.new
    end
    def test_defaults_empty
      assert_equal({}, @options.options)
    end

    def test_all_options
      @options.signing_algorithm = 'abc123'
      assert_equal({:signing_algorithm => 'abc123'}, @options.options)

      desired_options = {
        :signing_algorithm => 'abc123',
        :signable_headers => [],
        :domain => 'example.net',
        :identity => '@example.net',
        :selector => 'selector',
        :time => 'time',
        :header_canonicalization => 'simple',
        :body_canonicalization => 'simple'
      }

      desired_options.each do |key, value|
        @options.send("#{key}=", value)
      end

      assert_equal(desired_options, @options.options)

      desired_options.each do |key, value|
        assert_equal value, @options.send("#{key}")
      end
    end
  end
end
