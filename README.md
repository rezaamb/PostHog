ابتدا به فایل خودمون دسترسی اجرایی میدیم :
```bash
chmod +x install-posthog-haproxy.sh
```
سپس اونو اجرا میکنیم :
```bash
./install-posthog-haproxy.sh
```


وقتی دیدیم که اوکی بود روی systemd اجراش میکنیم :

ابتدا یک فایل در systemd میسازیم :
```bash
sudo vim /etc/systemd/system/posthog.service
```

سپس کانفیگ زیر رو در اون قرار میدیم:
```bash
[Unit]
Description=PostHog Install and Start Service
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=root
ExecStart=/bin/bash ExecStart=/bin/bash /root/install-posthog-haproxy.sh

Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```
سرویس رو ریفرش کن، فعال و استارت کن:
```bash
sudo systemctl daemon-reload
sudo systemctl enable posthog.service
sudo systemctl start posthog.service
```
سپس وضعیت رو چک کن:
```bash
sudo systemctl status posthog.service
```
