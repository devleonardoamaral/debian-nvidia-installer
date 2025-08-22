# debian-nvidia-installer

NVIDIA driver installer with a Bash TUI. This tool allows you to install NVIDIA drivers on Debian using an interactive text-based interface (TUI).
It automates steps such as package installation, compatibility checks, and graphics environment configuration.

### Requirements

* **Debian Trixie** distribution
* **64-bit architecture**
* **Compatible NVIDIA graphics card**
  > Official NVIDIA drivers on Debian Trixie **do not support** [GPUs based on the Kepler architecture](https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/).
  
  > See [how to install legacy drivers on Debian](https://wiki.debian.org/NvidiaGraphicsDrivers#Tesla_Drivers) if needed.
* **Bash-compatible** shell
* Administrator privileges (**sudo/root**)

# How to Run

After installation, you can start the script through the shortcut in the applications menu or via the terminal by running the command:

```bash
sudo debian-nvidia-installer
```
> ⚠️ **It is necessary to run as root**, as the tool makes system changes such as installing packages and modifying configuration files.

# Installation

You can install `debian-nvidia-installer` by downloading the `.deb` package from the **[Releases](https://github.com/devleonardoamaral/debian-nvidia-installer/releases)** section of this repository.

### Option 1: Graphical Interface (GUI)

1. Download the `.deb` file.
2. **Double-click** the file.
3. In your system’s package manager, click **“Install”**.

> 💡 Compatible with package managers like GDebi, Discover (KDE), GNOME Software, etc.

### Option 2: Terminal (Recommended)

```bash
# Move the file to /tmp (temporary directory) to avoid permission-related issues
mv ./debian-nvidia-installer_0.0.1.deb /tmp/
cd /tmp

# Install the package and automatically resolve dependencies
sudo apt install ./debian-nvidia-installer_0.0.1.deb

# Clean up the file after installation (optional)
rm ./debian-nvidia-installer_0.0.1.deb
```

# Uninstallation

```bash
# Remove the package and its dependencies
sudo apt remove debian-nvidia-installer
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

3. The file `debian-nvidia-installer.deb` will be generated in the current directory, ready for installation.

---

Para a versão em **Português do Brasil**, veja [README.pt_BR.md](README.pt_BR.md)
