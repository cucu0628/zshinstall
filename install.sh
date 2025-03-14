#!/bin/bash

# Ask for distro
echo "Melyik disztróra szeretnéd telepíteni? (fedora/debian)"
read distro

# Update package manager
if [ "$distro" == "fedora" ]; then
  sudo dnf update -y
  sudo dnf install -y zsh git curl eza fzf
elif [ "$distro" == "debian" ]; then
  sudo apt update -y
  sudo apt install -y zsh git curl eza fzf
else
  echo "Nem támogatott disztró. Kilépés."
  exit 1
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

# Install fastfetch
if [ ! -d "$HOME/fastfetch" ]; then
  git clone https://github.com/fastfetch-cli/fastfetch.git $HOME/fastfetch
  cd $HOME/fastfetch
  mkdir build && cd build
  cmake ..
  make -j$(nproc)
  sudo make install
  cd ~
fi

# Install Pokemon Colorscripts (optional)
if [ ! -d "$HOME/pokemon-colorscripts" ]; then
  git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git $HOME/pokemon-colorscripts
  sudo cp $HOME/pokemon-colorscripts/pokemon-colorscripts /usr/local/bin/
fi

# Set Zsh as default shell
chsh -s $(which zsh)

# Configure .zshrc
cat << EOF > $HOME/.zshrc
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="fino"
plugins=(git dnf zsh-autosuggestions zsh-syntax-highlighting)
source \$ZSH/oh-my-zsh.sh
fastfetch -c \$HOME/.config/fastfetch/config-compact.jsonc
source <(fzf --zsh)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
alias ls='eza -a --icons'
alias ll='eza -al --icons'
alias lt='eza -a --tree --level=1 --icons'
alias pipes='./pipes.sh/pipes.sh'
alias cl='clear'
alias mozi='python ./mozi/Untitled-1.py'
EOF

# Reload Zsh
exec zsh
