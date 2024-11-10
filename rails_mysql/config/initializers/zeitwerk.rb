Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "graphql" => "GraphQL",
  )
end
