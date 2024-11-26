Rails.application.configure do
  if ENV["CI"].present?
    Phobos.configure("config/phobos.ci.yml")
  else
    Phobos.configure("config/phobos.yml")
  end

  group_id = SecureRandom.uuid

  config.after_initialize do
    indexing_listener = Phobos::Listener.new(
      handler: IndexingConsumer,
      group_id:,
      topic: /book-reviews.(books|reviews|users)/,
    )

    # start method blocks
    Thread.new { indexing_listener.start }
  end
end
