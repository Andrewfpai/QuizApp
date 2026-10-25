# Recall: setup for phone + sync

Recall is a static web app: `index.html` plus a few small files. To use it on your phone and keep your devices in sync you need two free things:

1. **A Supabase project**: the database your quizzes and history sync to.
2. **A host for the files**: so the app has an `https://` address your phone can open and install.

Both take about 10 minutes the first time.

---

## 1. Create the database (Supabase)

1. Sign up at <https://supabase.com> and create a new project (free plan is fine).
2. Open **SQL Editor → New query**, paste everything from `supabase-schema.sql`, and click **Run**.
3. Open **Authentication → Sign In / Providers → Email** and turn **off** "Confirm email".
   (If you'd rather keep it on, set **Authentication → URL Configuration → Site URL** to your app's address from step 2, so the confirmation link opens the app.)
4. Open **Project Settings → API Keys** (or the **Connect** button) and copy:
   - the **Project URL**, like `https://abcdefghijkl.supabase.co`
   - the **publishable key** (older projects call it the **anon public** key)
5. Paste both into `config.js`:

   ```js
   window.RECALL_CONFIG = {
     supabaseUrl: 'https://abcdefghijkl.supabase.co',
     supabaseAnonKey: 'sb_publishable_...',
   };
   ```

   This key is meant to be public. Row-level security in the schema means each account can only read and write its own rows.

## 2. Put the app online

Upload the whole folder: `index.html`, `config.js`, `sw.js`, `manifest.webmanifest` and the three icon PNGs. Pick one host:

- **Vercel**: on <https://vercel.com/new>, import the GitHub repository. Leave the Framework Preset as **Other** and the build settings empty, then **Deploy**. Every push to `main` redeploys automatically.
- **Netlify**: go to <https://app.netlify.com/drop>, sign in, and drag the folder onto the page. You get an address like `https://something.netlify.app`. To update the app later, drag the folder onto your site's **Deploys** page.
- **GitHub Pages**: push the folder to a GitHub repository, then go to **Settings → Pages → Deploy from a branch → main / root**. The address is `https://<username>.github.io/<repo>/`.
- **Cloudflare Pages**: go to **Workers & Pages → Create → Pages → Upload assets** and upload the folder.

## 3. Install on your phone

1. Open the app's address on your phone.
   - **iPhone (Safari)**: tap **Share → Add to Home Screen**.
   - **Android (Chrome)**: tap **⋮ → Add to Home screen** (or **Install app**).
2. Open Recall from your home screen, tap the status pill at the top right (**Sign in to sync**), and tap **Create account** the first time.
3. On your computer, open the same address and **Sign in** with the same email and password.

Optional: once your account exists, turn off **Authentication → Sign In / Providers → Allow new users to sign up** in Supabase, so nobody else can make an account on your project.

---

## How offline and sync work

- Everything is saved on the device first, so the app works with no connection: taking quizzes, adding new ones, and deleting.
- The status pill shows what's going on: **Synced**, **Syncing**, **Offline · 3 to sync**, or **Sync error**. Tap it for details or **Sync now**.
- When you're back online, changes are pushed and pulled automatically. This happens on launch, when the app comes back to the foreground, and every minute while it's open.
- If the same quiz was changed on two devices, the newer change wins. Attempts from different devices never overwrite each other.
- Deleting a quiz deletes it and its history on all your devices.
- Signing out keeps the quizzes on that device. Anything not yet synced goes up the next time you sign in.

## Things to know

- **Free Supabase projects pause after about a week with no activity.** The app keeps working offline; tap **Restore** in the Supabase dashboard and sync resumes. Using the app regularly keeps the project awake.
- **Opening `index.html` straight from your computer** (double-click) still works, but without the offline install. Sync works if you've filled in `config.js`.
- **After updating the files**, open the app once while online to pick up the new version.

## Getting quizzes from an AI

The prompt is in `LLM-PROMPT.txt`, and also in the app under **Format & prompt → Copy prompt**. It works with Claude, ChatGPT, Gemini and others. Paste the AI's whole reply into **Paste JSON instead**; the app ignores the text around the JSON.
