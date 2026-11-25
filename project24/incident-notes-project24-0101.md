# Incident Notes — Project 24 (`project24-0101`)

- **Target Resource:** `app-ec2-project24-0101` (`ap-south-1`, default VPC, no ports 22 or 3389)
- **Affected Service:** `nginx` (`1.30.7`)
- **Failure Injection:** `sudo systemctl stop nginx` at `Wed Nov 25 06:29:13 UTC 2026` — service reported `inactive` and `HTTP Status: 000` (`Service unreachable`).
- **Recovery Action:** `sudo systemctl start nginx` at `Wed Nov 25 06:29:40 UTC 2026` (~27 seconds recovery duration).
- **Verification:** `systemctl is-active nginx` returned `active`, and `curl -i http://127.0.0.1` returned `HTTP/1.1 200 OK` (`OK - app-ec2-project24-0101`).
- **Follow-Up / Prevention:** Enable automatic service restart (`Restart=always` in systemd) and health checks for automated recovery.
