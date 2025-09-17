# Cursor Linux Installer

A simple script to install [Cursor](https://cursor.com) on Linux (AppImage-based), with fixes for common issues like:
- `dlopen(): error loading libfuse.so.2`
- `The setuid sandbox is not running as root`

This script:
- Downloads the latest Cursor AppImage via Cursor’s official API
- Extracts and installs it into `/opt/`
- Fixes sandbox permissions
- Creates a desktop entry + symlink so you can run `cursor` from the terminal or applications menu


## Requirements
- Debian/Ubuntu-based Linux
- `sudo` privileges
- Internet connection

The script auto-installs:
- `libfuse2` (required for AppImages)
- `curl`, `wget`, `jq`


## Installation

Clone the repo:

```bash
git clone https://github.com/<your-username>/cursor-linux-installer.git
cd cursor-linux-installer


chmod +x install-cursor.sh
sudo ./install-cursor.sh


---

### 4. Usage
```markdown
## Usage

After installation:
- Run `cursor` in your terminal
- Or launch **Cursor** from your applications menu


## Troubleshooting

- **Error:** `dlopen(): error loading libfuse.so.2`
  - Fix: Ensure `libfuse2` is installed: `sudo apt install libfuse2`

- **Error:** `setuid sandbox is not running as root`
  - Fix: The script sets `chmod 4755` on `chrome-sandbox`.  
    If Cursor updates its structure and this fails, run:
    ```bash
    find /opt/Cursor -name chrome-sandbox
    sudo chmod 4755 /path/to/chrome-sandbox
    ```

- **AppImage fails to run**
  - Try extracting manually:
    ```bash
    ./Cursor.AppImage --appimage-extract
    ./squashfs-root/AppRun
    ```

## Notes
- This script installs Cursor **system-wide** at `/opt/Cursor`.
- Tested on Ubuntu 25.04 (adjust package manager commands if using another distro).
- No `--no-sandbox` flag is used (for security reasons).
