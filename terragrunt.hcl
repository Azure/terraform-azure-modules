retry_max_attempts       = 60
retry_sleep_interval_sec = 60
retryable_errors         = [
  ".*read: connection reset by peer.*",
  ".*transport is closing.*",
  // `terraform init` frequently fails in CI due to network issues accessing plugins. The reason is unknown, but
  // eventually these succeed after a few retries.
  ".*unable to verify signature.*",
  ".*unable to verify checksum.*",
  ".*no provider exists with the given name.*",
  ".*registry service is unreachable.*",
  ".*Error installing provider.*",
  ".*Failed to query available provider packages.*",
  ".*timeout while waiting for plugin to start.*",
  ".*timed out waiting for server handshake.*",
  ".*could not query provider registry for.*",
  ".*Error acquiring the state lock.*"
]
