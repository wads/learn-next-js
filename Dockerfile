FROM node:20.16.0-alpine AS base
# 参考: https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile

RUN corepack enable pnpm

# Install dependencies only when needed
FROM base AS deps
# TODO: pythonのバージョン指定
#     : https://qiita.com/milkchocolate/items/87c773ea121eeae72f03
RUN apk update && apk add --no-cache g++ python3 make
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
RUN pnpm i --frozen-lockfile


# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
# COPY . .
RUN pnpm run build


FROM base AS dev_runner
WORKDIR /app
ENV NODE_ENV=development
# COPY --from=builder /app/.next ./.next
# COPY --from=builder /app/node_modules ./node_modules
# COPY --from=builder /app/package.json ./package.json
COPY . .
CMD ["pnpm", "dev"]
