#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS build
WORKDIR /src
COPY ["finaltestreactdotnet.csproj", ""]
RUN dotnet restore "./finaltestreactdotnet.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "finaltestreactdotnet.csproj" -c Release -o /app/build
FROM node:12-alpine as build-node
FROM build AS publish
RUN dotnet publish "finaltestreactdotnet.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=build-node /ClientApp/build ./ClientApp/build
CMD ASPNETCORE_URLS=http://*:$PORT dotnet finaltestreactdotnet.dll