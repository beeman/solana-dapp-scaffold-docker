# The base image
FROM node:20-alpine as base

RUN corepack enable && corepack prepare pnpm@8.12.1 --activate

# The build image
FROM base as build

WORKDIR /scratch

COPY package.json pnpm-lock.yaml /scratch/

RUN pnpm install --no-frozen-lockfile

COPY anchor /scratch/anchor
COPY web /scratch/web
COPY tsconfig.base.json /scratch/

RUN pnpm nx build web --skip-nx-cache

RUN find /scratch/dist/web

# The production image
FROM base as production

# Install the 'serve' package to serve the static content
RUN npm install -g serve

WORKDIR /app

COPY --from=build /scratch/dist/web /app/

EXPOSE 80

CMD ["serve", "-s", ".", "-l", "80"]
