resource "github_repository_ruleset" "main" {
  name        = "main"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH", "refs/heads/main"]
      exclude = []
    }
  }

  rules {

    creation                = true #allow no-one to create main?
    deletion                = true #restrict deletion of main to users with bypass (no-one)?
    required_linear_history = true
    non_fast_forward = true #no force pushes

    pull_request {
      dismiss_stale_reviews_on_push = true
      require_code_owner_review = true 
      required_approving_review_count = 0      
    }
  }
}