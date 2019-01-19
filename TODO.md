# TODO: Arch Linux ansible bootstrap setup

- automate actual install parts (like UEFI / EFISTUB setup)
- set sudo pacman to not ask for password from wheel

- keyboard layout: `caps:hyper` not working with `ctrl:swapcaps` as well.
  Should make one of the Ctrl keys work as Hyper in order to have another
  modifier for `sxhkd`.
- `urxvt`
  - disable Ctrl-S/Ctrl-Q in urxvt
  - load tamzen without Xft?
  - use `urxvtd` and `urxvtc`
  - set transparency
- future: extend base16-manager to work with iTerm2? ([ref](https://coderwall.com/p/s-2_nw/change-iterm2-color-profile-from-the-cli)).
- deepin wallpapers (they have a banging one with trees that will probably look
  good with gruvbox)
- intel graphics screen tearing on scroll?
  - check out [arch wiki](https://wiki.archlinux.org/index.php/intel_graphics#Tearing)
- seamless boot with plymouth
- actually detect intel graphics vs virtualbox on xorg install
- future: multiple monitors?

## DONE
- install proper X fonts
- fix cedilla for `en_US.UTF-8` locale
- set proper caps=ctrl key (`setxkbmap -option ctrl:swapcaps,caps:hyper`?)
  - future: keyboard layout switching?
- xsel
- compton
- set natural scroll direction
- user wallpaper
- lightdm wallpaper
- install polybar actually
- polybar config
  - polybar startup
- audio
- tamzen bitmap font
- enable media controls (volume etc) from keyboard
- battery indicator
- backlight controls
- load i915 module early at boot
- thinkfan
- hardware-accelerated video?
- mpv
- add cpupower and powertop
- add config to systemd so that:
  - powersave governor when on battery
  - performance governor when on AC
- screen lock
- install dunst for notifications
- dotfiles
- fish fish fish fish fish `><>`
- "command not found" stuff
- install base16-manager with Xresources, rofi, vim
  - Xresources: need to create dir `~/.Xresources.d`
  - rofi: need to create dir `~/.config/rofi`
  - vim need to create dir `~/.config/nvim`, install base16-vim and source `~/.config/nvim/colorscheme.vim`
  - polybar: use Xresources colors
  - dunst!
