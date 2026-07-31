#!/usr/bin/env bash
set -e

CONF="/etc/hermes-dev/install.conf"
mkdir -p /etc/hermes-dev

GPU_PASSTHROUGH="${GPU_PASSTHROUGH:-no}"
GATEWAY_INSTALLED="${GATEWAY_INSTALLED:-no}"
AGENT_REPO_URL="${AGENT_REPO_URL:-}"

ARCH="$(uname -m)"
MODEL="llama3:latest"
INSTALL_DATE="$(date -I)"
INSTALL_VERSION=1
UPDATE_VERSION=1

write_conf() {
cat > "$CONF" <<EOF
GPU_PASSTHROUGH=$GPU_PASSTHROUGH
GATEWAY_INSTALLED=$GATEWAY_INSTALLED
AGENT_REPO_URL=$AGENT_REPO_URL
ARCH=$ARCH
MODEL=$MODEL
INSTALL_DATE=$INSTALL_DATE
INSTALL_VERSION=$INSTALL_VERSION
UPDATE_VERSION=$UPDATE_VERSION
EOF
}

if [ -f "$CONF" ]; then
  # UPDATE MODE
  . "$CONF"

  apt update && apt upgrade -y && apt autoremove -y

  case "$ARCH" in
    x86_64) FILE="herdr-x86_64" ;;
    aarch64|arm64) FILE="herdr-aarch64" ;;
    *) FILE="herdr-x86_64" ;;
  esac

  wget -q https://github.com/herdrdev/herdr/releases/latest/download/$FILE -O /usr/local/bin/herdr
  chmod +x /usr/local/bin/herdr

  pip3 install --upgrade hermes-cli hermes-gateway

  if [ "$GATEWAY_INSTALLED" = "yes" ]; then
    hermes gateway update || true
    systemctl restart hermes-gateway || true
  fi

  if [ -n "$AGENT_REPO_URL" ] && [ -d /opt/hermes-agents ]; then
    git -C /opt/hermes-agents pull || true
  fi

  ollama update || true
  ollama pull "$MODEL" || true

  UPDATE_VERSION=$((UPDATE_VERSION + 1))
  write_conf

  echo "Hermes Dev updated successfully"
  exit 0
fi

# INSTALL MODE
apt update && apt upgrade -y && apt autoremove -y
apt install -y wget curl git python3 python3-pip python3-venv build-essential ca-certificates lsb-release

case "$ARCH" in
  x86_64) FILE="herdr-x86_64" ;;
  aarch64|arm64) FILE="herdr-aarch64" ;;
  *) FILE="herdr-x86_64" ;;
esac

wget https://github.com/herdrdev/herdr/releases/latest/download/$FILE -O /usr/local/bin/herdr
chmod +x /usr/local/bin/herdr

curl -fsSL https://ollama.com/install.sh | sh
sed -i 's/127.0.0.1/0.0.0.0/' /etc/ollama/config.toml || true
systemctl restart ollama
ollama pull "$MODEL"

pip3 install --upgrade pip
pip3 install hermes-cli hermes-gateway

if [ "$GATEWAY_INSTALLED" = "yes" ]; then
  hermes gateway install || true
  hermes gateway start || true
fi

if [ -n "$AGENT_REPO_URL" ]; then
  git clone "$AGENT_REPO_URL" /opt/hermes-agents || true
  if [ -d /opt/hermes-agents ]; then
    hermes agents add /opt/hermes-agents || true
  fi
fi

write_conf

cat > /usr/bin/update << 'EOF'
bash -c "$(curl -fsSL https://raw.githubusercontent.com/TCBWZA/ProxmoxVED/ct/hermes-dev.sh)"
EOF
chmod +x /usr/bin/update

echo "Hermes Dev installed successfully"
exit 0
