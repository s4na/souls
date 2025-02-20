require "securerandom"

module Souls
  class CLI < Thor
    desc "release", "Release Gem"
    def release
      raise(StandardError, "hey! It's Broken!") unless system("rspec")

      system("gem install souls")
      sleep(3)
      current_souls_ver = Souls::VERSION.strip.split(".").map(&:to_i)
      prompt = TTY::Prompt.new
      choices = [
        "1. Patch(#{Souls.version_detector(current_ver: current_souls_ver, update_kind: 'patch')})",
        "2. Minor(#{Souls.version_detector(current_ver: current_souls_ver, update_kind: 'minor')})",
        "3. Major(#{Souls.version_detector(current_ver: current_souls_ver, update_kind: 'major')})"
      ]
      choice_num = prompt.select("Select Version: ", choices)[0].to_i
      update_kinds = %w[patch minor major]
      update_kind = update_kinds[choice_num - 1]
      souls_new_ver = Souls.version_detector(current_ver: current_souls_ver, update_kind: update_kind)
      status = Paint["Saving Repo...", :yellow]
      Whirly.start(spinner: "clock", interval: 420, stop: "🎉") do
        Whirly.status = status
        %w[api worker].each do |s_name|
          update_service_gemfile(service_name: s_name, version: souls_new_ver)
          result = Paint[update_repo(service_name: s_name, version: souls_new_ver), :green]
          Whirly.status = result
        end
        overwrite_version(new_version: souls_new_ver)
        puts("before add")
        system("git add .")
        puts("before commit")
        system("git commit -m 'souls update v#{souls_new_ver}'")
        puts("before build")
        system("rake build")
        system("rake release")
        write_changelog(current_souls_ver: current_souls_ver)
        system("gh release create v#{souls_new_ver} -t v#{souls_new_ver} -F ./CHANGELOG.md")
        system("gsutil -m -q -o 'GSUtil:parallel_process_count=1' cp -r coverage gs://souls-bucket/souls-coverage")
        system("bundle exec rake upload:init_files")
        Whirly.status = Paint["soul-v#{souls_new_ver} successfully updated!"]
      end
    end

    desc "release_local", "Release gem for local use"
    def release_local
      unless `git status`.include?("nothing to commit")
        raise(
          StandardError,
          "You can only release to local with a clean working directory. Please commit your changes."
        )
      end

      local_dir = "~/.local_souls/"

      system("mkdir -p #{local_dir}")
      souls_local_ver = generate_local_version

      status = Paint["Saving Repo...", :yellow]
      Whirly.start(spinner: "clock", interval: 420, stop: "🎉") do
        Whirly.status = status

        %w[api worker].each do |s_name|
          update_service_gemfile(service_name: s_name, version: souls_local_ver, local: true)
          result = Paint[update_repo(service_name: s_name, version: souls_local_ver), :green]
          Whirly.status = result
        end

        Whirly.status = Paint["Creating local gem..."]

        overwrite_version(new_version: souls_local_ver)
        system("gem build souls.gemspec --output #{local_dir}souls-#{souls_local_ver}.gem")
        system("bundle exec rake upload:init_files")
        Whirly.status = Paint["Done. Created gem at #{local_dir}souls-#{souls_local_ver}.gem"]
        Whirly.status = Paint["Removing previous versions...", :white]
        system("gem uninstall souls -x --force")

        Whirly.status = Paint["Installing local gem..."]
        system("gem install #{local_dir}souls-#{souls_local_ver}.gem")

        Whirly.status = Paint["Cleaning up..."]
        system("git checkout .")
      end
    end

    private

    def write_changelog(current_souls_ver:)
      doc =
        `git -c log.ShowSignature=false log v#{current_souls_ver.join(".")}... \
          --reverse --merges --grep='Merge pull request' --pretty=format:%B`

      md = ""
      doc.each_line do |l|
        md << if l.include?("Merge pull request")
                "### #{l}"
              else
                l
              end
      end
      File.open("./CHANGELOG.md", "w") { |f| f.write(md) }
    end

    def update_repo(service_name: "api", version: "0.0.1")
      current_dir_name = FileUtils.pwd.to_s.match(%r{/([^/]+)/?$})[1]
      bucket_url = "gs://souls-bucket/boilerplates"
      file_name = "#{service_name}-v#{version}.tgz"
      release_name = "#{service_name}-latest.tgz"

      case current_dir_name
      when "souls"
        system("echo '#{version}' > lib/souls/versions/.souls_#{service_name}_version")
        system("echo '#{version}' > apps/#{service_name}/.souls_#{service_name}_version")
        system("cd apps/ && tar -czf ../#{service_name}.tgz #{service_name}/ && cd ..")
      when "api", "worker", "console", "admin", "media"
        system("echo '#{version}' > lib/souls/versions/.souls_#{service_name}_version")
        system("echo '#{version}' > .souls_#{service_name}_version")
        system("cd .. && tar -czf ../#{service_name}.tgz #{service_name}/ && cd #{service_name}")
      else
        raise(StandardError, "You are at wrong directory!")
      end

      system("gsutil cp #{service_name}.tgz #{bucket_url}/#{service_name.pluralize}/#{file_name}")
      system("gsutil cp #{service_name}.tgz #{bucket_url}/#{service_name.pluralize}/#{release_name}")
      system("gsutil cp .rubocop.yml #{bucket_url}/.rubocop.yml")
      FileUtils.rm("#{service_name}.tgz")
      "#{service_name}-v#{version} Succefully Stored to GCS! "
    end

    def update_service_gemfile(service_name: "api", version: "0.0.1", local: false)
      file_dir = "./apps/#{service_name}"
      file_path = "#{file_dir}/Gemfile"

      write_txt = ""
      File.open(file_path, "r") do |f|
        f.each_line do |line|
          gem = line.gsub("gem ", "").gsub("\"", "").gsub("\n", "").gsub(" ", "").split(",")
          write_txt +=
            if gem[0] == "souls"
              if local
                "gem \"souls\", \"#{version}\", path: \"~/.local_souls/\"\n"
              else
                "gem \"souls\", \"#{version}\"\n"
              end
            else
              line
            end
        end
      end
      File.open(file_path, "w") { |f| f.write(write_txt) }

      gemfile_lock = "#{file_dir}/Gemfile.lock"
      FileUtils.rm(gemfile_lock) if File.exist?(gemfile_lock)
      puts(Paint["\nSuccessfully Updated #{service_name} Gemfile!", :green])
    end

    def overwrite_version(new_version: "0.1.1")
      FileUtils.rm("./lib/souls/version.rb")
      file_path = "./lib/souls/version.rb"
      File.open(file_path, "w") do |f|
        f.write(<<~TEXT)
          module Souls
            VERSION = "#{new_version}".freeze
            public_constant :VERSION
          end
        TEXT
      end
      overwrite_gemfile_lock(new_version: new_version)
      true
    rescue StandardError, e
      raise(StandardError, e)
    end

    def overwrite_gemfile_lock(new_version: "0.1.1")
      file_path = "Gemfile.lock"
      new_file_path = "Gemfile.lock.tmp"
      File.open(file_path, "r") do |f|
        File.open(new_file_path, "w") do |new_line|
          f.each_line.with_index do |line, i|
            if i == 3
              new_line.write("    souls (#{new_version})\n")
            else
              new_line.write(line)
            end
          end
        end
      end
      FileUtils.rm(file_path)
      FileUtils.mv(new_file_path, file_path)
    end

    def generate_local_version
      max = 99_999_999_999
      a = SecureRandom.random_number(max) + 9999
      b = SecureRandom.random_number(max)
      c = SecureRandom.random_number(max)

      "#{a}.#{b}.#{c}"
    end
  end
end
