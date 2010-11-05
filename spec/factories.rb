Factory.sequence :name do |i|
  "Born in #{Time.now.year - i}"
end

Factory.sequence :email do |i|
  "user#{i}@geewee.net"
end

# Factories
Factory.define :author do |author|
  author.name  { Factory.next(:name) }
  author.email { Factory.next(:email) }
end

Factory.define :page do |page|
  page.title { Factory.next(:name) }
  page.body  'Sexy body!'
end

Factory.define :category do |category|
  category.display_name { Factory.next(:name) }
end

Factory.define :post do |post|
  post.title       "geewee is rspec'd!"
  post.intro       'Well, at least we try.'
  post.association :author
  post.association :category
end

Factory.define :comment do |post|
  post.name  { Factory.next(:name) }
  post.email { Factory.next(:email) }
  post.body  'MOAR'
  post.association :post
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
