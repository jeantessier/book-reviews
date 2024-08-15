Rails.application.configure do
  if ENV["CI"].present?
    Phobos.configure("config/phobos.ci.yml")
  else
    Phobos.configure("config/phobos.yml")
  end

  group_id = SecureRandom.uuid

  config.after_initialize do
    user_listener = Phobos::Listener.new(
      handler: UserConsumer,
      group_id: group_id,
      topic: "book-reviews.users",
    )

    # start method blocks
    Thread.new { user_listener.start }
  end
end
