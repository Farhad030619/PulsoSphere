# PulsoSphere — Bärbart EKG/EMG-system

PulsoSphere är ett öppet studentprojekt som bygger ett **bärbart armband** som *samtidigt* mäter **EKG** (hjärtrytm) och **EMG** (muskelaktivitet) och visar data i **realtid** i en mobilapp. Systemet består av:
- **Hårdvara:** Raspberry Pi Zero 2 W + ADS1015 (ADC), AD8232 (EKG), MyoWare 2.0 (EMG) + eget PCB
- **Backend:** Flask-API som tar emot/returnerar mätdata och lagrar i databas (MySQL/SQLite)
- **App:** Flutter-klient med Live-vyer, Historik och Inställningar

> **Obs!** Detta är **inte en medicinsk produkt**. Används endast för utbildning/utveckling.

---

## Funktioner
- Samtidig EKG/EMG-insamling
- Realtidsfiltrering av EKG (Butterworth bandpass) + R-toppdetektion → BPM
- REST-API (`POST /data`, `GET /data`) med DB-lagring (MySQL/SQLite)
- Flutter-app (Live EKG/EMG, Historik, Inställningar)
- Modulär hårdvara med eget PCB (KiCad)

---

## Repo-struktur
