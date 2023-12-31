# The base image
FROM node:20-alpine as base

# Set the working directory
WORKDIR /app

# The build image
FROM base as build

# Install corepack and pnpm
RUN corepack enable && corepack prepare pnpm@8.12.1 --activate

# Copy the package files
COPY package.json pnpm-lock.yaml /app/

# Install the dependencies
RUN pnpm install --no-frozen-lockfile

# Copy the source files
COPY anchor /app/anchor
COPY web /app/web
COPY tsconfig.base.json /app/

# Build the source files
RUN pnpm nx build web --skip-nx-cache

# The production image
FROM base as production

# Install the 'serve' package to serve the static content
RUN npm install -g serve

# Copy the static content from the build image
COPY --from=build /app/dist/web /app/

# Expose the port
EXPOSE 80

# Start the server
CMD ["serve", "-s", ".", "-l", "80"]
