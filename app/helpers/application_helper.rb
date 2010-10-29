# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # from acts_as_taggable_on_steroids
  include TagsHelper

  # our own markdown function that support coderay.
  # FIXME: it's ugly.
  def markdown text
    result  = String.new
    code    = nil
    lang    = nil
    opts    = nil

    text.split("\n").each do |line|
      if code
        if line =~ /^%\/code\s*$/
          lang ||= '__none__'
          tokens = CodeRay.scan(code, lang.downcase.to_sym)
          result << tokens.div(opts)
          code = lang = nil
        else
          code << line << "\n"
        end
      else
        if line =~ /^%code\b/
          opts = Hash.new
          if line =~ /\s+lang(?:uage)?=(\w+)\b/
            lang = $1
          end
          if line =~ /\s+(?:ln|line_numbers)=(\w+)\b/
            if %[table inline list].include?($1)
              opts[:line_numbers] = $1.to_sym
            end
          end
          if line =~ /\s+(?:tw|tab_width)=(\d+)\b/
            opts[:tab_width] = $1.to_i
          end
          code = String.new
        else
          result << line << "\n"
        end
      end
    end
    BlueCloth.new(result).to_html
  end

  # disable html support in mkd, used to render comments.
  def markdown_no_html text
    BlueCloth.new(text, :filter_html).to_html
  end

  # hack for atom
  def comment_url comment
    post_url comment.post, :anchor => "comment_#{comment.id}"
  end

  # guess the <title> of the page.
  def html_title
    if defined?(@post)
      @post.title
    elsif defined?(@page)
      @page.title
    else
      nil
    end
  end

  # translate and create a true sentance for
  # time_ago_in_word.
  def time_ago_sentance time
    t('time_ago', :time => time_ago_in_words(time))
  end


  # helper to display the comment count. Choose the right key to translate.
  def comments_count count
    case count
    when 0 then t('meta.no_comments')
    when 1 then t('meta.one_comment')
    else        "#{number_to_word(count)} #{t 'meta.comments'}"
    end
  end

  # translate a number into word. see http://pine.fm/LearnToProgram/?Chapter=08.
  # we only need to handle number > 1.
  #
  # XXX: this implementation sucks when number >= 1000 (as explainted in the
  #      link). It's our own version of the "year 2000 bug". If it happens
  #      sometimes, fixing it will be easy though ;)
  def number_to_word number
    numString = ''  #  This is the string we will return.

    #  "left" is how much of the number we still have left to write out.
    #  "write" is the part we are writing out right now.
    #  write and left... get it?  :)
    left  = number
    write = left / 100          #  How many hundreds left to write out?
    left  = left - write * 100  #  Subtract off those hundreds.

    if write > 0
      if write == 1
        numString << t('numbers.one_hundred')
      else
        #  Now here's a really sly trick:
        hundreds   = number_to_word(write)
        #  That's called "recursion".  So what did I just do?
        #  I told this method to call itself, but with "write" instead of
        #  "number".  Remember that "write" is (at the moment) the number of
        #  hundreds we have to write out.  After we add "hundreds" to "numString",
        #  we add the string ' hundred' after it.  So, for example, if
        #  we originally called englishNumber with 1999 (so "number" = 1999),
        #  then at this point "write" would be 19, and "left" would be 99.
        #  The laziest thing to do at this point is to have englishNumber
        #  write out the 'nineteen' for us, then we write out ' hundred',
        #  and then the rest of englishNumber writes out 'ninety-nine'.
        numString << hundreds + ' ' + (left.zero? ? t('numbers.100s') : t('numbers.100'))
      end

      if left > 0
        #  So we don't write 'two hundredfifty-one'...
        numString << ' '
      end
    end

    write = left / 10          #  How many tens left to write out?
    left  = left - write * 10  #  Subtract off those tens.

    if write > 0
      if write == 1 and left > 0
        #  Since we can't write "tenty-two" instead of "twelve",
        #  we have to make a special exception for these.
        numString << t("numbers.#{10 + left}")

        #  Since we took care of the digit in the ones place already,
        #  we have nothing left to write.
        left = 0
      else
        numString << t("numbers.#{write * 10}")
      end

      if left > 0
        #  So we don't write 'sixtyfour'...
        numString << (left == 1 ? t('numbers.dozen_to_one_sep') : t('numbers.dozen_to_digit_sep'))
      end
    end

    write = left  #  How many ones left to write out?
    left  = 0     #  Subtract off those ones.

    if write > 0
      numString << t("numbers.#{write}")
    end

    #  Now we just return "numString"...
    numString
  end
end
