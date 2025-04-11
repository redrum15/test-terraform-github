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



resource "aws_cloudfront_distribution" "test" {
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    target_origin_id = aws_s3_bucket.b.bucket_regional_domain_name


    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  origin {
    domain_name              = aws_s3_bucket.b.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = aws_s3_bucket.b.bucket_regional_domain_name
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


resource "aws_cloudfront_origin_access_control" "example" {
  name                              = "example"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
