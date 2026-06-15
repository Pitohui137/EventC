# Supabase Database Schema Setup Guide

## Overview
This document describes the database schema for the Campus Event Management System.

## Tables

### 1. **users** (Authentication Users)
Extends Supabase Auth with additional user information.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid (PK) | User ID (references auth.users) |
| email | text (UNIQUE) | User email address |
| nama | text | Full name |
| role | text | Role: 'admin' or 'user' |
| nomor_hp | text | Phone number (optional) |
| asal | text | Origin/Institution (optional) |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |

**Indexes:** email, role

---

### 2. **event**
Stores event information.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid (PK) | Event ID |
| nama | text | Event name |
| deskripsi | text | Event description |
| tipe | text | Type: 'seminar', 'workshop', or 'lomba' |
| lokasi | text | Event location |
| tanggal_mulai | timestamp | Start date/time |
| tanggal_selesai | timestamp | End date/time |
| batas_pendaftaran | timestamp | Registration deadline |
| kapasitas | integer | Maximum capacity |
| terdaftar | integer | Current registrations (auto-updated) |
| pendaftaran_ditutup | boolean | Registration closed flag |
| admin_id | uuid (FK) | Event administrator ID |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |

**Constraints:**
- `tanggal_mulai <= tanggal_selesai`
- `batas_pendaftaran <= tanggal_mulai`

**Indexes:** admin_id, tipe, tanggal_mulai, pendaftaran_ditutup

---

### 3. **pendaftaran** (Registrations)
Tracks user registrations for events.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid (PK) | Registration ID |
| user_id | uuid (FK) | User ID |
| event_id | uuid (FK) | Event ID |
| tanggal_daftar | timestamp | Registration date/time |
| status | text | Status: 'aktif', 'batal', or 'selesai' |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |

**Constraints:**
- `UNIQUE(user_id, event_id)` - Prevents duplicate registrations

**Indexes:** user_id, event_id, status, (user_id, event_id)

---

### 4. **tiket** (Digital Tickets)
Digital tickets for confirmed registrations.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid (PK) | Ticket ID |
| pendaftaran_id | uuid (FK) | Registration ID |
| nomor_tiket | text (UNIQUE) | Unique ticket number |
| qr_code | text | QR code data (encoded ticket info) |
| tanggal_buat | timestamp | Creation date/time |
| sudah_digunakan | boolean | Used flag |
| tanggal_digunakan | timestamp | When ticket was used (optional) |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |

**Constraints:**
- `UNIQUE(pendaftaran_id)` - One ticket per registration

**Indexes:** pendaftaran_id, nomor_tiket, sudah_digunakan

---

## Row Level Security (RLS) Policies

### Users Table
- ✅ Users can view their own profile
- ✅ Users can update their own profile
- ✅ Admins can view all users

### Event Table
- ✅ Anyone can view events
- ✅ Only admins can create events
- ✅ Event admin can update/delete their own events

### Pendaftaran Table
- ✅ Users can view their own registrations
- ✅ Users can register for events
- ✅ Admins can view registrations for their events

### Tiket Table
- ✅ Users can view their own tickets
- ✅ Admins can view all tickets

---

## Triggers & Functions

### 1. **create_ticket_on_registration()**
Automatically creates a digital ticket when a user registers.
- Generates unique ticket number: `TKT-{registration_id}-{YYYYMMDD}`
- Encodes QR code data: `{ticket_number}|{event_id}|{user_id}`

### 2. **update_event_terdaftar()**
Automatically updates event registration count when:
- User registers: increments `terdaftar`
- User cancels: decrements `terdaftar`

### 3. **update_updated_at()**
Automatically updates `updated_at` timestamp on any record modification.

---

## Setup Instructions

### Step 1: Create Supabase Project
1. Go to https://supabase.com
2. Sign up or log in
3. Create a new project
4. Wait for project initialization

### Step 2: Run SQL Migration
1. In Supabase dashboard, go to **SQL Editor**
2. Click **New Query**
3. Copy and paste the entire content from `supabase/migrations/001_init_schema.sql`
4. Click **Run**

### Step 3: Verify Tables
1. Go to **Table Editor**
2. Verify all tables are created:
   - users
   - event
   - pendaftaran
   - tiket

### Step 4: Get Credentials
1. Go to **Settings** → **API**
2. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (Anonymous key for client-side)
   - **service_role key** (For server-side operations - keep secret)

### Step 5: Update Flutter App
In `lib/main.dart`, replace:
```dart
await Supabase.initialize(
  url: 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

---

## ER Diagram

```
┌─────────────┐
│    users    │
├─────────────┤
│ id (PK)     │
│ email       │
│ nama        │
│ role        │
│ nomor_hp    │
│ asal        │
└─────────────┘
      │ 1
      │
      │ M
┌──────────────┐       ┌────────────────┐
│    event     │◄──────┤  pendaftaran   │
├──────────────┤       ├────────────────┤
│ id (PK)      │       │ id (PK)        │
│ nama         │       │ user_id (FK)   │
│ deskripsi    │       │ event_id (FK)  │
│ tipe         │       │ tanggal_daftar │
│ lokasi       │       │ status         │
│ tanggal_*    │       └────────────────┘
│ kapasitas    │             │ 1
│ terdaftar    │             │
│ admin_id (FK)│             │ 1
└──────────────┘       ┌──────────────┐
                       │    tiket     │
                       ├──────────────┤
                       │ id (PK)      │
                       │ pendaftaran_ │
                       │   id (FK)    │
                       │ nomor_tiket  │
                       │ qr_code      │
                       │ sudah_digunakan
                       └──────────────┘
```

---

## Testing Queries

### Create Test Admin User
```sql
INSERT INTO auth.users (id, email, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'admin@example.com',
  now(),
  '{"provider":"email","providers":["email"]}',
  '{}',
  now(),
  now()
);
```

Then insert into users table with role='admin'.

### View All Events
```sql
SELECT * FROM event ORDER BY tanggal_mulai;
```

### View Registration Statistics
```sql
SELECT 
  e.nama,
  e.kapasitas,
  COUNT(p.id) as terdaftar,
  (e.kapasitas - COUNT(p.id)) as tersisa
FROM event e
LEFT JOIN pendaftaran p ON e.id = p.event_id
GROUP BY e.id, e.nama, e.kapasitas;
```

---

## Notes
- All timestamps use UTC timezone
- RLS is enabled for security
- Triggers handle automatic updates
- Foreign keys cascade on delete
- Unique constraints prevent duplicates
