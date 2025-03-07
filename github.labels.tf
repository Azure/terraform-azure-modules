data "http" "labels" {
   url = var.github_labels_source_url
}

locals {
  label_list = csvdecode(data.http.labels.response_body)
}

resource "github_issue_label" "this" {
  for_each = { for value in local.label_list : value.Name => value }

  repository = data.github_repository.this.name
  name       = each.value.Name
  color      = each.value.HEX
  description = substr(each.value.Description, 0 , 100)
}
