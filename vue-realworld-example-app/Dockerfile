# Stage 1: Build the Vue app
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN yarn install --frozen-lockfile
COPY . .
ARG API_ROOT
ENV VUE_APP_API_URL=${API_ROOT}
RUN echo "API ROOT IS: ${VUE_APP_API_URL}"
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN yarn run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf