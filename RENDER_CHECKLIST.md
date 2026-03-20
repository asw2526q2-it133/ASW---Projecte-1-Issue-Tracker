# Checklist Deploy a Render

## ✅ Passos a Fer AQUÍ (localment)

- [x] Afegir PostgreSQL al `Gemfile`
- [x] Actualitzar `config/database.yml` per a PostgreSQL
- [x] Actualitzar `Dockerfile` amb dependencies de PostgreSQL
- [x] Crear `render.yaml` amb la configuració

**Tu has de:**
1. Executa `bundle lock --add-platform x86_64-linux` (perquè Linux executarà el codi)
2. Fa `git add .` i `git commit -m "Prepare for Render deployment"`
3. Fa `git push` al repositori de GitHub

---

## 🚀 Passos a Render (render.com)

### 1️⃣ Crear la Web Service
```
1. Accedeix a https://dashboard.render.com
2. Clica "New +" → "Web Service"
3. Selecciona "Deploy an existing repository"
4. Busca i selecciona ASW---Projecte-1-Issue-Tracker
```

### 2️⃣ Configurar la Web Service
```
Name:              issue-tracker
Environment:       Docker
Region:            Frankfurt (o el més proper)
Branch:            main
Build Command:     (deixar en blanc)
Start Command:     bin/docker-entrypoint
```

### 3️⃣ Configurar Variables d'Entorn

Afegeix aquestes variables (busca "Environment" al formulari):

| Variable | Valor |
|----------|-------|
| `RAILS_ENV` | `production` |
| `RAILS_LOG_TO_STDOUT` | `true` |
| `RAILS_MASTER_KEY` | (veure pas 4) |

### 4️⃣ Obtenir RAILS_MASTER_KEY
```
1. Obri el fitxer: config/master.key
2. Copia el contingut (és una linia de text)
3. Afegeix-la com a variable `RAILS_MASTER_KEY` a Render
```

### 5️⃣ Crear la Base de Dades

```
1. Clica "New +" → "PostgreSQL"
2. Configura:
   - Name:     issue-tracker-db
   - Database: issue_tracker
   - Deixa la resta per defecte
3. Copia la "Internal Database URL"
```

### 6️⃣ Connectar la BD a la Web Service

```
1. Torna a la Web Service → "Environment"
2. Afegeix nova variable:
   Name:  DATABASE_URL
   Value: (pega la URL que has copiat)
```

### 7️⃣ Deploy Inicial
```
1. Clica "Create Web Service"
2. Render farà automàticament el deploy
3. Pots veure els logs a "Logs" (top dreta)
```

### 8️⃣ Executar Migracions (IMPORTANT!)

Quan el deploy estigui completat (status verd):

```
1. Clica "Shell" (top dreta)
2. Escriu: bin/rails db:migrate
3. Espera a que termini
4. Opcionalment: bin/rails db:seed (si vols dades de prova)
```

---

## 📋 Resultats Esperats

✅ Base de dades PostgreSQL connectada  
✅ Assets precompilats  
✅ Logs sense errors de base de dades  
✅ Web accessible a URL proporcionada per Render  

---

## 🔗 Links Útils

- [Dashboard Render](https://dashboard.render.com)
- [Render Docs Rails](https://render.com/docs/deploy-rails)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

---

## ❌ Si Hi Ha Errors

**"Could not find declarative gems in Gemfile"**
```bash
# Localment:
bundle install
bundle lock --add-platform x86_64-linux
git add . && git commit -m "Update Gemfile.lock" && git push
```

**"ActiveRecord::PendingMigrationError"**
```bash
# A Render (Shell):
bin/rails db:migrate
```

**"RAILS_MASTER_KEY is missing"**
```
Verifica que la variable RAILS_MASTER_KEY estigui a Render Environment
```

**"Connection to database... refused"**
```bash
# A Render (Shell):
bin/rails dbconsole
# Si funciona, la connexió està bé
```

---

## 📞 Suport

Si tens problemes:
1. Mira els logs a Render → "Logs"
2. Revisa que DATABASE_URL estigui correcta
3. Assegura't que RAILS_MASTER_KEY és exacta (sense espais)
4. Prova `bin/rails db:setup` a Render Shell
