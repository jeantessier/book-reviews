Rails.application.configure do
  if ENV["CI"].present?
    Phobos.configure("config/phobos.ci.yml")
  else
    Phobos.configure("config/phobos.yml")
  end

  group_id = SecureRandom.uuid

  config.after_initialize do
    book_listener = Phobos::Listener.new(
      handler: BookConsumer,
      group_id:,
      topic: "book-reviews.books",
    )

    # start method blocks
    Thread.new { book_listener.start }
  end
end
