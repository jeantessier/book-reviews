Rails.application.configure do
  Phobos.configure('config/phobos.yml')

  group_id = SecureRandom.uuid

  config.after_initialize do
    indexing_listener = Phobos::Listener.new(
      handler: IndexingConsumer,
      group_id: group_id,
      topic: /book-reviews.(books|reviews|users)/
    )

    # start method blocks
    Thread.new { indexing_listener.start }
  end
end
