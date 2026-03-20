# Guia Ràpida: Deploy a Render

## 🎯 Objectiu
Executar la teva aplicació Rails a Render.com en lloc de localment.

## ✅ JA ESTÀ PREPARAT

Aquí pots trobar els fitxers creats per a la configuració:

| Fitxer | Propòsit |
|--------|----------|
| `Gemfile` aprovat | Afegit PostgreSQL per a producció |
| `config/database.yml` | Configurat per a PostgreSQL a Render |
| `Dockerfile` | Actualitzat amb PostgreSQL dependencies |
| `render.yaml` | Configuració de Render |
| `RENDER_DEPLOYMENT.md` | Documentació completa |
| `RENDER_CHECKLIST.md` | Passos pas-a-pas |

---

## 📝 PROXIMS PASSOS (Tu)

### 1. Confirma que estàs a Git

```bash
git status
```

### 2. Afegeix els canvis

```bash
git add .
git commit -m "Prepare for Render deployment - PostgreSQL + Docker config"
```

### 3. Fa push al repositori de GitHub

```bash
git push origin main
```

---

## 🚀 A RENDER.COM

Vés a [render.com](https://render.com) i segueix els passos:

### 1. Connecta el repositori de GitHub

- Crea un compte si no en tens
- Authoritza Render a accedir a GitHub
- Selecciona el repositori `ASW---Projecte-1-Issue-Tracker`

### 2. Crea Web Service (dockerfile)

- Nom: `issue-tracker`
- Dockerfile: deixa per defecte
- Start: `bin/docker-entrypoint`

### 3. Afegeix variables d'entorn

```
RAILS_ENV = production
RAILS_LOG_TO_STDOUT = true
RAILS_MASTER_KEY = (de config/master.key)
```

### 4. Crea PostgreSQL Database

- Nom: `issue-tracker-db`
- Copy "Internal Database URL"
- Afegeix com a variable `DATABASE_URL` a la Web Service

### 5. Deploy i Migracions

- Clica "Create"
- Espera a que estigui deployat (status verd)
- Clica "Shell" i executa: `bin/rails db:migrate`

---

## ✨ Listo!

La teva aplicació estarà en viu a una URL com:
```
https://issue-tracker.onrender.com
```

---

## 📖 Per a més detalls

- Vés a `RENDER_DEPLOYMENT.md` per a documentació completa
- Vés a `RENDER_CHECKLIST.md` per a una llista detallada
- Logs disponibles a Render Dashboard → "Logs"

---

## 🆘 Suport Ràpid

**Error de base de dades?**
```bash
# A Render Shell:
bin/rails db:migrate
```

**Vols veure logs?**
```bash
# A Render Dashboard → Logs tab
# Busca errors de PostgreSQL o Rails
```

**Vols parar el deploy?**
```
Render Dashboard → Deployments → Cancel
```

---

**Data creació:** Març 2026  
**Projecte:** ASW Issue Tracker  
**Platform:** Render.com + PostgreSQL + Rails 8.1
