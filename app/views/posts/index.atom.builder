atom_feed do |feed|
  feed.title('fork while fork')
  feed.updated(@posts.first.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))

  @posts.each do |post|
    feed.entry(post) do |entry|
      entry.title(post.title)
      content = markdown(post.intro) + link_to('Lire la suite...', post)
      entry.content(content, :type => 'html')
       entry.updated(post.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) # needed to work with Google Reader.
      entry.author do |author|
        author.name(post.author.name)
      end
    end
  end
end
