# Custom hook: enables k9s for all tutorials

# Deploy k9s for each tutorial
sudo -u "${SSH_USER}" bash <<'SCRIPT'
cd "$HOME"
find $HOME/eoepca-killercoda -path "$HOME/eoepca-killercoda/commons" -prune \
  -o -name assets -type d -exec ln -snfr $HOME/eoepca-killercoda/commons/assets/k9s {} \;
SCRIPT
