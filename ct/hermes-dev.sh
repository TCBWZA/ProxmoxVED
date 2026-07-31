#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/TCBWZA/ProxmoxVED/main/misc/build.func)

APP="Hermes Dev"
var_tags="${var_tags:-ai;updateable;hermes;ollama}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  CTID="$1"
  if [[ -z "$CTID" ]]; then
    msg_error "CTID required for update_script"
    exit 1
  fi

  header_info "$APP - Update"
  msg_info "Running Hermes Dev update inside CT $CTID"
  pct exec "$CTID" -- /usr/bin/update
  msg_ok "Hermes Dev updated"
  exit 0
}

start
build_container
description

msg_info "Pushing Hermes Dev installer into CT $CTID"
pct push "$CTID" install/hermes-dev-install.sh /root/hermes-dev-install.sh -perms 755

msg_info "Running Hermes Dev installer inside CT $CTID"
pct exec "$CTID" -- bash /root/hermes-dev-install.sh

msg_ok "Hermes Dev installation complete"
exit 0
