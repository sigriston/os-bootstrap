# TODO: Arch Linux ansible bootstrap setup

- automate actual install parts (like UEFI / EFISTUB setup)

- set sudo pacman to not ask for password from wheel
- install polybar actually
	- color emoji
- install base16-manager with Xresources, rofi, vim
	- Xresources: need to create dir `~/.Xresources.d`
	- rofi: need to create dir `~/.config/rofi`
	- vim: need to create dir `~/.config/nvim`, install base16-vim and source `~/.config/nvim/colorscheme.vim`
	- future: extend base16-manager to work with iTerm2? ([ref](https://coderwall.com/p/s-2_nw/change-iterm2-color-profile-from-the-cli)).
- install proper X fonts
- set natural scroll direction
- set proper caps=ctrl key (`setxkbmap -option ctrl:nocaps`?)
	- future: keyboard layout switching?
- enable media controls (volume etc) from keyboard
- intel graphics screen tearing on scroll?
	- check out [arch wiki](https://wiki.archlinux.org/index.php/intel_graphics#Tearing)
- seamless boot with plymouth
- lightdm wallpaper
- user wallpaper
- actually detect intel graphics vs virtualbox on xorg install
- future: multiple monitors?
- compton
- xsel / xclip