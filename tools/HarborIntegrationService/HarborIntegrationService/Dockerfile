FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 5038
ENV ASPNETCORE_HTTP_PORTS=5038

RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install sbom2doc --break-system-packages

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["HarborIntegrationService.csproj", "./"]
RUN dotnet restore "HarborIntegrationService.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "HarborIntegrationService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "HarborIntegrationService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
# TODO: Remove the two succeeding lines when deploying to Production.
#ENV ASPNETCORE_URLS=http://+:5038
ENV ASPNETCORE_ENVIRONMENT=Development
ENTRYPOINT ["dotnet", "HarborIntegrationService.dll"]