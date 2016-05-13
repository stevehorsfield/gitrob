module Gitrob
  class CLI
    module Commands
      module Query

        module Utils
          public
          def self.expand_escape_sequences(text)
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
      end
    end
  end
end
