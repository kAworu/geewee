Factory.sequence :name do |i|
  "Born in #{Time.now - i}"
end

Factory.sequence :email do |i|
  "user#{i}@geewee.net"
end

# Factories
Factory.define :author do |author|
  author.name  { Factory.next(:name) }
  author.email { Factory.next(:email) }
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
