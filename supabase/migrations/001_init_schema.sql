-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==================== USERS TABLE ====================
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  nama text NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'user')),
  nomor_hp text,
  asal text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create index on email and role for faster queries
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- ==================== EVENT TABLE ====================
CREATE TABLE IF NOT EXISTS event (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  nama text NOT NULL,
  deskripsi text,
  tipe text NOT NULL CHECK (tipe IN ('seminar', 'workshop', 'lomba')),
  lokasi text NOT NULL,
  tanggal_mulai timestamp with time zone NOT NULL,
  tanggal_selesai timestamp with time zone NOT NULL,
  batas_pendaftaran timestamp with time zone NOT NULL,
  kapasitas integer NOT NULL CHECK (kapasitas > 0),
  terdaftar integer DEFAULT 0 CHECK (terdaftar >= 0),
  pendaftaran_ditutup boolean DEFAULT false,
  admin_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT valid_dates CHECK (tanggal_mulai <= tanggal_selesai),
  CONSTRAINT batas_before_mulai CHECK (batas_pendaftaran <= tanggal_mulai)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_event_admin_id ON event(admin_id);
CREATE INDEX IF NOT EXISTS idx_event_tipe ON event(tipe);
CREATE INDEX IF NOT EXISTS idx_event_tanggal_mulai ON event(tanggal_mulai);
CREATE INDEX IF NOT EXISTS idx_event_pendaftaran_ditutup ON event(pendaftaran_ditutup);

-- ==================== PENDAFTARAN TABLE ====================
CREATE TABLE IF NOT EXISTS pendaftaran (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  event_id uuid NOT NULL REFERENCES event(id) ON DELETE CASCADE,
  tanggal_daftar timestamp with time zone DEFAULT now(),
  status text NOT NULL CHECK (status IN ('aktif', 'batal', 'selesai')) DEFAULT 'aktif',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  UNIQUE(user_id, event_id) -- Prevent duplicate registrations
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_pendaftaran_user_id ON pendaftaran(user_id);
CREATE INDEX IF NOT EXISTS idx_pendaftaran_event_id ON pendaftaran(event_id);
CREATE INDEX IF NOT EXISTS idx_pendaftaran_status ON pendaftaran(status);
CREATE INDEX IF NOT EXISTS idx_pendaftaran_user_event ON pendaftaran(user_id, event_id);

-- ==================== TIKET TABLE ====================
CREATE TABLE IF NOT EXISTS tiket (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  pendaftaran_id uuid NOT NULL REFERENCES pendaftaran(id) ON DELETE CASCADE,
  nomor_tiket text UNIQUE NOT NULL,
  qr_code text NOT NULL,
  tanggal_buat timestamp with time zone DEFAULT now(),
  sudah_digunakan boolean DEFAULT false,
  tanggal_digunakan timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  UNIQUE(pendaftaran_id) -- One ticket per registration
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_tiket_pendaftaran_id ON tiket(pendaftaran_id);
CREATE INDEX IF NOT EXISTS idx_tiket_nomor_tiket ON tiket(nomor_tiket);
CREATE INDEX IF NOT EXISTS idx_tiket_sudah_digunakan ON tiket(sudah_digunakan);

-- ==================== ROW LEVEL SECURITY (RLS) ====================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE event ENABLE ROW LEVEL SECURITY;
ALTER TABLE pendaftaran ENABLE ROW LEVEL SECURITY;
ALTER TABLE tiket ENABLE ROW LEVEL SECURITY;

-- ==================== POLICIES FOR USERS TABLE ====================
-- Users can view their own profile
CREATE POLICY "Users can view their own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Admins can view all users
CREATE POLICY "Admins can view all users"
  ON users FOR SELECT
  USING (
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ==================== POLICIES FOR EVENT TABLE ====================
-- Anyone can view published events
CREATE POLICY "Anyone can view events"
  ON event FOR SELECT
  USING (true);

-- Only admins can create events
CREATE POLICY "Only admins can create events"
  ON event FOR INSERT
  WITH CHECK (
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- Only event admin can update their events
CREATE POLICY "Event admin can update their events"
  ON event FOR UPDATE
  USING (
    admin_id = auth.uid() OR
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- Only event admin can delete their events
CREATE POLICY "Event admin can delete their events"
  ON event FOR DELETE
  USING (
    admin_id = auth.uid() OR
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ==================== POLICIES FOR PENDAFTARAN TABLE ====================
-- Users can view their own registrations
CREATE POLICY "Users can view their own registrations"
  ON pendaftaran FOR SELECT
  USING (
    user_id = auth.uid() OR
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- Users can register for events
CREATE POLICY "Users can register for events"
  ON pendaftaran FOR INSERT
  WITH CHECK (
    user_id = auth.uid()
  );

-- Users can update their own registrations
CREATE POLICY "Users can update their own registrations"
  ON pendaftaran FOR UPDATE
  USING (
    user_id = auth.uid() OR
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- Admins can view all registrations for their events
CREATE POLICY "Admins can view registrations"
  ON pendaftaran FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM event
      WHERE event.id = pendaftaran.event_id
      AND event.admin_id = auth.uid()
    ) OR
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ==================== POLICIES FOR TIKET TABLE ====================
-- Users can view their own tickets
CREATE POLICY "Users can view their own tickets"
  ON tiket FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM pendaftaran
      WHERE pendaftaran.id = tiket.pendaftaran_id
      AND pendaftaran.user_id = auth.uid()
    ) OR
    (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
  );

-- ==================== FUNCTIONS ====================

-- Function to auto-create ticket when registration is created
CREATE OR REPLACE FUNCTION create_ticket_on_registration()
RETURNS TRIGGER AS $$
DECLARE
  new_ticket_number text;
  qr_code_data text;
BEGIN
  -- Generate ticket number
  new_ticket_number := 'TKT-' || NEW.id::text || '-' || to_char(now(), 'YYYYMMDD');
  qr_code_data := new_ticket_number || '|' || NEW.event_id::text || '|' || NEW.user_id::text;
  
  -- Create ticket
  INSERT INTO tiket (pendaftaran_id, nomor_tiket, qr_code)
  VALUES (NEW.id, new_ticket_number, qr_code_data);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create ticket
DROP TRIGGER IF EXISTS trg_create_ticket ON pendaftaran;
CREATE TRIGGER trg_create_ticket
  AFTER INSERT ON pendaftaran
  FOR EACH ROW
  EXECUTE FUNCTION create_ticket_on_registration();

-- Function to update event terdaftar count
CREATE OR REPLACE FUNCTION update_event_terdaftar()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE event SET terdaftar = terdaftar + 1 WHERE id = NEW.event_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE event SET terdaftar = terdaftar - 1 WHERE id = OLD.event_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update event count
DROP TRIGGER IF EXISTS trg_update_event_terdaftar ON pendaftaran;
CREATE TRIGGER trg_update_event_terdaftar
  AFTER INSERT OR DELETE ON pendaftaran
  FOR EACH ROW
  EXECUTE FUNCTION update_event_terdaftar();

-- Function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
DROP TRIGGER IF EXISTS trg_update_users_timestamp ON users;
CREATE TRIGGER trg_update_users_timestamp
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trg_update_event_timestamp ON event;
CREATE TRIGGER trg_update_event_timestamp
  BEFORE UPDATE ON event
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trg_update_pendaftaran_timestamp ON pendaftaran;
CREATE TRIGGER trg_update_pendaftaran_timestamp
  BEFORE UPDATE ON pendaftaran
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trg_update_tiket_timestamp ON tiket;
CREATE TRIGGER trg_update_tiket_timestamp
  BEFORE UPDATE ON tiket
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
