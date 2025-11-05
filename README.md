# PulsoSphere — Bärbart EKG/EMG-system

PulsoSphere är ett öppet studentprojekt som bygger ett **bärbart armband** som *samtidigt* mäter **EKG** (hjärtrytm) och **EMG** (muskelaktivitet) och visar data i **realtid** i en mobilapp. Systemet består av:

* **Hårdvara:** Raspberry Pi Zero 2 W + ADS1015 (ADC), AD8232 (EKG), MyoWare 2.0 (EMG) + eget PCB
* **Backend:** Flask-API som tar emot/returnerar mätdata och lagrar i databas (MySQL/SQLite)
* **App:** Flutter-klient med Live-vyer, Historik och Inställningar

> **Obs!** Detta är **inte en medicinsk produkt**. Använd endast för utbildning/utveckling.

---

## Funktioner

* Samtidig insamling av EKG & EMG
* Realtidsfiltrering av EKG (Butterworth bandpass) + R-toppdetektion → BPM
* REST-API (`POST /data`, `GET /data`) med DB-lagring (MySQL/SQLite)
* Flutter-app (Live EKG/EMG, Historik, Inställningar)
* Modulär hårdvara med eget PCB (KiCad)

---

## Repo-struktur

```
PulsoSphere/
├─ backend/
│  └─ flask-api/           # Flask-API + DB-integration (app_db.py, db.py)
├─ device/
│  └─ pi-scripts/          # Raspberry Pi-kod (ADC-läsning, filtrering, POST till API)
├─ mobile/
│  └─ flutter-app/         # Flutter-klient
├─ db/
│  ├─ mysql/schema.sql     # MySQL-schema (measurements)
│  └─ sqlite/schema.sql    # SQLite-schema
├─ docs/                   # Bilder, pinout, BOM, API-dokumentation m.m.
└─ .github/workflows/ci.yml
```

---

## Kom igång

### 1) Backend (Flask + DB)

**Krav:** Python 3.10+

```bash
cd backend/flask-api
python -m venv .venv && source .venv/bin/activate   # Win: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
```

Fyll i `.env`:

```
# mysql eller sqlite
DB_DIALECT=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=appuser
DB_PASS=hemligt
DB_NAME=pulso

# För SQLite: DB_DIALECT=sqlite och DB_NAME=./pulsosphere.db
```

Starta API:

```bash
python app_db.py   # http://localhost:5001
```

Snabbtest:

```bash
curl -X POST http://localhost:5001/data \
  -H "Content-Type: application/json" \
  -d '{"bpm":64,"ekg":[0.1,0.2,0.3],"emg":[0.05,0.06,0.07]}'
curl http://localhost:5001/data
```

### 2) Databas

* **MySQL:** kör `db/mysql/schema.sql` i Workbench/CLI för att skapa `pulso` + `measurements`.
* **SQLite:** ingen extra setup (fil skapas automatiskt av backend).

### 3) Device (Raspberry Pi)

Pi-koden (i `device/pi-scripts/`) läser ADS1015/AD8232/MyoWare, filtrerar och skickar till API:

```python
import requests
payload = {"bpm": bpm, "ekg": ekg_samples, "emg": emg_samples}
requests.post("http://<backend-ip>:5001/data", json=payload, timeout=5)
```

Tips:

* Skicka ~1 paket/sek eller efter varje beräknad BPM för rimlig nättrafik.
* Lägg till retry/backoff vid nätverksfel.

### 4) Mobil (Flutter)

**Krav:** Flutter 3.x

```bash
cd mobile/flutter-app
flutter pub get
flutter run
```

Minimal fetch i appen:

```dart
final res = await http.get(Uri.parse('http://<backend-ip>:5001/data'));
if (res.statusCode == 200) {
  final data = jsonDecode(res.body);
  final bpm = data['bpm'];
  // TODO: uppdatera UI med bpm/ekg/emg
}
```

---

## API

**POST `/data`**

* Body (JSON):

```json
{ "bpm": 62, "ekg": [0.1, 0.2, 0.3], "emg": [0.05, 0.06, 0.07] }
```

* Svar:

```json
{ "status": "ok" }
```

**GET `/data`**

* Svar (JSON, senaste mätningen):

```json
{ "id": 123, "ts": "2025-11-05T12:34:56", "bpm": 62, "ekg": [...], "emg": [...] }
```

> Lägg gärna fler exempel och framtida endpoints i `docs/API.md`.

---

## Hårdvara (översikt)

* **Raspberry Pi Zero 2 W**
* **ADS1015** (I²C A/D)
* **AD8232** (EKG), **MyoWare 2.0** (EMG)
* Eget **PCB** (KiCad)

Rekommenderade dokument i `docs/`:

* `pinout.md` — Pi ↔ ADS1015 ↔ AD8232/MyoWare (text + bild)
* `BOM.md` — komponentlista (del, mängd, länk)
* `enclosure.md` — armbands-/låddesign (valfritt)

---

## Utveckling & bidrag

* Brancher: `feat/...`, `fix/...`, `chore/...`

* Konventionella commit-meddelanden:

  * `feat(api): add /history endpoint`
  * `fix(device): stabilize R-peak detector`
  * `docs(readme): update quickstart`

* PR-checklista:

  * [ ] Beskriv syfte och ändringar
  * [ ] Uppdatera README/docs vid behov
  * [ ] Kör analyser/tester lokalt

Se `CONTRIBUTING.md` (valfritt).

---

## CI

GitHub Actions kör:

* Backend: installerar krav och kompilerar Python
* Flutter: `flutter pub get` + `flutter analyze`

Workflow: `.github/workflows/ci.yml`

```yaml
name: CI
on: [push, pull_request]
jobs:
  backend:
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: backend/flask-api } }
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - run: pip install -r requirements.txt
      - run: python -m py_compile app_db.py db.py
  flutter:
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: mobile/flutter-app } }
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.24.0' }
      - run: flutter pub get
      - run: flutter analyze
```

---

## Felsökning

* **Glömt MySQL-lösenord?** Starta MySQL med `--skip-grant-tables` och kör `ALTER USER 'root'@'localhost' IDENTIFIED BY 'NyLösen!'`, starta om normalt.
* **CORS i appen?** CORS är aktiverat i Flask (flask-cors). Säkerställ att appen pekar mot rätt IP/port.
* **Tomma svar från `/data`?** Kontrollera att Pi skickar JSON som `{ bpm, ekg[], emg[] }` och att DB-uppkoppling är korrekt i `.env`.

---

## Säkerhet & integritet

* **Inte en medicinsk produkt**; ingen diagnos eller behandling.
* Lagra aldrig hemligheter i git. Använd `.env` (ignoreras av `.gitignore`).
* Begränsa MySQL-användare (t.ex. `appuser`) till endast nödvändiga privilegier.

---

## Roadmap (förslag)

* `/history?from=..&to=..` + aggregation per minut/timme
* Signal-/rörelsestörningshantering, bättre filtrering
* App: förbättrad historik med sök/filtrering och export

---

## Licens

MIT — se `LICENSE`.