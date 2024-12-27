#!/bin/bash

set -e

mkdir -p \
    /share/data \
    /share/edge/traefik \
    /share/edge/cert-manager \
    /share/monitoring/uptime-kuma \
    /share/monitoring/signoz \
    /share/monitoring-postgres \
    /share/media/postgres \
    /share/media/sabnzbd/ \
    /share/media/sonarr/ \
    /share/media/radarr/ \
    /share/media/readarr/ \
    /share/apps/vaultwarden-postgres
