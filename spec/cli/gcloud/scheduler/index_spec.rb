RSpec.describe(Souls::CloudScheduler) do
  describe "awake" do
    before :each do
      allow($stdout).to(receive(:write))
    end

    it "should set ping every 15 minutes" do
      cli = Souls::CloudScheduler.new
      allow(Souls.configuration).to(receive(:app).and_return("test-app"))
      allow_any_instance_of(Souls::CloudScheduler).to(receive(:system).and_return(true))
      expect_any_instance_of(Souls::CloudScheduler).to(
        receive(:system).with(
          "gcloud scheduler jobs create http test-app-awake
            --schedule '0,10,20,30,40,50 * * * *' --uri abc.com --http-method GET"
        )
      )

      expect(cli.invoke(:awake, [], { url: "abc.com" })).to(eq(true))
    end
  end
end
