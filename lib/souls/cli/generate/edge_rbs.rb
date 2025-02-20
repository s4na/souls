module Souls
  class Generate < Thor
    desc "edge_rbs [CLASS_NAME]", "Generate GraphQL Edge RBS from schema.rb"
    def edge_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/types/edges/"
        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}_edge.rbs"
        File.open(file_path, "w") do |f|
          f.write(<<~TEXT)
            module Types
              class #{singularized_class_name.camelize}Edge < BaseObject
                def self.edge_type: (*untyped) -> untyped
                def self.node_type: (*untyped) -> untyped
                def self.global_id_field: (*untyped) -> untyped
                def self.connection_type: ()-> untyped
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
