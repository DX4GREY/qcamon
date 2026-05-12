# QCAMON - WiFi Manager for Qualcomm Qcacld-3.0

QCAMON is a lightweight WiFi management tool designed specifically for Qualcomm's Qcacld-3.0 driver. It allows users to switch between managed and monitor modes, set channels, restart the driver, and check the status of the WiFi interface.

## Features

- **Mode Switching**: Easily switch between managed and monitor modes using the `con_mode` sysfs parameter.
- **Channel Setting**: Set specific channels when in monitor mode.
- **Driver Restart**: Reload the wlan.ko module to reset the driver state.
- **Status Display**: View the current state of the driver, interface, and mode.
- **Cross-Platform**: Supports both Termux (Android) and Debian-based systems.

## Requirements

- Root access (for Android/Termux, use `su` or `sudo`).
- Dependencies: `iw`, `iproute2`, `svc` (for Android).
- Qualcomm Qcacld-3.0 driver loaded.
- wlan.ko module available at `/data/local/tmp/wlan.ko` (for Termux) or appropriate path.

## Installation

### From Source

1. Clone or download the repository.
2. Run `make build` to build packages for both Termux and Debian.
3. Install the appropriate package:
   - For Termux: `dpkg -i out/termux.deb`
   - For Debian: `sudo dpkg -i out/debian.deb`

### Manual Installation

1. Copy `wifi_manager.sh` to a directory in your PATH (e.g., `/usr/local/bin/qcamon` for Debian or `/data/data/com.termux/files/usr/bin/qcamon` for Termux).
2. Make it executable: `chmod +x /path/to/qcamon`.
3. Ensure dependencies are installed.

## Usage

Run the script with the desired action:

```
qcamon {restart|mode|channel|status} [args]
```

### Commands

- `restart`: Restart the driver by reloading the wlan.ko module.
- `mode {managed|monitor}`: Switch to managed or monitor mode.
  - Monitor mode sets `con_mode` to 4.
  - Managed mode requires a driver restart.
- `channel <chan>`: Set the channel (only in monitor mode).
- `status`: Display the current WiFi status.

### Examples

- Switch to monitor mode: `qcamon mode monitor`
- Set channel to 6: `qcamon channel 6`
- Switch to managed mode: `qcamon mode managed`
- Restart driver: `qcamon restart`
- Show status: `qcamon status`

## Notes

- Ensure the wlan.ko module path is correct for your system.
- For Android/Termux, the script assumes the Termux environment.
- The tool is designed for Qcacld-3.0; compatibility with other drivers is not guaranteed.

## License

This project is licensed under the MIT License. See LICENSE file for details.

## Author

Dx4Grey <dxablack@gmail.com> 