atom_feed do |feed|
  feed.title('Commentaires sur: ' + h(@post.title))
  feed.updated(@post.comments.last.created_at)

  @post.comments.each do |comment|
    feed.entry(comment) do |entry|
      entry.title('Par :' + comment.name)
      entry.content(markdown_no_html(comment.body), :type => 'html')
    end
  end
end
