require_relative "./iam/index"
require_relative "./pubsub/index"
require_relative "./run/index"
require_relative "./sql/index"
require_relative "./compute/index"
require_relative "./scheduler/index"
require_relative "../cli_exception"

module Souls
  class Gcloud < Thor
    desc "iam [COMMAND]", "souls gcloud iam Commands"
    subcommand "iam", Iam

    desc "pubsub [COMMAND]", "souls gcloud pubsub Commands"
    subcommand "pubsub", Pubsub

    desc "sql [COMMAND]", "souls gcloud sql Commands"
    subcommand "sql", Sql

    desc "compute [COMMAND]", "souls gcloud compute Commands"
    subcommand "compute", Compute

    desc "run [COMMAND]", "souls gcloud run Commands"
    subcommand "cloud_run", CloudRun

    desc "scheduler [COMMAND]", "souls gcloud schedluer Commands"
    subcommand "scheduler", CloudScheduler

    map run: "cloud_run"

    desc "auth_login", "gcloud config set and gcloud auth login"
    def auth_login
      project_id = Souls.configuration.project_id
      system("gcloud projects describe #{project_id}", out: File::NULL) or raise(Souls::GcloudException)
      system("gcloud config set project #{project_id} >/dev/null 2>&1")
      system("gcloud auth login")
    end

    desc "config_set", "gcloud config set"
    def config_set
      project_id = Souls.configuration.project_id
      system("gcloud projects describe #{project_id}", out: File::NULL) or raise(Souls::GcloudException)
      system("gcloud config set project #{project_id} >/dev/null 2>&1")
    end

    desc "enable_permissions", "Enable Google Cloud APIs for SOULs Framework"
    def enable_permissions
      system("gcloud services enable compute.googleapis.com")
      system("gcloud services enable iam.googleapis.com")
      system("gcloud services enable dns.googleapis.com")
      system("gcloud services enable sqladmin.googleapis.com")
      system("gcloud services enable sql-component.googleapis.com")
      system("gcloud services enable servicenetworking.googleapis.com")
      system("gcloud services enable containerregistry.googleapis.com")
      system("gcloud services enable run.googleapis.com")
      system("gcloud services enable vpcaccess.googleapis.com")
      system("gcloud services enable cloudscheduler.googleapis.com")
    end
  end
end
