data "http" "labels" {
   url = var.github_labels_source_url
}

locals {
  label_list = csvdecode(data.http.labels.response_body)
  labels = { for label in local.label_list : label.Name => {
    name = label.Name
    color = label.HEX
    description = strcontains(label.Description, ":") ? split(":", split(".",label.Description)[0])[1] : label.Description
  } }
}

resource "github_issue_label" "this" {
  for_each = local.labels

  repository = data.github_repository.this.name
  name       = each.value.name
  color      = each.value.color
  description = substr(each.value.description, 0 , 100)
}
