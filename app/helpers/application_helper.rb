# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # our own markdown function that support coderay
  def markdown text
    result  = String.new
    code    = nil
    lang    = nil
    ln      = nil

    text.split("\n").each do |line|
      if code
        if line =~ /^\s*%end\s*code\s*$/
          result << if lang
                      tokens = CodeRay.scan(code, lang.downcase.to_sym)
                      if ln
                        tokens.div(:line_numbers => :table)
                      else
                        tokens.div
                      end
                    else
                      "<div class=\"code\"><pre>#{code}</pre></div>"
                    end
          code = ln = lang = nil
        else
          code << line << "\n"
        end
      else
        if line =~ /^\s*%code\s/
          if line =~ /\s+lang=(\w+)\s+/
            lang = $1
          end
          if line =~ /\s+ln=(\w+)\s+/ and $1 =~ /yes|true/i
            ln = true
          end
          code = String.new
        else
          result << line << "\n"
        end
      end
    end
    BlueCloth.new(result).to_html
  end
end
