# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # our own markdown function that support coderay.
  # FIXME: it's ugly.
  def markdown text
    result  = String.new
    code    = nil
    lang    = nil

    text.split("\n").each do |line|
      if code
        if line =~ /^\s*%end\s*code\s*$/
          result << if lang
                      CodeRay.scan(code, lang.downcase.to_sym).div
                    else
                      "<div class=\"code\"><pre>#{code}</pre></div>"
                    end
          code = lang = nil
        else
          code << line << "\n"
        end
      else
        if line =~ /^\s*%code\s/
          if line =~ /\s+lang(?:uage)?=(\w+)\s*/
            lang = $1
          end
          code = String.new
        else
          result << line << "\n"
        end
      end
    end
    BlueCloth.new(result).to_html
  end

  # disable html support in mkd
  def markdown_no_html text
    BlueCloth.new(text, :filter_html).to_html
  end

  # archives url helper
  def archives_url what
    opts = { :controller => :archives, :id => what }
    opts[:action] = case what
                      when Author   then :by_author
                      when Category then :by_category
                      when Tag      then :by_tag
                    end
    opts
  end

  # hack for atom
  def comment_url comment
    post_url comment.post, :anchor => "comment_#{comment.id}"
  end
end
