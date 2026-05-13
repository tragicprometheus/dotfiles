#!/usr/bin/env bash

cd ..

case "$OSTYPE" in
linux-gnu*)
		echo "Linux"
		zshrc_path="~/.zshrc"
		ohmyzsh_path="~/.oh-my-zsh"
		gitconfig_path="~/.config/git/config"
		sioyek_keys_config="~/.config/sioyek/keys_user.config"
		sioyek_prefs_config="~/.config/sioyek/prefs_user.config"
		;;
cygwin*|msys*|win32*)
		echo "Windows (Cygwin/MSYS/Git Bash)"
		gitconfig_path="~/.gitconfig"
		sioyek_keys_config="C:/ProgramData/sioyek/keys_user.config"
		sioyek_prefs_config="C:/ProgramData/sioyek/prefs_user.config"
		;;
*)
		echo "Unknown OS: $OSTYPE"
		;;
esac

cp ./zshrc $zshrc_path
cp  ./oh-my-zsh $ohmyzsh_path
cp ./gitconfig $gitconfig_path

# Sioyek Configuraion 
cp ./sioyek/keys_user.config $sioyek_keys_config
cp ./sioyek/prefs_user.config $sioyek_prefs_config
