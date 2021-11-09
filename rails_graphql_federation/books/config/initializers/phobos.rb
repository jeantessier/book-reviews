Rails.application.configure do
  Phobos.configure('config/phobos.yml')

  group_id = SecureRandom.uuid

  config.after_initialize do
    book_listener = Phobos::Listener.new(
      handler: BookConsumer,
      group_id: group_id,
      topic: 'book-reviews.books'
    )

    # start method blocks
    Thread.new { book_listener.start }
  end
end
