# Deploy a Render - Guia Completa

## Prerequisites
1. Compte a [Render.com](https://render.com)
2. Repositori de GitHub amb el codi
3. `SECRET_KEY_BASE` per a la producció

## Passos de Deploy

### 1. Preparar el repositori

Assegura't que tots aquests fitxers están al repositori:
- `Gemfile` (amb PostgreSQL afegit)
- `Dockerfile`
- `build.sh` (script de build per a Render)
- `config/database.yml` (configurat per a producció)
- `config/puma.rb` (configurat per a Render)

### 2. A la consola de Render

#### Crear una nova Web Service:
1. Accedeix a [dashboard.render.com](https://dashboard.render.com)
2. Clica a **"New +"** → **"Web Service"**
3. Selecciona **"Deploy an existing repository"**
   - Connecta el teu repositori de GitHub
   - Selecciona el repositori `ASW---Projecte-1-Issue-Tracker`

#### Configuració de la Web Service:

| Camp | Valor |
|------|-------|
| **Name** | `issue-tracker` (o el nom que preferiu) |
| **Environment** | `Docker` |
| **Region** | `Frankfurt` (o el més proper) |
| **Branch** | `main` |
| **Build Command** | Deixar en blanc (usarà Dockerfile) |
| **Start Command** | `bin/docker-entrypoint` |

#### Variables d'Entorn:

Afegeix aquestes variables dins de **"Environment"**:

```plaintext
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_MASTER_KEY=(veure pas 3)
```

### 3. Obtenir RAILS_MASTER_KEY

La clau mestra es troba en:
```
config/master.key
```

- Copia el contingut d'aquest fitxer
- Afegeix-lo com a variable d'entorn `RAILS_MASTER_KEY` a Render

⚠️ **IMPORTANT**: No facis push d'aquest fitxer a GitHub!

### 4. Crear Database (PostgreSQL)

1. A Render, clica **"New +"** → **"PostgreSQL"**
2. Configura:
   - **Name**: `issue-tracker-db`
   - **Database**: `issue_tracker`
   - **User**: `rails`
   - Deixa la resta per defecte

3. Copia la **Database URL** interna (comença amb `postgresql://...`)

4. Afegeix a Render Web Service com a variable:
   ```
   DATABASE_URL=(pega la URL que has copiat)
   ```

### 5. Deploy i Migracions

1. El primer deploy es farà automàticament
2. Quan estigui deployat, accedeix a la consola:
   - Shell → `bash`
   - Executa les migracions:
   ```bash
   bin/rails db:migrate
   bin/rails db:seed
   ```

### 6. Veure logs

A la consola de Render → **"Logs"** top dreta per veure els logs en temps real.

## Configuracions Importants

### Database
La base de dades es configura automàticament usant la variable `DATABASE_URL` a `config/database.yml`.

### Assets
Els assets es precompilen durant el build (dins del Dockerfile).

### Records DNS (si tens domini personalitzat)
1. A Render, copia el **Custom Domain** que et proporciona
2. Afegeix un registro CNAME al teu DNS:
   ```
   nom.exemple.com  CNAME  issue-tracker.onrender.com
   ```

## Troubleshooting

### Error: "Could not find declarative gems in Gemfile"
- Assegura't que tens `Gemfile.lock` al repositori
- Executa `bundle install` localment i fa push

### Error: "ActiveRecord::PendingMigrationError"
- A la consola de Render, executa: `bin/rails db:migrate`

### Error: "rails/master.key is missing"
- Verifica que la variable `RAILS_MASTER_KEY` está correctament establerta a Render

### Port 4000 busy
- Render usa automàticament el port 3000, no cal canviar res

## Actualitzacions Posteriors

Cada vegada que facis push a `main`:
1. Render detectarà els canvis automàticament
2. Farà un rebuild i deploy
3. Pots veure el progres a la consola

Per a parar el deploy si hi ha errors:
- A Render → **"Deployments"** → Clica el deploy actual → **"Cancel"**

---

**Nota**: Si la base de dades és nova, necessitarás executar les migracions manualment la primera vegada.
