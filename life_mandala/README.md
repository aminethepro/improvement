# Life Mandala

A personal life-goals app based on the Mandala Chart: one main goal,
eight pillars, and eight sub-goals per pillar (73 total cells in a
9x9 grid). Fully offline, no account, no ads.

## What's included in this version (v1)

- Blank-slate onboarding: enter your main goal, then your 8 pillars
  (name, description, color)
- Full 9x9 Mandala grid, visually grouped by pillar
- Pinch-to-zoom, pan, double-tap zoom, and a "fit to screen" button
- Tap any cell to edit it (main goal / pillar / goal) at any time
- Tap a goal cell to mark today as Done / Partial / Not done, and see
  your last 7 days at a glance
- Everything is saved automatically on your phone — close the app
  and reopen it, your data is still there
- Dark mode follows your phone's system setting
- Reset-application option in Settings (with a confirmation step)

## What's not built yet

The Today screen, full statistics, numeric/reading/workout tracking,
checklists, milestones, scheduling by day-of-week, notifications, and
data export/import are all part of the original plan but are not in
this first version. The data model (stable goal IDs, dated records)
is already built so these can be added on top without losing any of
your existing data.

## How to turn this into an APK you can install (no coding, no installs)

You don't need Android Studio or any developer tools on your phone or
computer. This project already includes a robot (GitHub Actions) that
builds the APK for you in the cloud. You just need a free GitHub
account.

### Step 1 — Create a GitHub account (skip if you have one)
Go to https://github.com/signup and create a free account.

### Step 2 — Create a new repository
1. Go to https://github.com/new
2. Name it anything, e.g. `life-mandala`
3. Leave it "Public" (or "Private", both work)
4. Do NOT check "Add a README" (we already have one)
5. Click **Create repository**

### Step 3 — Upload the project files
1. On your new repository's page, click **"uploading an existing file"**
   (or the "Add file" → "Upload files" button)
2. Open the `life_mandala` folder you downloaded from this chat on
   your computer
3. Drag the **entire contents** of that folder (the `lib` folder, the
   `.github` folder, `pubspec.yaml`, this `README.md` — everything
   inside `life_mandala`, not the `life_mandala` folder itself) into
   the GitHub upload box
   - If GitHub's drag-and-drop doesn't accept folders directly on
     your browser, upload the `pubspec.yaml` and `README.md` first,
     then repeat "Add file → Upload files" for the `lib` folder and
     the `.github` folder — GitHub will preserve the folder structure
     as long as you drag whole folders in, not files one by one
4. Scroll down and click **Commit changes**

### Step 4 — Let the cloud build the APK
1. Click the **Actions** tab at the top of your repository
2. You should see a workflow run called "Build APK" already running
   (it starts automatically after your upload). If not, click
   "Build APK" on the left, then "Run workflow"
3. Wait 3–6 minutes. A green checkmark means it succeeded

### Step 5 — Download your APK
1. Click on the completed workflow run
2. Scroll to the **Artifacts** section at the bottom
3. Click **life-mandala-apk** to download a zip file
4. Unzip it — inside is `app-release.apk`

### Step 6 — Install it on your phone
1. Transfer `app-release.apk` to your Android phone (email it to
   yourself, use a USB cable, Google Drive, WhatsApp, etc.)
2. Open the file on your phone
3. Android will ask permission to "install unknown apps" the first
   time — allow it for the app you're using to open the file (e.g.
   your Files app or Chrome)
4. Tap **Install**

That's it — the app is now on your phone, works fully offline, and
your data stays only on your device.

## If something in Step 4 fails (red X instead of green check)

Click into the failed run and open the red step to see the error
message, then paste that message back into the chat with Claude —
it can adjust the code to fix it. This is normal for a first build
and usually a one-line fix.
