-- ============================================================
-- Migration: Lernpfad-Pipeline (Mastery Stages)
-- Tabelle: vocab_progress
-- Zweck:   Fortschritt pro Wort und Stufe (flashcard/cloze/listen/sentence)
-- ============================================================

-- mastery_stage: Aktuelle Gesamtstufe (0–4)
--   0 = noch in Stufe 1 (Karteikarte)
--   1 = Stufe 2 (Lückentext)
--   2 = Stufe 3 (Hören)
--   3 = Stufe 4 (Satzbau)
--   4 = vollständig gemeistert
ALTER TABLE vocab_progress
  ADD COLUMN IF NOT EXISTS mastery_stage  smallint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS stage_scores   jsonb    NOT NULL DEFAULT '{}';

-- Beispiel stage_scores:
--   { "flashcard": 3, "cloze": 1, "listen": 0, "sentence": 0 }
--   flashcard=3 → Schwellenwert erreicht, Stufe 1 gemeistert

-- Index für effiziente Abfragen: "Welche Wörter sind in Stufe X?"
CREATE INDEX IF NOT EXISTS idx_vocab_progress_mastery
  ON vocab_progress(user_id, mastery_stage);

-- Index für Lernpfad-Dashboard: alle Wörter eines Nutzers sortiert nach Stage
CREATE INDEX IF NOT EXISTS idx_vocab_progress_stage_scores
  ON vocab_progress USING GIN (stage_scores)
  WHERE stage_scores != '{}';
