# debian-nvidia-installer

NVIDIA driver installer with a Bash TUI. This tool allows you to install NVIDIA drivers on Debian using an interactive text-based interface (TUI).
It automates steps such as package installation, compatibility checks, and graphics environment configuration.

# Requirements

* **Debian Trixie** distribution  
* Bash-compatible shell  
* Administrator privileges (sudo/root)

After installation, you can start the installer directly from the terminal with:

```bash
sudo debian-nvidia-installer
```

> ⚠️ **You must run it as root**, since the tool performs system changes, such as installing packages and modifying configuration files.

# Installation

You can install `nvidia-installer` by downloading the `.deb` package from the **[Releases](https://github.com/devleonardoamaral/debian-nvidia-installer/releases)** section of this repository.

### Option 1: Graphical Interface (GUI)

1. Download the `.deb` file.
2. **Double-click** the file.
3. In your system’s package manager, click **“Install”**.

> 💡 Compatible with package managers like GDebi, Discover (KDE), GNOME Software, etc.

### Option 2: Terminal (Recommended)

```bash
# Move the file to /tmp (temporary directory) to avoid permission-related issues
mv ./nvidia-installer_0.0.1.deb /tmp/
cd /tmp

# Install the package and automatically resolve dependencies
sudo apt install ./nvidia-installer_0.0.1.deb

# Clean up the file after installation (optional)
rm ./nvidia-installer_0.0.1.deb
```

> 💡 Using `apt install ./file.deb` ensures that dependencies are installed correctly.

# Uninstallation

```bash
# Remove the package and its dependencies
sudo apt remove nvidia-installer
```

---

# How to Build the Package Manually

1. Clone this repository:

```bash
git clone https://github.com/devleonardoamaral/debian-nvidia-installer.git
```

2. Build the `.deb` package with the correct permissions:

```bash
dpkg-deb --build --root-owner-group debian-nvidia-installer
```

> 💡 The `--root-owner-group` option ensures that all files inside the package have `root` as their owner and group, as expected for Debian packages.

3. The file `debian-nvidia-installer.deb` will be generated in the current directory, ready for installation.

---

Para a versão em **Português do Brasil**, veja [README.pt_BR.md](README.pt_BR.md)
