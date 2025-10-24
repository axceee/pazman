# pazman

**A beautiful, secure CLI password manager that just works.**

Stop juggling passwords. Stop reusing them. Stop worrying about security. `pazman` encrypts your passwords with military-grade AES-256 encryption and keeps them safe in your terminal.

---

## Quick Install

### Linux / macOS
```bash
curl -fsSL https://raw.githubusercontent.com/axceee/pazman/main/install.sh | bash
```

### Windows (PowerShell)
```powershell
iwr -useb https://raw.githubusercontent.com/axceee/pazman/main/install.ps1 | iex
```

---

## Features

- **Military-grade encryption** - AES-256-CBC keeps your passwords safe
- **Beautiful interface** - Clean, colorful CLI that's a joy to use
- **Lightning fast** - Native bash, no dependencies to install
- **Auto-generate passwords** - Strong 20-character passwords created instantly
- **Smart clipboard** - Auto-copies and clears after 30 seconds
- **Zero knowledge** - Your master password never leaves your machine
- **Cross-platform** - Works on Linux, macOS, Windows (WSL/Git Bash)

---

## Usage

```bash
# Add a new password (auto-generates)
pazman set github

# Add with your own password
pazman set gmail MySecureP@ss123

# Retrieve a password (copies to clipboard)
pazman get github

# Update an existing password
pazman put github

# Delete a password
pazman pop oldservice

# List all your services
pazman list
```

---

## Security First

- **Master password protection** - One password to rule them all
- **Local encryption** - Everything stays on your machine
- **No password exposure** - Never displayed in terminal
- **Auto-clear clipboard** - Passwords vanish after 30 seconds
- **Secure file permissions** - `chmod 600` on all sensitive files

---

## What It Looks Like

```
pazman - Secure CLI Password Manager
--------------------------------------------------

COMMANDS:
  set     Add/update password (auto-generates if omitted)
  get     Retrieve password (copies to clipboard)
  put     Update existing password
  pop     Delete password
  list    List all stored services

[OK] Password copied to clipboard (auto-clears in 30s)
```

---

## Requirements

- Bash 4.0+
- OpenSSL (usually pre-installed)
- Clipboard utility: `xclip` (Linux X11), `wl-clipboard` (Wayland), `pbcopy` (macOS), or `clip.exe` (Windows)

---

## Manual Installation

```bash
# Download the script
curl -O https://raw.githubusercontent.com/axceee/pazman/main/pazman

# Make it executable
chmod +x pazman

# Move to your PATH
sudo mv pazman /usr/local/bin/
```

---

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

---

## License

MIT License - feel free to use `pazman` however you'd like.

---

## Why pazman?

Because password management should be **simple**, **secure**, and **beautiful**. No browser extensions. No cloud sync. No subscriptions. Just a clean CLI tool that respects your privacy and gets out of your way.

**Stop managing passwords. Start using pazman.**
