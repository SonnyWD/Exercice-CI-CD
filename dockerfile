# Builder (compilation du projet)
FROM node:lts-alpine AS builder

WORKDIR /app

# Copier les fichiers de gestion des dépendances
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier tout le code source
COPY . .

# Compiler le projet TypeScript
RUN npm run build




# Image finale plus légère
#FROM node:lts-alpine 
# Image distroless
FROM gcr.io/distroless/nodejs22-debian12

WORKDIR /app

# Copier uniquement les fichiers nécessaires depuis l'étape builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules 
USER nonroot chown=user:nonroot:nonroot --from=builder /app/package*.json ./
# Installer uniquement les dépendances de production
#RUN npm install --production
USER nonroot
# Sécurité : créer un user non-root
#RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
  #&& chown -R appuser:appgroup /app
#USER appuser

# Exposer le port sur lequel NestJS écoute (par défaut 3000)
EXPOSE 3000

# Commande pour démarrer l’application
#CMD ["npm", "run", "start:prod"]
CMD ["dist/main.js"]
