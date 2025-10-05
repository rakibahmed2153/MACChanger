# Auto MAC Address Changer

A Bash script that repeatedly changes your network interface’s MAC address at user-defined intervals, then restores the original MAC when finished or interrupted.

---

## ✨ Features

- Interactive prompts for:
  - **Network interface** (e.g. `wlan0`, `eth0`)
  - **Number of MAC changes**
  - **Delay (seconds)** between changes  
- Automatically restores the **original MAC address** after finishing or interruption (`Ctrl+C`).  
- Uses `macchanger` and `ip` (modern replacement for `ifconfig`).  
- Input validation for safer usage.  

---

## 📦 Prerequisites

- Linux system (tested on **Kali / Ubuntu / Debian**)  
- Root privileges (run with `sudo`)  
- Required packages:  
  - `macchanger`  
  - `iproute2`  
  - `bc`  

Install dependencies:

```bash
sudo apt update
sudo apt install macchanger iproute2 bc -y

```

## ⚙️ Installation

Clone this repository or download the script:

```
git clone https://github.com/rakibahmed2153/MACChanger.git
cd MACChanger
```

Make the script executable:

```
chmod +x auto-macchange.sh
```

## 🚀 Usage

Run the script with root privileges:
```
sudo ./auto-macchange.sh
```

##  You’ll be asked:

1. Interface → e.g. wlan0, eth0
2. Number of times to change the MAC
3. Delay in seconds between changes

## 🖥️ Example Session

```
Enter network interface to change (e.g. wlan0, eth0): wlan0
Original MAC for wlan0: 00:11:22:33:44:55
How many times do you want to change the MAC? 3
Delay between changes (seconds): 5
-> I will change the MAC 3 times on interface wlan0 with 5 second(s) delay.

-> Iteration 1 / 3: changing MAC...
Result:
Current MAC: aa:bb:cc:dd:ee:ff (random)

-> Iteration 2 / 3: changing MAC...
...

-> Restoring original hardware MAC (attempt) for wlan0...
-> MAC after restore attempt: 00:11:22:33:44:55
-> Done.
```

## ⚠️ Disclaimer

For educational purposes only.
Do not use this script on networks or devices you don’t own or have explicit permission to test.
Changing your MAC can break connectivity or violate network policies.
The author is not responsible for misuse, damage, or legal issues.

## 📜 License

MIT License — feel free to use, modify, and share.
