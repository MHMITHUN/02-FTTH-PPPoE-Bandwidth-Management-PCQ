# FTTH Broadband Access Architecture: MikroTik PPPoE Server, FreeRADIUS & PCQ Dynamic Bandwidth Shaping

[![Live Demo](https://img.shields.io/badge/Demo-Live%20PPPoE%20&%20FTTH%20Dashboard-06b6d4)](https://mhmithun.github.io/02-FTTH-PPPoE-Bandwidth-Management-PCQ/)
[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](LICENSE)
[![Platform: MikroTik RouterOS](https://img.shields.io/badge/RouterOS-v7%20CCR--Series-blue.svg)](configs/mikrotik_pppoe_pcq.rsc)
[![FTTH: GPON / EPON](https://img.shields.io/badge/FTTH-GPON%20OLT%20%2F%20ONU-emerald.svg)](configs/gpon_olt_onu_provisioning.txt)

Turnkey ISP broadband delivery architecture featuring centralized MikroTik RouterOS PPPoE Access Concentrator, dynamic subscriber IP pool recycling, Per-Connection Queueing (PCQ) traffic shaping, FreeRADIUS accounting, and GPON/EPON Optical Line Terminal (OLT) service-port provisioning.

---

## 🌐 Live Web Management Simulator (`index.html`)

An interactive ISP Subscriber & OLT Operations Dashboard:
- **Live PPPoE Active Sessions Viewer**: Monitor subscriber authentication, assigned IP addresses, uptime, and live Rx/Tx throughput.
- **PCQ Dynamic Bandwidth Equalizer**: Visual simulator demonstrating how 100 concurrent broadband subscribers dynamically share a 1 Gbps pipe without packet buffer bloat.
- **FTTH Optical Link Budget Calculator**: Input optical transmitter power (dBm), fiber length (km), and optical splitter ratios (1:8, 1:16, 1:32, 1:64) to calculate received ONU optical sensitivity (dBm) and detect high-loss cuts.
- **MikroTik CLI / Winbox Command Generator**: Instantly generate RouterOS scripts for user profiles (e.g. 10 Mbps, 25 Mbps, 50 Mbps).

---

## 🛠️ Key Technical Implementations

1. **MikroTik RouterOS PPPoE Server (`configs/mikrotik_pppoe_pcq.rsc`)**:
   - Centralized PPPoE service bound to VLAN trunking interface (`vlan-pppoe-subscribers`).
   - MTU/MRU clamping to 1480 to prevent TCP MSS fragmentation.
   - Subscriber IP Pool: `100.64.0.0/18` (Carrier-Grade NAT RFC 6598).
   - Dynamic Profile tiers:
     - `Profile-10M`: 10M/10M rate limit with 15M burst for 8 seconds.
     - `Profile-25M`: 25M/25M rate limit with 35M burst for 8 seconds.
     - `Profile-50M`: 50M/50M rate limit with 75M burst for 8 seconds.

2. **Per-Connection Queueing (PCQ) Dynamic QoS**:
   - Prevents bandwidth hogging by heavy multi-threaded downloaders (IDM, torrents).
   - Dynamically partitions available bandwidth equally across all active customer IP connections.

3. **GPON / EPON OLT & ONU Provisioning (`configs/gpon_olt_onu_provisioning.txt`)**:
   - DBA profile definitions (Dynamic Bandwidth Assignment Type 4 Best Effort).
   - GEM port and T-CONT mapping for Triple-Play traffic (Internet VLAN 100, IPTV VLAN 200, Management VLAN 300).
   - ONU automatic authentication via LOID / SN registration.

---

## 📁 Repository Structure
```
├── configs/
│   ├── freeradius_dictionary_users.txt   # FreeRADIUS users & rate-limit attributes
│   ├── gpon_olt_onu_provisioning.txt     # Huawei / ZTE / BDCOM OLT CLI configuration
│   └── mikrotik_pppoe_pcq.rsc            # Complete RouterOS script for PPPoE & Queues
├── index.html                            # Interactive FTTH & PPPoE NOC web console
├── LICENSE
└── README.md
```

---

## 🚀 Deployment Instructions

### 1. MikroTik RouterOS Setup
```bash
/import file-name=mikrotik_pppoe_pcq.rsc
```

### 2. Verify Active Subscribers
```bash
/interface pppoe-server print
/interface pppoe-server active print
/queue simple print
```

---

## 📄 License & Maintainer
Maintained by **[MD. Mahamudul Hasan](https://github.com/MHMITHUN)**  
- Email: mhmmithun1@gmail.com | Phone: 01560027539  
- GitHub: [@MHMITHUN](https://github.com/MHMITHUN) | LinkedIn: [linkedin.com/in/mahamudul0](https://linkedin.com/in/mahamudul0)  
Released under the [MIT License](LICENSE).

