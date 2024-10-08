#--
# Copyright (c) 2017 Michael Berkovich, theiceberk@gmail.com
#
#  __    __  ____  _      _          _____  ____  _     ______    ___  ____
# |  |__|  ||    || |    | |        |     ||    || |   |      |  /  _]|    \
# |  |  |  | |  | | |    | |        |   __| |  | | |   |      | /  [_ |  D  )
# |  |  |  | |  | | |___ | |___     |  |_   |  | | |___|_|  |_||    _]|    /
# |  `  '  | |  | |     ||     |    |   _]  |  | |     | |  |  |   [_ |    \
#  \      /  |  | |     ||     |    |  |    |  | |     | |  |  |     ||  .  \
#   \_/\_/  |____||_____||_____|    |__|   |____||_____| |__|  |_____||__|\_|
#
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module WillFilter
  module Containers
    class Json < WillFilter::FilterContainer
      def self.operators
        [:is, :is_in, :is_less_than, :is_greater_than, :is_in_ancestry]
      end

      def template_name
        'json'
      end

      def validate
        # no validation is necessary
      end

      def sql_condition
        return [" JSON_EXTRACT(#{json_key_split[0]}, '$.#{json_key_split[1]}') = JSON_EXTRACT(?,'$') ", json_value] if operator == :is
        return [" JSON_OVERLAPS(JSON_EXTRACT(#{json_key_split[0]}, '$.#{json_key_split[1]}'), ? )",json_in_value] if operator == :is_in
        return [" JSON_OVERLAPS(JSON_EXTRACT(#{json_key_split[0]}, '$.#{json_key_split[1]}'), ? )",fetch_by_ancestry] if operator == :is_in_ancestry
        return [" JSON_EXTRACT(#{json_key_split[0]}, '$.#{json_key_split[1]}') < JSON_EXTRACT(?,'$') ", json_value] if operator == :is_less_than
        return [" JSON_EXTRACT(#{json_key_split[0]}, '$.#{json_key_split[1]}') > JSON_EXTRACT(?,'$') ", json_value] if operator == :is_greater_than
      end

      def json_key_split
        condition.key.to_s.split('.')
      end

      def json_value
        value.to_i
      end

      def json_in_value
        "[#{value}]"
      end

      def fetch_by_ancestry
        values = self.filter.model_class_name.constantize.fetch_by_ancestry(value)
        "[#{values}]"
      end
    end
  end
end