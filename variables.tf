variable "dry_run" {
  type        = bool
  default     = false
  description = "Toggle to turn off all infras"
  nullable    = false
}

variable "github_token" {
  type      = string
  default   = null
  sensitive = true
}