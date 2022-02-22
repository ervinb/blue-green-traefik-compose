http:
  routers:
    docker-localhost:
      rule: Host(`docker.localhost`)
      service: ${SERVICE_TO_UPDATE}