# ==============================================================================
# MikroTik RouterOS v7 Script: High-Capacity PPPoE Server & PCQ Traffic Shaping
# Target: Asian Network ISP Distribution Core (CCR1036 / CCR2004)
# Author: Md. Mahamudul Hasan (Support Engineer - ISP Software & Networking)
# ==============================================================================

/system identity set name="AsianNet-PPPoE-BRASS"

# 1. IP Pools for Subscribers (RFC 6598 CGNAT Range)
/ip pool
add name=pool-cgnat-subscribers ranges=100.64.10.2-100.64.30.254

# 2. DNS Server Settings with Cache
/ip dns
set allow-remote-requests=yes cache-size=4096KiB servers=8.8.8.8,1.1.1.1

# 3. PPPoE Profiles with Rate-Limiting & Bursting
/ppp profile
add change-tcp-mss=yes dns-server=100.64.10.1,8.8.8.8 local-address=100.64.10.1 \
    name=profile-bronze-10m rate-limit=10M/10M 15M/15M 8M/8M 8/8 remote-address=pool-cgnat-subscribers \
    use-encryption=yes use-upnp=no
    
add change-tcp-mss=yes dns-server=100.64.10.1,8.8.8.8 local-address=100.64.10.1 \
    name=profile-silver-25m rate-limit=25M/25M 35M/35M 20M/20M 8/8 remote-address=pool-cgnat-subscribers \
    use-encryption=yes use-upnp=no

add change-tcp-mss=yes dns-server=100.64.10.1,8.8.8.8 local-address=100.64.10.1 \
    name=profile-gold-50m rate-limit=50M/50M 75M/75M 45M/45M 8/8 remote-address=pool-cgnat-subscribers \
    use-encryption=yes use-upnp=no

# 4. PPPoE Server Service Binding
/interface pppoe-server server
add authentication=pap,chap,mschap2 default-profile=profile-silver-25m disabled=no \
    interface=ether2-to-olt max-mru=1480 max-mtu=1480 mrru=1600 service-name=AsianNet-Broadband

# 5. Local PPP Secrets (Fallback / VIP clients)
/ppp secret
add name="user_gazipur_101" password="SecretPassword@2026" profile=profile-silver-25m service=pppoe comment="VIP Client - Tungi"
add name="user_tungi_home_202" password="SecretPassword@2026" profile=profile-bronze-10m service=pppoe comment="Home User"
add name="corp_client_505" password="EnterpriseSecret@2026" profile=profile-gold-50m service=pppoe comment="Corporate Office"

# 6. PCQ Dynamic Bandwidth Queue Types
/queue type
add kind=pcq name=pcq-download-custom pcq-classifier=dst-address pcq-dst-address6-mask=64 pcq-rate=0 pcq-total-limit=4000KiB
add kind=pcq name=pcq-upload-custom pcq-classifier=src-address pcq-rate=0 pcq-src-address6-mask=64 pcq-total-limit=4000KiB

# 7. Dynamic Queue Tree for Fair Equal Sharing
/queue tree
add max-limit=1000M name=TOTAL-INTERNET-OUT parent=global
add limit-at=500M max-limit=950M name=QUEUE-PPPOE-DOWNLOAD packet-mark="" parent=TOTAL-INTERNET-OUT queue=pcq-download-custom
add limit-at=200M max-limit=450M name=QUEUE-PPPOE-UPLOAD packet-mark="" parent=TOTAL-INTERNET-OUT queue=pcq-upload-custom

# 8. Firewall Source NAT (Masquerade / CGNAT)
/ip firewall nat
add action=masquerade chain=srcnat comment="CGNAT Broadband Masquerade" out-interface=ether1-wan src-address=100.64.0.0/18

# 9. Security: Drop Invalid Packets & Mitigate SYN Flood
/ip firewall filter
add action=drop chain=input comment="Drop Invalid Connections" connection-state=invalid
add action=accept chain=input comment="Accept Established/Related" connection-state=established,related
add action=accept chain=input comment="Permit PPPoE Discovery" dst-port=1701,500,4500 protocol=udp

