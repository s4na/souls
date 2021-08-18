module Types
  class MutationType < Types::BaseObject
    workers =
      Dir["./app/graphql/mutations/*.rb"].map do |file|
        file.gsub("./app/graphql/mutations/", "").gsub(".rb", "")
      end
    workers.each do |worker|
      field worker.underscore.to_s.to_sym,
            mutation: Object.const_get("Mutations::#{worker.singularize.camelize}")
    end
    mailers =
      Dir["./app/graphql/mutations/mailers/*.rb"].map do |file|
        file.gsub("./app/graphql/mutations/mailers/", "").gsub(".rb", "")
      end
    mailers.each do |mailer|
      field mailer.underscore.to_s.to_sym,
            mutation: Object.const_get("Mutations::Mailers::#{mailer.singularize.camelize}")
    end
  end
end
