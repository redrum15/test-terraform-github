terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "github" {
  owner = "redrum15"
}


resource "github_repository" "test" {
  name             = "test-terraform-github"
  description      = "test for terraform github provider"
  license_template = "mit"

  visibility = "public"
}

# resource "github_branch" "development" {
#   repository = github_repository.test.name
#   branch     = "development"
# }


# resource "github_branch_protection" "protect_devel" {
#   repository_id = github_repository.test.node_id
#   pattern       = "devel"

#   required_pull_request_reviews {
#     dismiss_stale_reviews           = true
#     required_approving_review_count = 1
#   }

#   enforce_admins = true

#   allows_deletions    = false
#   allows_force_pushes = false
# }


resource "github_branch_protection" "protect_stage" {
  repository_id = github_repository.test.node_id
  pattern       = "devel"

  required_status_checks {
    strict   = true
    contexts = ["CI Pipeline / build (pull_request)"]
  }

  enforce_admins      = true
  allows_force_pushes = false
  allows_deletions    = false
}
