resource "github_repository_ruleset" "main" {
  name        = "main"
  repository  = data.github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
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

  depends_on = [ github_repository_pull_request.this ]
}
