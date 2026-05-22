#!/bin/bash

cd ..

case "$OSTYPE" in
  linux-gnu*)
		echo "Linux"
		zshrc_path="~/.zshrc"
		ohmyzsh_path="~/.oh-my-zsh"
		gitconfig_path="~/.config/git/config"
		sioyek_keys_config="~/.config/sioyek/keys_user.config"
		sioyek_prefs_config="~/.config/sioyek/prefs_user.config"
		cp $zshrc_path ./zshrc
		cp $ohmyzsh_path ./oh-my-zsh
		cp $gitconfig_path ./gitconfig
		;;
  cygwin*|msys*|win32*)
		echo "Windows (Cygwin/MSYS/Git Bash)"
		bashrc_path="$HOME/.bashrc"
		gitconfig_path="$HOME/.gitconfig"
		sioyek_keys_config="C:/ProgramData/sioyek/keys_user.config"
		sioyek_prefs_config="C:/ProgramData/sioyek/prefs_user.config"
		yazi_config="$APPDATA/yazi/config/yazi.toml"
		cp $bashrc_path ./bashrc
		cp $yazi_config ./yazi.toml
		;;
  *)
		echo "Unknown OS: $OSTYPE"
		;;

esac

# Sioyek Configuraion
cp $sioyek_keys_config ./sioyek/keys_user.config
cp $sioyek_prefs_config ./sioyek/prefs_user.config
