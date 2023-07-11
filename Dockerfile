#It will use node:19-alpine3.16 as the parent image for building the Docker image
FROM node:19-alpine3.16 as BUILDER
WORKDIR /react-app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:latest
WORKDIR /nginx
COPY --from=BUILDER /app/build /usr/share/nginx/html
EXPOSE 80
