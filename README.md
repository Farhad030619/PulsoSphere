
PulsoSphere

PulsoSphere är ett bärbart system som mäter **EKG** (hjärta) och **EMG** (muskler) i realtid. Hårdvaran samlar signaler via **ADS1015** till **Raspberry Pi Zero 2 W**, där signalen filtreras och hjärtslag detekteras. Data skickas till ett **Flask-API** (MySQL/MariaDB) som konsumeras av en **Flutter-app** för live-grafer, puls (BPM) och historik.

> **Viktig notis:** Detta är ett student-/demoprojekt och **inte** avsett för medicinsk diagnostik eller kliniskt bruk.

---

## Innehåll
- [Översikt](#översikt)
- [Systemarkitektur](#systemarkitektur)
- [Funktioner](#funktioner)
- [Hårdvara](#hårdvara)
- [Projektstruktur](#projektstruktur)
- [Kom igång](#kom-igång)
  - [Backend (Flask + MySQL/MariaDB)](#backend-flask--mysqlmariadb)
  - [API](#api)
  - [Exponera API:t via ngrok (valfritt)](#exponera-apit-via-ngrok-valfritt)
  - [Mobilapp (Flutter)](#mobilapp-flutter)
- [Testning](#testning)
- [Säkerhet & sekretess](#säkerhet--sekretess)
- [Begränsningar & framtida arbete](#begränsningar--framtida-arbete)
- [Bidra](#bidra)
- [Licens](#licens)
- [Team & kurs](#team--kurs)

---

## Översikt
PulsoSphere demonstrerar en lågkostnadsplattform för bärbar fysiologimätning:
1. **Sensorer** (EKG/EMG) → 2. **ADC (ADS1015)** → 3. **Raspberry Pi Zero 2 W** (digital filtrering, R-toppdetektion, BPM) → 4. **Flask-API** (REST) + **MySQL/MariaDB** → 5. **Flutter-app** (livevisualisering & historik).

### Signalbehandling i korthet
- EKG filtreras med bandpass (t.ex. Butterworth ~0,25–10 Hz).
- R-toppar detekteras med en robust tröskel/logik.
- BPM beräknas löpande från R-R-intervall.
- EMG samplas och visas som amplitud/tidsserie.

---

## Systemarkitektur
```

[AD8232 EKG]  
>--[ ADS1015 (I²C) ]--> [ Raspberry Pi Zero 2 W ]
[MyoWare EMG] /                               |
v
[ Flask-API (REST) ] <--> [ MySQL/MariaDB ]
|
v
[ Flutter-app ]

```

- **Pi Zero 2 W:** centralenhet (Wi-Fi/BLE, 40-pin GPIO).
- **ADS1015:** 12-bitars ADC via I²C.
- **AD8232 (EKG)** ansluts till A0, **MyoWare 2.0 (EMG)** till A1.
- **API:** REST-endpoints för att *skicka in* (POST) och *hämta* (GET) senaste mätning.
- **App:** pollar backend periodiskt (t.ex. ~3 s), visar BPM, EKG-/EMG-grafer samt historik.

---

## Funktioner
- Realtids-EKG med digitalt bandpassfilter och R-toppdetektion → stabil BPM.
- EMG-insamling via MyoWare och visning i appen.
- Backend lagrar mätningar (BPM + listor för EKG/EMG + tidsstämpel) i databas.
- Flutter-appen har vyer för **Live EKG**, **Live EMG**, **Historik** och **Inställningar**.
- Valfri tunnel via **ngrok** när man vill demo:a utanför lokalt nät.

---

## Hårdvara
- **Raspberry Pi Zero 2 W** – central enhet.
- **ADS1015** – 12-bitars ADC via I²C.
- **AD8232** – EKG-modul (A0).
- **MyoWare 2.0** – EMG-modul (A1).
- **Eget PCB (KiCad)** – headers för modulär inkoppling, korta kablar, B.Cu-routing.

> Lägg gärna in KiCad-filer (scheman, PCB, Gerbers) i `/hardware/` om de inte redan finns.

---

## Projektstruktur
> Exempel – justera efter ert faktiska repo.
```

PulsoSphere/
├─ backend/
│  ├─ app.py
│  ├─ requirements.txt
│  └─ src/...
├─ app/                 # Flutter
│  ├─ lib/
│  ├─ pubspec.yaml
│  └─ android/ios/...
├─ hardware/            # KiCad, Gerbers, PDF-scheman
├─ docs/                # ev. extra dokumentation
└─ README.md

````

---

## Kom igång

### Förkrav
- **Backend:** Python 3.10+, Flask, flask-cors, MySQL-drivrutin (t.ex. `mysqlclient` eller `pymysql`), MySQL/MariaDB.
- **App:** Flutter SDK (3.x), Android Studio/VS Code, fysisk enhet eller emulator.
- **Pi:** Raspberry Pi OS, I²C aktiverat (`raspi-config` → Interface Options → I2C).

> Versionskrav kan behöva justeras efter verkliga `requirements.txt` och Flutterversion.

---

### Backend (Flask + MySQL/MariaDB)

1) **Skapa databas och tabell**
   ```sql
   CREATE DATABASE pulso DEFAULT CHARACTER SET utf8mb4;
   USE pulso;

   CREATE TABLE measurement (
     id BIGINT AUTO_INCREMENT PRIMARY KEY,
     bpm FLOAT NOT NULL,
     ekg LONGTEXT NOT NULL,   -- JSON-text (lista av samples)
     emg LONGTEXT NOT NULL,   -- JSON-text (lista av samples)
     ts  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
   );
````

2. **Konfigurera miljövariabler**

   ```bash
   # exempel – spara i .env (checka inte in) eller exportera i shell
   export DB_HOST=127.0.0.1
   export DB_PORT=3306
   export DB_USER=pulso_user
   export DB_PASS=superhemligt
   export DB_NAME=pulso
   export FLASK_APP=app.py
   export FLASK_ENV=development
   ```

3. **Installera och starta backend**

   ```bash
   cd backend
   python -m venv .venv
   source .venv/bin/activate   # Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   flask run -p 5000
   ```

   Backend kör nu på `http://localhost:5000` (eller Pi:ns IP om du kör där).

---

### API

#### POST `/data`

Tar emot senaste mätning:

```json
{
  "bpm": 62,
  "ekg": [120, 121, 119, ...],
  "emg": [8, 9, 7, ...]
}
```

**Svar (exempel):**

```json
{ "status": "ok", "id": 123 }
```

#### GET `/data`

Returnerar **senaste** mätningen (inkl. tidsstämpel). **Exempel:**

```json
{
  "id": 123,
  "bpm": 62.0,
  "ekg": [120, 121, 119, ...],
  "emg": [8, 9, 7, ...],
  "ts": "2025-05-30T11:22:33Z"
}
```

> **Rekommendationer**
>
> * CORS aktiverat i Flask om appen körs från annan origin.
> * Tydliga felkoder (4xx/5xx), inputvalidering, try/except kring DB.
> * I produktion: använd **HTTPS/TLS**, någon form av **auth** (t.ex. token/API-nyckel), samt ev. **rate limiting**.

---

### Exponera API:t via ngrok (valfritt)

Vill du demo:a utanför lokalt nät (t.ex. från Pi till mobilen via internet):

```bash
# installera & autentisera ngrok separat
ngrok http 5000
```

* Kopiera den publika **https-URL:en** som ngrok visar (t.ex. `https://abc123.ngrok.io`).
* Sätt den som `API_BASE_URL` i Flutter-appens konfiguration.

> **Viktigt:** Checka **inte** in ngrok-token eller hemliga URL:er i repo. ngrok är för **dev/demo**, inte för produktion.

---

### Mobilapp (Flutter)

1. **Konfigurera bas-URL**

   * Ange `API_BASE_URL`/`BASE_URL` i appens config (ex. Pi:ns IP: `http://<pi-ip>:5000` eller ngrok-URL).

2. **Installera och kör**

   ```bash
   cd app
   flutter pub get
   flutter run
   ```

   Appen pollar `/data` periodiskt (t.ex. var 3:e sekund), visar BPM och live-grafer för EKG och EMG samt en historikvy.

> **Tips:** Kör gärna backend och app på samma nät (LAN) för lägsta latens.

---

## Testning

* **Backend:** skriv enhetstester för API-endpoints (t.ex. `pytest`) och mocka DB-lagret.
* **App:** widget-tester för vyer/state, integrationstest för polling mot en lokal test-server.
* **Hårdvara:** mata in syntetiska vågformer (EKG-liknande) för att verifiera filtrering/R-toppdetektion.

---

## Säkerhet & sekretess

* Lagra inga personuppgifter i klartext. Undvik att checka in loggar eller rådata som kan kopplas till individ.
* Hantera hemligheter via miljövariabler/secret manager. Använd **HTTPS** om trafik går över internet.
* Lägg in en tydlig **disclaimer** i appen om icke-medicinsk användning.

---

## Begränsningar & framtida arbete

* Det planerade **analoga lågpassfiltret (~25 Hz)** uteblev p.g.a. komponentbrist → all filtrering sker digitalt.
* **Polling** (~3 s) fungerar för demo men ger onödig trafik. Överväg **WebSocket** eller **Server-Sent Events** för push.
* Vidare arbete: artefakthantering (rörelser/elektrod-loss), adaptiv tröskel, dataexport, användarprofiler.

---

## Bidra

PRs och issues välkomnas! Öppna gärna en issue för större förslag innan ni skickar PR.

* Följ kodstil/formatterare där det finns (t.ex. `black` för Python, `dart format` för Flutter).
* Skriv tester när det är rimligt.
* Dela aldrig hemligheter i PR/Issues.

---

## Licens

Lägg till en licensfil (`LICENSE`) – t.ex. **MIT**, **Apache-2.0** eller annan valfri OSS-licens.

---

## Team & kurs

**KTH – Projektkurs inom elektroteknik, del 2 (CM1002)**
Team: Dennis Vidmant, Farhad Jelve, Karib Kaykobad, Muse Dubet & Peter Karlström

---

## Kontakt

* Skapa en **issue** här i GitHub-repo:t.
* För kursrelaterade frågor: följ kursens kommunikationskanaler.

```

Vill du att jag byter ut kommandon/paths (t.ex. rätt mappnamn för backend och Flutter-appen) efter exakt struktur i ditt repo? Skicka gärna en snabb trädvy så uppdaterar jag canvasen.
```
