# Supabase setup for FaceReader

## 1. Create project

Create a project at [supabase.com](https://supabase.com), then open **SQL Editor** and run the single migration:

`migrations/20260412120000_monsters.sql`

The script is idempotent (safe to run more than once).

## 2. Storage bucket

In **Storage**, create a public bucket named `monster-images`.

Under bucket **Policies**, allow public `insert`, `select`, and `delete` for development (tighten for production).

## 3. Configure the iOS app (repo-root `.env`)

Secrets are **not** stored in a bundled plist. At build time, the **FaceReaderEnv** target runs `scripts/generate-secrets-xcconfig.sh`, which reads **repo-root** `.env` and writes `FaceReader/Configuration/Secrets.generated.xcconfig` (gitignored). Xcode merges those settings like environment variables; `Info.plist` uses `$(SUPABASE_URL)` and `$(SUPABASE_PUBLISHABLE_KEY)`.

1. Copy the example file at the repo root:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your project **URL** and **publishable** key from **Project Settings → API → API Keys** (`sb_publishable_…`).

3. Optionally set **secret** (`sb_secret_…`) in `.env` for local Supabase CLI/admin only — **do not** read it from the iOS app or add it to `Info.plist`.

4. `FaceReader.debug.xcconfig` / `FaceReader.release.xcconfig` only `#include? "Secrets.generated.xcconfig"`.

5. Build the **FaceReader** scheme (it depends on **FaceReaderEnv**, so the script runs first). If you change `.env`, rebuild the app target.

**CI / Xcode Cloud:** create `.env` or generate `Secrets.generated.xcconfig` in a pre-build step, or set **User-Defined** build settings `SUPABASE_URL` / `SUPABASE_PUBLISHABLE_KEY` on the app target so `Info.plist` substitution still works.

**Note:** `https://` in `.xcconfig` must avoid a bare `//` (comment). The generator defines `URL_SLASH = /` and writes `https:$(URL_SLASH)$(URL_SLASH)host`.

**Legacy:** you can still use a hand-written `FaceReader/Configuration/Secrets.xcconfig` if you add `#include? "Secrets.xcconfig"` after the generated include — not required for the default `.env` flow.
