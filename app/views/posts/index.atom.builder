atom_feed do |feed|
  feed.title h(GeeweeConfig.entry.blogtitle)
  feed.updated(@posts.first.try(:updated_at) || Time.now)

  @posts.each do |post|
    feed.entry(post) do |entry|
      entry.title(h post.title)
      content = markdown(post.intro) + link_to(t('posts.read_more') + '...', post_url(post))
      entry.content(content, :type => 'html')
      entry.author do |author|
        author.name(post.author.name)
      end
    end
  end
end
