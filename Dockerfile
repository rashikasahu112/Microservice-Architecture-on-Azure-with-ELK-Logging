FROM node:alpine as build
WORKDIR /app
COPY . /app
ARG VITE_SERVER_URL
RUN npm install
RUN npm install vite@5.2.0
RUN npm run build
FROM nginx:1.25.3
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/sites-enabled/default
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
