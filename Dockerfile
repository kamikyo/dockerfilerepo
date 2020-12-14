ARG REPO=mcr.microsoft.com/dotnet/core/runtime
FROM $REPO:3.1-alpine3.12

# Install ASP.NET Core
RUN aspnetcore_version=3.1.7 \
    && wget -O aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/$aspnetcore_version/aspnetcore-runtime-$aspnetcore_version-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='43df2fa8660a9dff03cf8412ad7a78f9e790be0cbcabc69c4ab69c640a3efbe3327cd2f98101dd6adf8a8a51e2692a2404358c2a3457321098dc815cc87c55dc' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && tar -ozxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz \
    && apk add --no-cache icu-libs \
    && apk add unixODBC \
    && apk add unixODBC-devel \
    && wget https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.6.1.1-1_amd64.apk \
    && wget https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.6.1.1-1_amd64.apk \
    && apk add gnupg \
    && wget https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.6.1.1-1_amd64.sig \
    && wget https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.6.1.1-1_amd64.sig \
    && wget https://packages.microsoft.com/keys/microsoft.asc | gpg --import - \
    && gpg --verify msodbcsql17_17.6.1.1-1_amd64.sig msodbcsql17_17.6.1.1-1_amd64.apk \
    && gpg --verify mssql-tools_17.6.1.1-1_amd64.sig mssql-tools_17.6.1.1-1_amd64.apk \
    && apk add --allow-untrusted msodbcsql17_17.6.1.1-1_amd64.apk \
    && apk add --allow-untrusted mssql-tools_17.6.1.1-1_amd64.apk
    
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
