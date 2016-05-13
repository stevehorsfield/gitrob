require 'sequel'
require 'gitrob/cli/commands/query/utils'


module Gitrob
  class CLI
    module Commands
      module Query
        class List < Gitrob::CLI::Command
          include Utils

          def initialize(options)
            @options = options
            @separator = Utils::expand_escape_sequences(options[:separator])
            @since = options[:since] == nil ? nil : DateTime.parse(options[:since])

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
            query = query.where('created_at >= ?', @since) unless @since == nil

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
