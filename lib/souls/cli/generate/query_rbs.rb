module Souls
  class Generate < Thor
    desc "query_rbs [CLASS_NAME]", "Generate GraphQL Query RBS"
    def query_rbs(class_name)
      single_query_rbs(class_name)
      queries_rbs(class_name)
    end

    private

    def single_query_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/queries/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Queries
              class BaseQuery
              end
              class #{singularized_class_name.camelize} < Queries::BaseQuery
                def resolve:  ({
                                id: String?
                              }) -> ( Hash[Symbol, ( String | Integer | bool )] | ::GraphQL::ExecutionError )

                def self.argument: (*untyped) -> String
                def self.type: (*untyped) -> String
              end
            end
          TEXT
        end
        puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      end
      file_path
    end

    def queries_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/queries/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        pluralized_class_name = class_name.underscore.pluralize
        file_path = "#{file_dir}#{pluralized_class_name}.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Queries
              class BaseQuery
              end
              class #{pluralized_class_name.camelize} < Queries::BaseQuery
                def resolve:  () -> ( Hash[Symbol, ( String | Integer | bool )] | ::GraphQL::ExecutionError)
                def self.type: (*untyped) -> String
              end
            end
          TEXT
        end
        puts(Paint % ["Created file! : %{white_text}", :green, { white_text: [file_path.to_s, :white] }])
      end
      file_path
    end
  end
end
