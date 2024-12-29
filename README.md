# Bash Utils

This repository contains a collection of useful bash functions and aliases.

## Available Commands

### `ask`
Prompts the user with a yes/no question and returns 0 for yes and 1 for no.

### `bat`
Alias for `batcat`, a cat clone with syntax highlighting and Git integration.

### `fcd`
Changes the current directory to the specified directory or to a directory selected interactively using `fzf`.

### `findNoBin`
Finds all non-binary files in the current directory and its subdirectories.

### `img_convert`
Converts images from one format to another.

### `img_find_duplicates`
Finds duplicate files based on their names.

### `img_jpg_to_png`
Alias for `img_convert jpg png`.

### `img_png_to_jpg`
Alias for `img_convert png jpg`.

### `img_png_transparent_white`
Makes the white color in PNG images transparent.

### `img_png_white_to_color`
Replaces the white color in PNG images with a specified color.

### `img_recount`
Renames files in the current directory with sequential numbers.

### `img_scale`
Scales an image by a specified factor.

### `img_scale_all`
Scales all images in the current directory by a specified factor.

### `img_trim_all`
Trims whitespace from all images in the current directory.

### `install_deb_package`
Installs a `.deb` package using `dpkg`.

### `install_deb_package_url`
Downloads and installs a `.deb` package from a specified URL.

### `install_vscode`
Downloads and installs Visual Studio Code.

### `ls`
Alias for `exa --icons --color=auto --group-directories-first`.

### `lsl`
Alias for `ls -s modified -la`.
