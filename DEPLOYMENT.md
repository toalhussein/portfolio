# 🚀 Deployment Guide

Complete guide for deploying your Flutter Web portfolio to various hosting platforms.

## 📋 Pre-Deployment Checklist

Before deploying, ensure:
- ✅ All configuration is complete (see [CHECKLIST.md](CHECKLIST.md))
- ✅ Supabase is properly set up
- ✅ App runs without errors locally
- ✅ Production build completes successfully

## 🏗️ Build for Production

```bash
# Clean previous builds
flutter clean

# Build optimized production bundle
flutter build web --release

# Optional: Build with environment variables
flutter build web --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

The production build will be in `build/web/` directory.

---

## 🔥 Firebase Hosting (Recommended)

### Why Firebase?
- ✅ Free tier available
- ✅ Global CDN
- ✅ Custom domain support
- ✅ SSL certificate included
- ✅ Easy rollbacks

### Setup Steps

1. **Install Firebase CLI**
```bash
npm install -g firebase-tools
```

2. **Login to Firebase**
```bash
firebase login
```

3. **Initialize Firebase in your project**
```bash
firebase init hosting
```

Select these options:
- What do you want to use as your public directory? **build/web**
- Configure as a single-page app? **Yes**
- Set up automatic builds with GitHub? **No** (you can enable later)
- Overwrite index.html? **No**

4. **Deploy**
```bash
# Build
flutter build web --release

# Deploy
firebase deploy --only hosting
```

5. **Access your site**
Your site will be available at: `https://your-project.web.app`

### Custom Domain

1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Follow the DNS configuration steps
4. Wait for SSL certificate (up to 24 hours)

---

## 🔷 Vercel (Fast & Simple)

### Why Vercel?
- ✅ Extremely fast deployment
- ✅ Automatic HTTPS
- ✅ Preview deployments
- ✅ GitHub integration

### Setup Steps

#### Method 1: Vercel CLI

1. **Install Vercel CLI**
```bash
npm install -g vercel
```

2. **Build and Deploy**
```bash
# Build
flutter build web --release

# Deploy
vercel --prod
```

3. **Follow prompts:**
- Set up and deploy? **Yes**
- Which scope? Select your account
- Link to existing project? **No**
- What's your project's name? **your-portfolio**
- In which directory is your code located? **.**
- Want to override the settings? **Yes**
- Output directory? **build/web**
- Build command? **flutter build web --release**

#### Method 2: GitHub Integration (Recommended)

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Click "New Project"
4. Import your GitHub repository
5. Configure:
   - Framework: **Other**
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`
6. Add environment variables (if using):
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
7. Deploy!

### Custom Domain
1. Go to Project Settings → Domains
2. Add your domain
3. Configure DNS as instructed

---

## 🟢 Netlify

### Why Netlify?
- ✅ Drag-and-drop deployment
- ✅ Form handling
- ✅ Split testing
- ✅ Deploy previews

### Setup Steps

#### Method 1: Drag & Drop

1. Build locally:
```bash
flutter build web --release
```

2. Go to [netlify.com](https://netlify.com)
3. Drag `build/web` folder to the drop zone
4. Done! 🎉

#### Method 2: Netlify CLI

1. **Install Netlify CLI**
```bash
npm install -g netlify-cli
```

2. **Login**
```bash
netlify login
```

3. **Deploy**
```bash
# Build
flutter build web --release

# Deploy
netlify deploy --prod --dir=build/web
```

#### Method 3: GitHub Integration

1. Create `netlify.toml` in project root:
```toml
[build]
  command = "flutter build web --release"
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

2. Push to GitHub
3. Go to Netlify Dashboard
4. "New site from Git"
5. Connect GitHub repository
6. Deploy!

---

## 🌐 GitHub Pages (Free)

### Setup Steps

1. **Install gh-pages package** (for easy deployment)
```bash
npm install -g gh-pages
```

2. **Build**
```bash
flutter build web --release --base-href "/your-repo-name/"
```

