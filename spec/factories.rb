# FactoryGirl <3
Factory.define :author do |author|
  author.name  { Factory.next :author_name }
  author.email { Factory.next :email       }
end

Factory.define :page do |page|
  page.title { Factory.next :title   }
  page.body  { Factory.next :content }
end

Factory.define :category do |category|
  category.display_name { Factory.next :category_name }
end

Factory.define :post do |post|
  post.title       { Factory.next :title   }
  post.intro       { Factory.next :content }
  post.association :author
  post.association :category
end

Factory.define :comment do |comment|
  comment.name  { 'fake ' + Factory.next(:author_name) }
  comment.email { Factory.next :email   }
  comment.body  { Factory.next :content }
  comment.association :post
end

Factory.define :geewee_config do |cfg|
  cfg.bloguri       'http://localhost/'
  cfg.blogtitle     'Geewee'
  cfg.blogsubtitle  'is sweet'
  cfg.locale        'en'
  cfg.use_recaptcha false
  cfg.recaptcha_public_key  nil
  cfg.recaptcha_private_key nil
  cfg.post_count_per_page   2
end

# Sequences, boring stuff.
Factory.sequence :author_name do |i|
  # thanks http://en.wikipedia.org/wiki/List_of_software_authors
  case i
  when 1 then 'Alan Turing'
  when 2 then 'C.A.R. Hoare'
  when 3 then 'Grace Hopper'
  when 4 then 'Ada Lovelace'
  when 5 then 'Christopher Strachey'
  when 6 then 'John Backus'
  when 7 then 'Niklaus Wirth'
  else        "Author ##{i}"
  end
end

Factory.sequence :category_name do |i|
  case i
  when 1 then 'Programming'
  when 2 then 'Folklor'
  when 3 then 'Buddhism'
  when 4 then 'Business'
  when 5 then 'Children'
  when 6 then 'Crime'
  when 7 then 'Thriller'
  else        "Category #{i}"
  end
end

Factory.sequence :email do |i|
  "user#{i}@geewee.net"
end

Factory.sequence :title do |i|
  case i
  when 1 then 'roses are red'
  when 2 then 'violets are blue'
  when 3 then 'cucumber is sweet'
  when 4 then 'and so are you'
  else        "Title #{i}"
  end
end

Factory.sequence :content do |i|
  case i
  when 1 then 'Time it was and what a time it was it was,'
  when 2 then 'A time of innocence a time of confidences.'
  when 3 then 'Long ago it must be, I have a photograph'
  when 4 then "Preserve your memories, they're all that's left you"

  else        "This is a very dummy content for the #{i}th time"
  end
end
