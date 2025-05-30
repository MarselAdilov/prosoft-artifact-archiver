FROM demisto/powershell:7.4.6.117357
RUN apk update && \
    apk add bash p7zip just curl
RUN pwsh -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; Install-Module Pester -Force"
COPY . /prosoft
WORKDIR /prosoft