3. **Deploy**
```bash
cd build/web
git init
git add .
git commit -m "Deploy"
git remote add origin https://github.com/username/repo.git
git push -f origin main:gh-pages
```

4. **Enable GitHub Pages**
- Go to repo Settings → Pages
- Source: gh-pages branch
- Save

5. **Access**
Visit: `https://username.github.io/repo-name/`

---

## ☁️ Google Cloud Storage

### Setup Steps

1. **Create GCS bucket**
```bash
gsutil mb gs://your-portfolio-bucket
```

2. **Configure for web hosting**
```bash
gsutil web set -m index.html -e 404.html gs://your-portfolio-bucket
```

3. **Make public**
```bash
gsutil iam ch allUsers:objectViewer gs://your-portfolio-bucket
```

4. **Deploy**
```bash
flutter build web --release
gsutil -m rsync -R build/web gs://your-portfolio-bucket
```

---

## 🔧 Environment Variables

### For Sensitive Data

Instead of hardcoding in `app_constants.dart`, use environment variables:

1. **Update `app_constants.dart`:**
```dart
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'YOUR_DEFAULT_URL',
);

static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'YOUR_DEFAULT_KEY',
);
```

2. **Build with variables:**
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_key_here
```

3. **For CI/CD**, set in platform:
   - **Firebase**: Not needed (set at build time)
   - **Vercel**: Project Settings → Environment Variables
   - **Netlify**: Site Settings → Environment Variables
   - **GitHub Actions**: Repository Secrets

---

## 🔄 CI/CD with GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build web
      run: flutter build web --release \
        --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
        --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
    
    - uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: '${{ secrets.GITHUB_TOKEN }}'
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
        channelId: live
        projectId: your-firebase-project-id
```

---

## 🎯 Post-Deployment

### Verify Deployment
- [ ] Visit deployed URL
- [ ] Test all pages
- [ ] Test admin login
- [ ] Check mobile responsiveness
- [ ] Verify language toggle works
- [ ] Test contact form
- [ ] Check browser console for errors

### Optimize Performance
```bash
# Analyze bundle size
flutter build web --release --analyze-size

# Enable web renderer options
flutter build web --release --web-renderer canvaskit  # Better performance
# or
flutter build web --release --web-renderer html  # Better compatibility
```

### Monitor
- Set up error tracking (Sentry, Firebase Crashlytics)
- Monitor Supabase usage
- Check analytics (Google Analytics, Plausible)

---

## 🆘 Troubleshooting

### Issue: 404 on refresh
**Solution**: Configure SPA routing in hosting platform
- **Firebase**: Already configured in firebase.json
- **Netlify**: Add redirects in netlify.toml
- **Vercel**: Automatically handled

### Issue: Environment variables not working
**Solution**: Verify build command includes `--dart-define`

### Issue: Slow loading
**Solution**: 
- Use `--web-renderer canvaskit` for better performance
- Enable compression on hosting platform
- Optimize images in Supabase Storage

### Issue: CORS errors
**Solution**: Verify Supabase URL is correct and CORS is enabled

---

## 📊 Deployment Comparison

| Platform | Difficulty | Speed | Free Tier | Custom Domain | CI/CD |
|----------|-----------|-------|-----------|---------------|-------|
| Firebase | Easy | ⭐⭐⭐⭐⭐ | Yes | Yes | Easy |
| Vercel | Very Easy | ⭐⭐⭐⭐⭐ | Yes | Yes | Built-in |
| Netlify | Very Easy | ⭐⭐⭐⭐ | Yes | Yes | Built-in |
| GitHub Pages | Medium | ⭐⭐⭐ | Yes | Yes | Manual |
| GCS | Hard | ⭐⭐⭐⭐⭐ | Limited | Yes | Manual |

**Recommendation**: Start with **Vercel** or **Firebase Hosting** for easiest deployment.

---

**Happy Deploying! 🚀**
