# Selkies GLX desktop: KDE Plasma on its own X.Org server driven by the GPU.
# Ships Steam (namespace-free runtime wrapper), Wine, Firefox, Chrome, proot-apps.
# REQUIRES a GPU at runtime (NVIDIA via container toolkit, or AMD/Intel via /dev/dri).
FROM ghcr.io/selkies-project/selkies-glx-desktop:26.04

USER root
ENV DEBIAN_FRONTEND=noninteractive

# cloudflared — named tunnel (TUNNEL_TOKEN) or quick-tunnel fallback
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSL -o /usr/local/bin/cloudflared \
       https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared \
    && rm -rf /var/lib/apt/lists/*

# Session autostart entries (user app + tunnel) — Plasma honors XDG autostart
COPY desktop-autostart.desktop /etc/xdg/autostart/desktop-autostart.desktop
COPY tunnel-autostart.desktop /etc/xdg/autostart/tunnel-autostart.desktop
RUN chmod 644 /etc/xdg/autostart/*.desktop

# Helper scripts
COPY start-tunnel.sh /usr/local/bin/start-tunnel.sh
COPY autostart.sh /usr/local/bin/autostart.sh
RUN chmod +x /usr/local/bin/start-tunnel.sh /usr/local/bin/autostart.sh

# Return to the image's session user (uid 1000 = ubuntu) — this image is
# designed rootless; root is only for the build layers above
USER 1000

ENV SELKIES_ENABLE_HTTPS=true
ENV PASSWD=changeme

EXPOSE 8080
