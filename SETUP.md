# Recall: setup for phone + sync

Recall is a static web app: `index.html` plus a few small files. To use it on your phone and keep your devices in sync you need two free things:

1. **A Firebase project**: the database your quizzes and history sync to. The free Spark plan needs no credit card and never pauses, so there's nothing to maintain.
2. **A host for the files**: so the app has an `https://` address your phone can open and install.

Both take about 10 minutes the first time.

---

## 1. Create the database (Firebase)

1. Go to <https://console.firebase.google.com>, click **Create a project**, and give it a name. You can turn off Google Analytics.
2. **Turn on sign-in**: open **Build → Authentication → Get started → Sign-in method → Email/Password**, switch on the first toggle, and **Save**.
3. **Create the database**: open **Build → Firestore Database → Create database**. Pick a location near you (for Indonesia, `asia-southeast2 (Jakarta)`), choose **Start in production mode**, and click **Create**.
4. **Add the security rules**: in Firestore, open the **Rules** tab, replace everything with the contents of `firestore.rules`, and click **Publish**.
5. **Get your keys**: click the gear icon → **Project settings → General**. Under **Your apps**, click the web icon `</>`, give the app a nickname, and **Register app** (skip Firebase Hosting). From the `firebaseConfig` snippet, copy `apiKey` and `projectId` into `config.js`:

   ```js
   window.RECALL_CONFIG = {
     firebaseApiKey: 'AIzaSy...',
     firebaseProjectId: 'recall-1a2b3',
   };
   ```

   The API key is meant to be public. The Firestore rules make sure each account can only read and write its own data.

6. Commit and push `config.js`. If the site is already on Vercel, it redeploys automatically.

## 2. Put the app online

Upload the whole folder. Pick one host:

- **Vercel**: on <https://vercel.com/new>, import the GitHub repository. Leave the Framework Preset as **Other** and the build settings empty, then **Deploy**. Every push to `main` redeploys automatically.
- **Netlify**: go to <https://app.netlify.com/drop>, sign in, and drag the folder onto the page.
- **GitHub Pages**: in the repository, go to **Settings → Pages → Deploy from a branch → main / root**.

## 3. Install on your phone

1. Open the app's address on your phone.
   - **iPhone (Safari)**: tap **Share → Add to Home Screen**.
   - **Android (Chrome)**: tap **⋮ → Add to Home screen** (or **Install app**).
2. Open Recall from your home screen, tap the status pill at the top right (**Sign in to sync**), and tap **Create account** the first time.
3. On your computer, open the same address and **Sign in** with the same email and password.

Optional: once your account exists, stop anyone else from creating one. In Firebase, go to **Authentication → Settings → User actions** and untick **Enable create (sign-up)**.

---

## How offline and sync work

- Everything is saved on the device first, so the app works with no connection: taking quizzes, adding new ones, and deleting.
- The status pill shows what's going on: **Synced**, **Syncing**, **Offline · 3 to sync**, or **Sync error**. Tap it for details or **Sync now**.
- When you're back online, changes are pushed and pulled automatically. This happens on launch, when the app comes back to the foreground, and every minute while it's open.
- If the same quiz was changed on two devices, the newer change wins. Attempts from different devices never overwrite each other.
- Deleting a quiz deletes it and its history on all your devices.
- Signing out keeps the quizzes on that device. Anything not yet synced goes up the next time you sign in.

## Things to know

- **Free limits**: the Spark plan allows 50,000 reads and 20,000 writes per day and 1 GB of storage. A personal quiz app uses a tiny fraction of that.
- **Opening `index.html` straight from your computer** (double-click) still works, but without the offline install. Sync works if you've filled in `config.js`.
- **After updating the files**, open the app once while online to pick up the new version.

## Getting quizzes from an AI

The prompt is in `LLM-PROMPT.txt`, and also in the app under **Format & prompt → Copy prompt**. It works with Claude, ChatGPT, Gemini and others. Paste the AI's whole reply into **Paste JSON instead**; the app ignores the text around the JSON.
