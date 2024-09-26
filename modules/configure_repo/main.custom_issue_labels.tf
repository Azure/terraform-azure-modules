#get the labels csv
data "http" "labels" {
    url = var.labels_download_url
}

locals {
  label_list = csvdecode(data.http.labels.response_body)
}

resource "github_issue_label" "test_repo" {
  for_each = { for value in local.label_list : value.Name => value }

  repository = data.github_repository.this.name
  name       = each.value.Name
  color      = each.value.HEX
  description = substr(each.value.Description, 0 , 100)

  depends_on = [ data.github_repository.this ]
}