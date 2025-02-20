require_relative "./scaffolds/scaffold_resolver_rbs"

RSpec.describe(Souls::Generate) do
  describe "Generate Resolver RBS" do
    let(:class_name) { "user" }

    before do
      FakeFS do
        @file_dir = "./sig/api/app/graphql/resolvers/"
        FileUtils.mkdir_p(@file_dir) unless Dir.exist?(@file_dir)
      end
    end

    it "creates resolver.rbs file" do
      file_path = "#{@file_dir}#{class_name.singularize}_search.rbs"
      FakeFS.activate!
      generate = Souls::Generate.new
      generate.options = { mutation: class_name }
      allow(Souls).to(receive(:get_mother_path).and_return(""))
      allow(FileUtils).to(receive(:pwd).and_return("api"))
      a1 = generate.resolver_rbs(class_name)
      file_output = File.read(file_path)

      expect(a1).to(eq(file_path))
      expect(File.exist?(file_path)).to(eq(true))
      FakeFS.deactivate!

      expect(file_output).to(eq(Scaffold.scaffold_resolver_rbs))
    end
  end
end
