#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment to enable stub debug output:
# export CURL_STUB_DEBUG=/dev/tty
# export MKDIR_STUB_DEBUG=/dev/tty
# export TAR_STUB_DEBUG=/dev/tty
# export RM_STUB_DEBUG=/dev/tty

@test "Download plugin" {
  export BUILDKITE_PLUGIN_TERRAFORM_PROVIDER_DEBUG="true"
  export BUILDKITE_PLUGIN_TERRAFORM_PROVIDER_REPO="jianyuan/terraform-provider-sentry"
  export BUILDKITE_PLUGIN_TERRAFORM_PROVIDER_VERSION="0.4.0"

  stub curl \
    "-sL https://api.github.com/repos/jianyuan/terraform-provider-sentry/releases : cat tests/fixtures/releases.json" \
    "-L https://github.com/jianyuan/terraform-provider-sentry/releases/download/v0.4.0/terraform-provider-sentry_0.4.0_linux_amd64.tar.gz -o /tmp/terraform-provider-sentry_0.4.0.tar.gz : touch /tmp/terraform-provider-sentry_0.4.0.tar.gz"
  stub jq \
    "-r : cat tests/fixtures/releases.txt"
  stub mkdir \
    "-p $HOME/.terraform.d/plugins : "
  stub tar \
    "-xzf /tmp/terraform-provider-sentry_0.4.0.tar.gz -C : "

  run "$PWD/hooks/pre-command"

  assert_output --partial "Getting"
  assert_output --partial "Downloading"
  assert_output --partial "Installed"
  assert_success
  unstub curl
  unstub mkdir
  unstub tar
}
