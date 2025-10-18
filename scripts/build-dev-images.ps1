Write-Host "Building sales-api dev image (with dev dependencies)..."
docker build --pull --no-cache --build-arg INSTALL_DEV=1 -t qoder2-sales-api:dev ./backend/sales-api
Write-Host "Built qoder2-sales-api:dev"
