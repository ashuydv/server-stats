# 🖥️ server-stats

A lightweight Bash script to analyse basic server performance stats on any Linux server.

> Project from [roadmap.sh - Server Stats](https://roadmap.sh/projects/server-stats)

---

## 📋 Features

- ✅ Total CPU usage with visual progress bar
- ✅ Total memory usage (Free vs Used with percentage)
- ✅ Total disk usage (Free vs Used with percentage)
- ✅ Top 5 processes by CPU usage
- ✅ Top 5 processes by memory usage
- ✅ OS version, kernel, architecture
- ✅ System uptime & last boot time
- ✅ Load average (1, 5, 15 minutes)
- ✅ Currently logged-in users
- ✅ Failed login attempts (last 10)

---

## 🚀 Usage

**1. Clone the repository**

```bash
git clone https://github.com/your-username/server-stats.git
cd server-stats
```

**2. Make the script executable**

```bash
chmod +x server-stats.sh
```

**3. Run the script**

```bash
./server-stats.sh
```

---

## 🖥️ Sample Output

```
  ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗
  ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
  ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
  ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
  ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
  ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
              S T A T S   R E P O R T
              2026-06-08 08:01:23 UTC

📋  SYSTEM INFORMATION
──────────────────────────────────────────────────────
  Hostname:          ip-172-31-46-178
  OS:                Amazon Linux 2023
  Kernel:            6.1.172-216.329.amzn2023.x86_64
  Architecture:      x86_64
  Uptime:            up 19 minutes
  Last Boot:         2026-06-08 07:42

🖥️   CPU USAGE
──────────────────────────────────────────────────────
  Total CPU Used:  0.0%
  [████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0.0% used / 100% idle

🧠  MEMORY USAGE
──────────────────────────────────────────────────────
  Total:       916.8 MiB
  Used:        268.4 MiB
  Available:   648.3 MiB
  [████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 29.3% used
```

---

## ⚙️ Requirements

- Any Linux distribution (tested on Amazon Linux 2023 & Ubuntu 24.04)
- Bash 4+
- Standard coreutils (`ps`, `df`, `top`, `awk`) — no external dependencies

---

## 🌐 Deploying on AWS EC2

**1. Launch an EC2 instance** (t3.micro with Amazon Linux 2023 recommended)

**2. Copy the script to your EC2**

```bash
scp -i ~/.ssh/your-key.pem server-stats.sh ec2-user@<your-ec2-ip>:~
```

**3. SSH into your EC2**

```bash
ssh -i ~/.ssh/your-key.pem ec2-user@<your-ec2-ip>
```

**4. Run the script**

```bash
chmod +x server-stats.sh && ./server-stats.sh
```

> **Note:** If progress bars show `?` characters, fix with: `export LANG=en_US.UTF-8`

---

## 📁 Project Structure

```
server-stats/
└── server-stats.sh     # Main script
└── README.md           # This file
```

---

## 🔗 Project URL

[https://roadmap.sh/projects/server-stats](https://roadmap.sh/projects/server-stats)