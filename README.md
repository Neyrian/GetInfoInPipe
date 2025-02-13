# GetInfoInPipe

## 📌 Overview

This malware simulation creates a named pipe and uses it to temporarily store the additional information gathered by creating the following processes: 
- whoami.exe /all
- ipconfig.exe /all
- netstat.exe -aon
  
Each piece of information returned will be encrypted.

A list of running processes on the system will also be gathered and encrypted by calling `CreateToolHelp32Snapshot` and listing processes through `Process32First` and `Process32Next`.


🔗 Research References:

- [Trend Micro: Pikabot Spam Wave](https://www.trendmicro.com/en_us/research/24/a/a-look-into-pikabot-spam-wave-campaign.html)
- [MITRE ATT&CK: Pikabot Campaign (C0037)](https://attack.mitre.org/campaigns/C0037/)

---

## ⚠️ Disclaimer

🚨 **This project is for educational purposes only.** It does not contain malicious code but simulates **anti-analysis techniques** used by real malware. Use responsibly in **authorized research environments**.

---

## 🛠 Features

- Implements a named pipe server in PowerShell using embedded C#.
- Uses Windows API calls to interact with system processes.
- Allows interprocess communication through named pipes.
- Provide a client to store data in a json under `$env:TEMP\Curupira.json`
  
---

## Prerequisites
- Windows operating system
- PowerShell (version 5.1 or later recommended)

---

## Installation
1. Clone this repository:
   ```sh
   git clone https://github.com/neyrian/GetInfoInPipe.git
   ```
2. Navigate to the directory:
   ```sh
   cd GetInfoInPipe
   ```
3. Run the server:
   ```sh
   powershell -ExecutionPolicy Bypass -File GetInfosInPipeServer.ps1
   ```
4. (optional) Run the client:
   ```sh
   powershell -ExecutionPolicy Bypass -File GetInfosInPipeClient.ps1
   ```
---
## Author
- Neyrian

