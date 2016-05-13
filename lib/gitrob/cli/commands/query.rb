require 'sequel'
require 'gitrob/cli/commands/query/utils'
require 'gitrob/cli/commands/query/list'


module Gitrob
  class CLI
    module Commands
      class Query
        

        module Utils
          public
          def expand_escape_sequences(text)
            result = ""
            state = 0
            val = 0
            idx = 0
            for c in text.each_char
              case 
              when state == 0 && c != '\\'
                result = result + c
              when state == 0
                state = 1
              when state == 1 && c == '\\'
                result = result + c
                state = 0
              when state == 1 && c == 'n'
                result = result + "\n"
                state = 0
              when state == 1 && c == 't'
                result = result + "\t"
                state = 0
              when state == 1 && c == 'x'
                idx = 0
                state = 2
              when state == 1
                result = result + '\\' + c
                state = 0
              when state == 2 && idx == 0 && ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'))
                val = c.hex
                idx += 1
              when state == 2 && idx == 1 && ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'))
                val = val * 16 + c.hex
                result = result + val.chr
                state = 0
              when state == 2 && idx == 0
                state = 0
                result = result + "\\x"
              when state == 2
                result = result + val.chr
                state = 0
              end
              
            end
            result
          end
        end

        class List < Gitrob::CLI::Command

          def initialize(options)
            @options = options
            @separator = Utils::expand_escape_sequences(options[:separator])
            @since = options[:since] == nil ? nil : Date.parse(options[:since])

            list_assessments
          end

          private

          def list_assessments
            db = Sequel::Model.db

            query = 
              db[:assessments] 
              .select(:id, :name, :site, :finished, :deleted, :created_at, :updated_at)
              .reverse_order(:id)
            query = query.limit(@options[:limit]) if @options[:limit] > 0
            query = query.where(:finished => @options[:completed]) unless @options[:unfinished]
            query = query.where(:finished => !@options[:unfinished]) unless @options[:completed]
            query = query.where(:id => @options[:id]) unless @options[:id] == -1
            query = query.where{created_at >= @since } unless @since == nil

            columns = ["ID","Name","Site","Finished","Deleted","Created","Updated","\n"]
            print (columns.join(@separator)) if @options[:headers]
            query.all do |row|
              columns = [ row[:id], row[:name], row[:site], row[:deleted], row[:created_at], row[:updated_at], "\n" ]
              print (columns.join(@separator))
            end
          end
          
        end
      end
    end
  end
end
