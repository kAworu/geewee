# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # our own markdown function that support coderay
  def markdown text
    result  = String.new
    code    = nil
    lang    = nil

    text.split("\n").each do |line|
      if lang
        if line =~ /^\s*%end\s*code\s*$/
          result << CodeRay.scan(code, lang).div
          lang = nil
        else
          code << line << "\n"
        end
      else
        if line =~ /^\s*%code\s+(\w+)\s*$/
          lang = $1
          code = String.new
        else
          result << line << "\n"
        end
      end
    end
    BlueCloth.new(result).to_html
  end
end
