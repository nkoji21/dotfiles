# dotfiles

Personal dotfiles for macOS development environment.

## Setup

### 1. Install Dependencies

```sh
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Clone Repository

```sh
git clone https://github.com/nkoji21/dotfiles.git ~/ghq/github.com/nkoji21/dotfiles
cd ~/ghq/github.com/nkoji21/dotfiles
```

### 3. Install Homebrew Packages

```sh
brew bundle install
```

### 4. Create Personal Git Config

Create `~/.gitconfig.local` with your personal information:

```gitconfig
[user]
	email = your-email@example.com
	name = Your Name
```

### 5. Run Install Script

```sh
cd ~/ghq/github.com/nkoji21/dotfiles
./install.sh
```
