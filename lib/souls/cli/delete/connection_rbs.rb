module Souls
  class Delete < Thor
    desc "connection_rbs [CLASS_NAME]", "Delete GraphQL Connection RBS"
    def connection_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        singularized_class_name = class_name.underscore.singularize
        file_dir = "./sig/api/app/graphql/types/connections/"
        file_path = "#{file_dir}#{singularized_class_name}_connection.rbs"
        FileUtils.rm_f(file_path)
        puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
      end
      file_path
    end
  end
end
