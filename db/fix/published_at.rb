# run it with script/runner
# set published_at to created_at for all posts in db!

Post.all.each do |p|
    p.published_at = p.created_at
    p.save!
end
