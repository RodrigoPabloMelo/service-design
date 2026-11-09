# Front-end: Flutter Web (loop de design) servido por nginx.
# O deploy do Studio builda a branch `design` com o entry main_design.dart.

FROM ghcr.io/cirruslabs/flutter:3.35.3 AS build
WORKDIR /app
COPY pubspec.yaml pubspec.loc[k] ./
RUN flutter pub get
COPY . .
ARG ENTRY=lib/main_design.dart
ARG API_BASE_URL=/api
# SHA curto do commit (injetado pelo deploy.yml) — vira /version.json pro
# checklist pós-deploy e pro futuro banner de atualização (goldenpath doc 14).
ARG APP_VERSION=local
# --pwa-strategy none: sem Service Worker — o cache é controlado só pelos
# headers do nginx + hash nos nomes dos bundles (goldenpath web-cache-busting).
RUN flutter build web --release -t ${ENTRY} \
    --pwa-strategy none \
    --dart-define=API_BASE_URL=${API_BASE_URL} \
 && echo "{\"version\": \"${APP_VERSION}\"}" > build/web/version.json

FROM nginx:1.27-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 3000
