-- ── Supabase Storage: Bucket "audio" Policies ────────────────────────────────
--
-- Ausführen in: Supabase Dashboard → SQL Editor
--
-- Regeln:
--   ✅ Eingeloggte Nutzer können MP3s lesen (download)
--   ❌ Niemand kann schreiben / löschen (nur per Service Role Key aus Scripts)
-- ─────────────────────────────────────────────────────────────────────────────

-- Sicherstellen dass der Bucket existiert und public = false ist
-- (Public = false → Zugriff nur über Policies, nicht anonym per URL)
UPDATE storage.buckets
SET public = false
WHERE id = 'audio';

-- Alle bestehenden Policies für diesen Bucket entfernen (sauberer Neustart)
DROP POLICY IF EXISTS "audio_read_authenticated" ON storage.objects;
DROP POLICY IF EXISTS "audio_insert_nobody"      ON storage.objects;
DROP POLICY IF EXISTS "audio_update_nobody"      ON storage.objects;
DROP POLICY IF EXISTS "audio_delete_nobody"      ON storage.objects;

-- ── READ: nur eingeloggte Nutzer ─────────────────────────────────────────────
CREATE POLICY "audio_read_authenticated"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'audio');

-- ── INSERT / UPDATE / DELETE: niemand (nur Service Role umgeht Policies) ──────
-- Es werden absichtlich keine INSERT/UPDATE/DELETE Policies erstellt.
-- → Kein authentifizierter Nutzer kann Dateien hochladen oder löschen.
-- → Das generate-audio / upload-audio Script nutzt den Service Role Key,
--   der Policies vollständig umgeht.
