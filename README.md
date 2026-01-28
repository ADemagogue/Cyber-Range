# Cyber-Range (Containerized Fork)

> **Status: ALPHA** -- This fork is under active development and has not been validated in a live exercise. Use at your own risk.

This is a containerized fork of [chipmanfu's Cyber-Range](https://github.com/chipmanfu/Cyber-Range). The original project deploys across 7 Ubuntu VMs and 1 VyOS router. This fork collapses the entire environment into a single `docker compose up -d` deployment on one Linux host.

All credit for the Cyber-Range concept, architecture, network design, OPFOR automation, traffic generation, and original scripts goes to **chipmanfu**.

## What Changed

- Replaced the VyOS router VM with a lightweight Alpine container that applies IP addresses directly to host interfaces
- Converted all bare-metal services (DNS, CA, Proxy) into Docker containers
- Merged all 6 web service compose files into a single master `docker-compose.yml`
- Parameterized all hardcoded IPs, passwords, and paths via a single `.env` file
- Added a `cert-bootstrap` init container that generates SSL certs for all web services on first boot
- NRTS runs as an on-demand interactive container with Docker socket access for spawning red team infrastructure
- Added BATS test suite (27 test files) and GitHub Actions CI pipeline
- Addressed 17 errata items identified during plan audit (see `CONTAINER_PLAN.md` Section 13)

## Quick Start

```bash
# 1. Clone
git clone https://github.com/ADemagogue/Cyber-Range.git && cd Cyber-Range

# 2. Configure
cp .env.example .env
# Edit .env — set interface names, passwords, optional CS license key

# 3. Prepare host networking (run once)
sudo ./setup-host.sh

# 4. Launch
docker compose up -d

# 5. Watch startup
docker compose logs -f
```

## Requirements

- Linux host (Ubuntu 22.04+ recommended) -- Docker Desktop on macOS/Windows does **not** support macvlan
- Docker Engine 24+ with Compose V2 (V2.21+ for `service_completed_successfully`)
- 4 network interfaces (physical or virtual with promiscuous mode)
- 16 GB RAM minimum (32 GB recommended)
- 50 GB disk (100 GB if downloading traffic websites)

## Spin Up a Red Team Instance

```bash
# Interactive — drops into the buildredteam.sh menu
NRTS_INSTANCE=team1 docker compose run --rm --profile nrts nrts

# Multiple concurrent instances in separate terminals
NRTS_INSTANCE=team2 docker compose run --rm --profile nrts nrts
```

Each instance gets its own persistent state directory under `data/nrts/`.

## Teardown

```bash
# Stop everything (preserve data)
docker compose down

# Stop everything and destroy all data
docker compose down -v
```

## Architecture Overview

```
docker-compose.yml
|
+-- router          (Alpine + iproute2, host network, applies ~1670 IPs)
+-- rootdns         (BIND9, host network, 14 IPs for root DNS emulation)
+-- ca-server       (Ubuntu + OpenSSL + faketime, PKI infrastructure)
+-- cert-bootstrap  (one-shot, generates SSL certs for web services)
+-- proxy           (Squid, internet access gateway)
+-- owncloud        (file sharing — simulates dropbox.com)
+-- bookstack       (documentation wiki — redbook.com)
+-- hastebin        (paste service — pastebin.com)
+-- drawio          (diagramming — diagrams.net)
+-- ntp             (NTP time service)
+-- ms-sites        (Windows NCSI/connectivity check emulation)
+-- nrts            (on-demand, interactive red team server)
```

## Configuration

All operator-tunable values live in `.env`. See `.env.example` for the full list. Key settings:

| Variable | Default | Description |
|----------|---------|-------------|
| `ADMIN_DEV` | `eth0` | Host interface for admin network |
| `SERVICES_DEV` | `eth1` | Host interface for services network |
| `GRAYSPACE_DEV` | `eth2` | Host interface for grayspace (simulated internet) |
| `WAN_DEV` | `eth3` | Host interface for WAN (target range connection) |
| `MASTER_PASSWORD` | `toor` | Default password for SSH between containers |
| `CA_DOMAIN` | `globalcert.com` | Domain for the simulated certificate authority |
| `CS_LICENSE_KEY` | _(empty)_ | Cobalt Strike license key (optional) |

## Known Limitations

- **Linux only.** macvlan requires Linux kernel support.
- **4 NICs required** for full multi-segment operation. Single-NIC setups work with bridge networks but external blue team machines cannot reach range IPs directly.
- **Promiscuous mode** must be enabled on hypervisor port groups for macvlan.
- **Cobalt Strike** cannot be distributed in the image. The NRTS downloads it at first run if `CS_LICENSE_KEY` is set.
- **1.1 GB website archive** is downloaded on first run for the traffic webhost (requires internet access).

---

# Original CyberRange Documentation

_The following is from the original project by [chipmanfu](https://github.com/chipmanfu/Cyber-Range)._

## The CyberRange Network Diagram
![CyberRange](https://github.com/chipmanfu/Cyber-Range/assets/50666533/4d71b340-ffaa-4745-b7a7-e9624449adca)

This Github project provides the CyberRange systems shown above in the green box.  The blue box would be the target domains (aka blue space) environments that the end user would need to build and attach to the CyberRange envirnoment.  Once, you've installed the CyberRange, there will be a Bookstack website running on the Web-Services VM that contains all of the documentation regarding the CyberRange along with instructions on how to connect a target domain to this environment.

## CyberRange Key Features
- Geo-IP based Public IP routing - The SI-Router is configured to route around 1650 public IP subnets that represent Geo-locations around the world.
- Global DNS Registration - The RootDNS VM will emulate the real world Root DNS servers (A-root through M-root) as well as Googles Recurvise DNS server at 8.8.8.8.  This handles DNS for the environment and comes with scripts to allow users to register new DNS as well as some automation built in to OPFOR infastructure builds that can provide randomized DNS.
- Simulated Trusted Certificate Authority - The CA-Server VM will simulated a trusted CA.  This system also has scripts for user generated SSL certs that can be used for Web server authentication and/or SSL certs for signing binaries.  This system is also intergrated into the OPFOR infastructure automation and will create SSL certs for OPFOR Domains for any HTTPS C2, as well as provide a code-signing cert that will integrate into Cobalt Strikes teamserver.
- OPFOR Infastructure Automation - The NRTS server is a customized Ubuntu server that can create various OPFOR infrastructure systems in docker containers.  Using a script called "buildredteam.sh", a user can quickly build out redirectors, payload host, Cobalt Strike Teamservers, and/or set up a phishing attack.  The script will automate IP assignments, DNS registration, and Obtaining CA signed SSL certs if required, then build out the service and configure this service and start it within a docker container.  Each NRTS you build can support running multiple OPFOR infastructure systems
- Simulated Internet File sharing service - The web-services VM runs an Owncloud instance in a docker container to simulate real world file hosting site like dropbox.  Owncloud supports WebDAV, and various APIs that enables OPFOR to utilized this for file exfil and/or payload hosting.
- Simulated Pastebin - The web-services VM additionally runs a dockerized hastebin instance.  This can be used by OPFOR to host code snipnets that can be called via https or http link.
- CyberRange Documenation - The web-services VM also hosts a dockerized bookstack instance that contains all of the CyberRange documenation.
- Real World NTP server emulation - The web-services VM hosts an NTP server that gets its time source from the IA-Proxy which in turn gets its time source from the real internet.  The RootDNS server will resolve real world NTP server domains such as time.windows.com, *.ntp.org, *.nist.gov, to this server to ensure your target domain systems are synced to real world time.
- 175 Hosted websites - The Traffic-WebHost VM runs an apache webserver that hosts 175 scrapped websites that can be used for traffic generation.  These sites are be build with SSL Certs that have been signed by the CA-Server to enable trusted SSL Certs for all of these sites.
- External SMTP Traffic Generator - The Traffic-EmailGen can generate emails and send these to your target domain users.
- Real World Internet Access - The CyberRange environment has a internet access web proxy.  This allows access to the real internet for all of the systems in the CyberRange.

## Legacy Installation Instructions
See the [original project wiki](https://github.com/chipmanfu/Cyber-Range/wiki) for VM-based installation.
Once installed, there is a bookstack instance within the environment at www.redbook.com that contains detailed overviews and how-to guides for using the environment.

## New Features (Original)

- Updated NRTS docker services to push logs into the docker logs.  You can see service logs by running: docker logs "serviceName"
- Modified SSL cert creation to simulate SSL cert aging.  New certs will be created with an offset creation date between 6-18 months old
- Added a Domain Fronting Content Delivery Network redirector to the NRTS server

## To Do
- Add a simulated "Let's Encrypt" Certificate authority to simulate various levels of trust
- Full integration testing on a multi-NIC host
- Traffic generation containers (email + webhost) end-to-end validation
