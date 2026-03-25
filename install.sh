#!/bin/bash

set -e

DOTFILES_DIR="$HOME/ghq/github.com/nkoji21/dotfiles"

echo "========================================="
echo "  Dotfiles Setup"
echo "========================================="
echo ""

# Check Homebrew
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed."
    echo "Please install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "✓ Homebrew found"

# Install mise if not installed
if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    brew install mise
else
    echo "✓ mise found"
fi

# Install aqua if not installed
if ! command -v aqua &> /dev/null; then
    echo "Installing aqua..."
    brew install aqua
else
    echo "✓ aqua found"
fi

echo ""
echo "Creating symlinks..."

# Create directories if not exist
mkdir -p ~/.config/mise
mkdir -p ~/.config/aqua
mkdir -p ~/.config/ghostty/themes
mkdir -p ~/.config/sheldon
mkdir -p ~/.local/share/sheldon
mkdir -p ~/.cursor
mkdir -p ~/.claude
mkdir -p ~/.codex

# Symlink home directory files
ln -sfn "$DOTFILES_DIR/.gitconfig" ~/.gitconfig
ln -sfn "$DOTFILES_DIR/.zshenv" ~/.zshenv
ln -sfn "$DOTFILES_DIR/.zshrc" ~/.zshrc
ln -sfn "$DOTFILES_DIR/.zprofile" ~/.zprofile
ln -sfn "$DOTFILES_DIR/.cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"

# Symlink .cursor files
ln -sfn "$DOTFILES_DIR/.cursor/commands" ~/.cursor/commands
ln -sfn "$DOTFILES_DIR/.cursor/rules" ~/.cursor/rules
ln -sfn "$DOTFILES_DIR/.cursor/skills" ~/.cursor/skills

# Symlink .claude files
ln -sfn "$DOTFILES_DIR/.claude/skills" ~/.claude/skills

# Symlink .codex skills individually (cannot symlink the whole dir as ~/.codex is managed by Codex)
for skill_dir in "$DOTFILES_DIR/.agents/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    ln -sfn "$skill_dir" ~/.codex/skills/"$skill_name"
done

# Symlink .config subdirectories
ln -sfn "$DOTFILES_DIR/mise/config.toml" ~/.config/mise/config.toml
ln -sfn "$DOTFILES_DIR/aqua/aqua.yaml" ~/.config/aqua/aqua.yaml
ln -sfn "$DOTFILES_DIR/aqua/aqua-checksums.json" ~/.config/aqua/aqua-checksums.json
ln -sfn "$DOTFILES_DIR/aqua/imports" ~/.config/aqua/imports
ln -sfn "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config
ln -sfn "$DOTFILES_DIR/ghostty/themes/kanagawa-wave" ~/.config/ghostty/themes/kanagawa-wave
ln -sfn "$DOTFILES_DIR/sheldon/plugins.toml" ~/.config/sheldon/plugins.toml
ln -sfn "$DOTFILES_DIR/sheldon/plugins.lock" ~/.local/share/sheldon/plugins.lock

echo "✓ Symlinks created"

# Install tools
echo ""
echo "Installing tools..."

echo "Installing mise tools (go, node, pnpm, python)..."
mise install

echo "Installing aqua tools (gh, ghq, eza, bat, fzf, act, sheldon)..."
aqua install -a

echo "Generating sheldon lock file..."
sheldon lock

echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Please restart your terminal."
