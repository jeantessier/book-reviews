require "graphql/rake_task"

GraphQL::RakeTask.new(
    load_schema: ->(_task) {
      require File.expand_path("../../config/environment", __dir__)
      RailsMysqlSchema
    },
    directory: "app/graphql",
    idl_outfile: "rails_mysql_schema.graphql",
    json_outfile: "rails_mysql_schema.json",
)
