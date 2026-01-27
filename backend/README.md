# Backend & Local Database

This directory contains logic for the offline backend.

## Structure
- `local_db/`: SQLite database schema and migration scripts.
- `treatment_engine/`: Logic and data for mapping diseases to treatments.
- `data/`: JSON files for static content (diseases, treatments).

## Database
The app uses `sqflite`. The database file will be stored in the app's document directory.
