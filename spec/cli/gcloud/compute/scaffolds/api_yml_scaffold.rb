module Scaffold
  def self.scaffold_api_yml
    <<~APIYML
      name: Mailer

      on:
        push:
          branches:
            - main
          paths:
            - "apps/mailer/**"
            - ".github/workflows/mailer.yml"

      jobs:
        build:

          runs-on: ubuntu-20.04

          services:
            db:
              image: postgres:13
              ports: ["5433:5432"]
              env:
                POSTGRES_PASSWORD: postgres
              options: >-
                --health-cmd pg_isready
                --health-interval 10s
                --health-timeout 5s
                --health-retries 5

          steps:
          - uses: actions/checkout@v2
          - name: Set up Ruby 3.0
            uses: ruby/setup-ruby@v1
            with:
              ruby-version: 3.0
          - name: Build and test with Rake
            env:
              PGHOST: 127.0.0.1
              PGUSER: postgres
              RACK_ENV: test
            run: |
              sudo apt-get -yqq install libpq-dev
              cd apps/mailer
              gem install bundler
              bundle install --jobs 4 --retry 3
              bundle exec rake db:create RACK_ENV=test
              bundle exec rake db:migrate RACK_ENV=test
              bundle exec rspec

          - name: Checkout the repository
            uses: actions/checkout@v2

          - name: GCP Authenticate
            uses: google-github-actions/setup-gcloud@master
            with:
              version: "323.0.0"
              project_id: ${{ secrets.SOULS_GCP_PROJECT_ID }}
              service_account_key: ${{ secrets.SOULS_GCP_SA_KEY }}
              export_default_credentials: true

          - name: Configure Docker
            run: gcloud auth configure-docker --quiet

          - name: Build Docker container
            run: docker build -f ./apps/mailer/Dockerfile ./apps/mailer -t gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-mailer

          - name: Push to Container Resistory
            run: docker push gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-mailer

          - name: Deploy to Cloud Run
            run: |
                gcloud run deploy souls-${{ secrets.SOULS_APP_NAME }}-mailer \\
                  --service-account=${{ secrets.SOULS_APP_NAME }}@${{ secrets.SOULS_GCP_PROJECT_ID }}.iam.gserviceaccount.com \\
                  --image=gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-mailer \\
                  --memory=4Gi \\
                  --region=${{ secrets.SOULS_GCP_REGION }} \\
                  --allow-unauthenticated \\
                  --platform=managed \\
                  --quiet \\
                  --concurrency=80 \\
                  --port=8080 \\
                  --set-cloudsql-instances=${{ secrets.SOULS_GCLOUDSQL_INSTANCE }} \\
                  --set-env-vars="SOULS_DB_USER=${{ secrets.SOULS_DB_USER }}" \\
                  --set-env-vars="SOULS_DB_PW=${{ secrets.SOULS_DB_PW }}" \\
                  --set-env-vars="SOULS_DB_HOST=${{ secrets.SOULS_DB_HOST }}" \\
                  --set-env-vars="TZ=${{ secrets.TZ }}" \\
                  --set-env-vars="SOULS_SECRET_KEY_BASE=${{ secrets.SOULS_SECRET_KEY_BASE }}" \\
                  --set-env-vars="SOULS_PROJECT_ID=${{ secrets.SOULS_GCP_PROJECT_ID }}"
    APIYML
  end

  def self.scaffold_api_yml_api
    <<~APIYML
      name: Mailer

      on:
        push:
          branches:
            - main
          paths:
            - "apps/mailer/**"
            - ".github/workflows/mailer.yml"

      jobs:
        build:

          runs-on: ubuntu-20.04

          services:
            db:
              image: postgres:13
              ports: ["5433:5432"]
              env:
                POSTGRES_PASSWORD: postgres
              options: >-
                --health-cmd pg_isready
                --health-interval 10s
                --health-timeout 5s
                --health-retries 5

          steps:
          - uses: actions/checkout@v2
          - name: Set up Ruby 3.0
            uses: ruby/setup-ruby@v1
            with:
              ruby-version: 3.0
          - name: Build and test with Rake
            env:
              PGHOST: 127.0.0.1
              PGUSER: postgres
              RACK_ENV: test
            run: |
              sudo apt-get -yqq install libpq-dev
              cd apps/mailer
              gem install bundler
              bundle install --jobs 4 --retry 3
              bundle exec rake db:create RACK_ENV=test
              bundle exec rake db:migrate RACK_ENV=test
              bundle exec rspec

          - name: Checkout the repository
            uses: actions/checkout@v2

          - name: GCP Authenticate
            uses: google-github-actions/setup-gcloud@master
            with:
              version: "323.0.0"
              project_id: ${{ secrets.SOULS_GCP_PROJECT_ID }}
              service_account_key: ${{ secrets.SOULS_GCP_SA_KEY }}
              export_default_credentials: true

          - name: Configure Docker
            run: gcloud auth configure-docker --quiet

          - name: Build Docker container
            run: docker build -f ./apps/mailer/Dockerfile ./apps/mailer -t gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-mailer

          - name: Push to Container Resistory
            run: docker push gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-mailer

          - name: Deploy to Cloud Run
            run: |
                gcloud run deploy souls-${{ secrets.SOULS_APP_NAME }}-mailer \\
                  --service-account=${{ secrets.SOULS_APP_NAME }}@${{ secrets.SOULS_GCP_PROJECT_ID }}.iam.gserviceaccount.com \\
                  --image=gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-mailer \\
                  --memory=4Gi \\
                  --vpc-connector=app-connector \\
                  --region=${{ secrets.SOULS_GCP_REGION }} \\
                  --allow-unauthenticated \\
                  --platform=managed \\
                  --quiet \\
                  --concurrency=80 \\
                  --port=8080 \\
                  --set-cloudsql-instances=${{ secrets.SOULS_GCLOUDSQL_INSTANCE }} \\
                  --set-env-vars="SOULS_DB_USER=${{ secrets.SOULS_DB_USER }}" \\
                  --set-env-vars="SOULS_DB_PW=${{ secrets.SOULS_DB_PW }}" \\
                  --set-env-vars="SOULS_DB_HOST=${{ secrets.SOULS_DB_HOST }}" \\
                  --set-env-vars="TZ=${{ secrets.TZ }}" \\
                  --set-env-vars="SOULS_SECRET_KEY_BASE=${{ secrets.SOULS_SECRET_KEY_BASE }}" \\
                  --set-env-vars="SOULS_PROJECT_ID=${{ secrets.SOULS_GCP_PROJECT_ID }}"
    APIYML
  end

  def self.scaffold_api_yml_worker
    <<~APIYML
      name: Mailer

      on:
        push:
          branches:
            - main
          paths:
            - "apps/mailer/**"
            - ".github/workflows/mailer.yml"

      jobs:
        build:

          runs-on: ubuntu-20.04

          services:
            db:
              image: postgres:13
              ports: ["5433:5432"]
              env:
                POSTGRES_PASSWORD: postgres
              options: >-
                --health-cmd pg_isready
                --health-interval 10s
                --health-timeout 5s
                --health-retries 5

          steps:
          - uses: actions/checkout@v2
          - name: Set up Ruby 3.0
            uses: ruby/setup-ruby@v1
            with:
              ruby-version: 3.0
          - name: Build and test with Rake
            env:
              PGHOST: 127.0.0.1
              PGUSER: postgres
              RACK_ENV: test
            run: |
              sudo apt-get -yqq install libpq-dev
              cd apps/mailer
              gem install bundler
              bundle install --jobs 4 --retry 3
              bundle exec rake db:create RACK_ENV=test
              bundle exec rake db:migrate RACK_ENV=test
              bundle exec rspec

          - name: Checkout the repository
            uses: actions/checkout@v2

          - name: GCP Authenticate
            uses: google-github-actions/setup-gcloud@master
            with:
              version: "323.0.0"
              project_id: ${{ secrets.SOULS_GCP_PROJECT_ID }}
              service_account_key: ${{ secrets.SOULS_GCP_SA_KEY }}
              export_default_credentials: true

          - name: Configure Docker
            run: gcloud auth configure-docker --quiet

          - name: Build Docker container
            run: docker build -f ./apps/mailer/Dockerfile ./apps/mailer -t gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-mailer

          - name: Push to Container Resistory
            run: docker push gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-mailer

          - name: Deploy to Cloud Run
            run: |
                gcloud run deploy souls-${{ secrets.SOULS_APP_NAME }}-mailer \\
                  --service-account=${{ secrets.SOULS_APP_NAME }}@${{ secrets.SOULS_GCP_PROJECT_ID }}.iam.gserviceaccount.com \\
                  --image=gcr.io/${{ secrets.SOULS_GCP_PROJECT_ID }}/${{secrets.SOULS_APP_NAME}}-mailer \\
                  --memory=4Gi \\
                  --vpc-connector=app-connector \\
                  --vpc-egress=all \\
                  --region=${{ secrets.SOULS_GCP_REGION }} \\
                  --allow-unauthenticated \\
                  --platform=managed \\
                  --quiet \\
                  --concurrency=80 \\
                  --port=8080 \\
                  --set-cloudsql-instances=${{ secrets.SOULS_GCLOUDSQL_INSTANCE }} \\
                  --set-env-vars="SOULS_DB_USER=${{ secrets.SOULS_DB_USER }}" \\
                  --set-env-vars="SOULS_DB_PW=${{ secrets.SOULS_DB_PW }}" \\
                  --set-env-vars="SOULS_DB_HOST=${{ secrets.SOULS_DB_HOST }}" \\
                  --set-env-vars="TZ=${{ secrets.TZ }}" \\
                  --set-env-vars="SOULS_SECRET_KEY_BASE=${{ secrets.SOULS_SECRET_KEY_BASE }}" \\
                  --set-env-vars="SOULS_PROJECT_ID=${{ secrets.SOULS_GCP_PROJECT_ID }}"
    APIYML
  end
end
