- name: Docker build & push para ACR
  env:
    ACR_LOGIN: ${{ steps.tfout.outputs.acr }}
    TAG: ${{ github.sha }}
  run: |
    az acr login --name ${ACR_LOGIN%%.*}
    docker buildx create --use --name dino || true
    docker buildx build \
      --platform linux/amd64 \
      -f www/Dockerfile \        # <- Dockerfile nessa pasta
      -t "$

