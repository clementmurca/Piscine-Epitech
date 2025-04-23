# Dockerfile - web_interfaces

# use official image node
FROM node:16 as build-stage

# Define working folder
WORKDIR /app

# Copy files required for install dependencies
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the project
COPY . .

# Build app Vue.js
RUN npm run build

# Use Nginx for app
FROM nginx:alpine as production-stage

COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copy the custom nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf


# Expose port for Nginx
EXPOSE 80

# command to launch Nginx
CMD ["nginx", "-g", "daemon off;"]