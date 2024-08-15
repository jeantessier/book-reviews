Rails.application.configure do
  Phobos.configure("config/phobos.yml")

  group_id = SecureRandom.uuid

  config.after_initialize do
    review_listener = Phobos::Listener.new(
      handler: ReviewConsumer,
      group_id: group_id,
      topic: "book-reviews.reviews",
    )

    book_and_user_listener = Phobos::Listener.new(
      handler: BookAndUserConsumer,
      group_id: "reviews",
      topic: /book-reviews.(books|users)/,
    )

    # start method blocks
    Thread.new { review_listener.start }
    Thread.new { book_and_user_listener.start }
  end
end
