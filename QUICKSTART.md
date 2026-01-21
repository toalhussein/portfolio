# 🚀 Quick Start Guide

Get your portfolio up and running in 10 minutes!

## Step 1: Supabase Setup (5 minutes)

### 1.1 Create Supabase Project
1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Fill in project details and wait for setup
4. Copy your **Project URL** and **anon/public key** from Settings → API

### 1.2 Run Database Setup
1. In Supabase Dashboard, go to **SQL Editor**
2. Open `supabase_setup.sql` from this project
3. Copy the entire content
4. Paste into SQL Editor and click **Run**
5. Wait for "Success" message

### 1.3 Create Storage Bucket
1. Go to **Storage** in Supabase Dashboard
2. Click "New bucket"
3. Name it: `project-images`
4. Make it **Public**
5. Create bucket

### 1.4 Create Your Admin Account
1. Go to **Authentication** → **Users**
2. Click "Add user"
3. Enter your email and password
4. Click "Create user"
5. **Copy the user UUID** (you'll need it in next step)

### 1.5 Add Admin to Database
1. Go back to **SQL Editor**
2. Run this query (replace with your values):
```sql
INSERT INTO public.admins (user_id, email)
VALUES ('YOUR_USER_UUID_HERE', 'your-email@example.com');
```
3. Click **Run**

## Step 2: Configure Flutter App (2 minutes)

### 2.1 Update Supabase Credentials
1. Open `lib/core/constants/app_constants.dart`
2. Replace these lines:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
```
With your actual values from Step 1.1

### 2.2 Update Personal Info (Optional)
In the same file, update:
```dart
static const String developerName = 'Your Name';
static const String username = 'your_username';
static const String emailAddress = 'your@email.com';
```

## Step 3: Run the App (3 minutes)

### 3.1 Install Dependencies
```bash
flutter pub get
```

### 3.2 Run on Chrome
```bash
flutter run -d chrome
```

### 3.3 Test the App
1. **Home Page**: Should load with your info
2. **Projects Page**: Will be empty (add projects via admin)
3. **Contact Page**: Test sending a message
4. **Admin Login**: Use email/password from Step 1.4
5. **Admin Dashboard**: Add your first project!

## 🎉 You're Done!

### Next Steps:
- ✅ Add projects via Admin Dashboard
- ✅ Customize colors in `lib/core/theme/app_theme.dart`
- ✅ Update skills list in `app_constants.dart`
- ✅ Test language toggle (Arabic ↔ English)
- ✅ Deploy to Firebase Hosting or Vercel

## 🐛 Common Issues

**Issue: "Supabase not initialized"**
- Solution: Make sure you ran `flutter pub get`

**Issue: "Admin login failed"**
- Solution: Verify you added the user to `admins` table in Step 1.5

**Issue: "Can't upload images"**
- Solution: Check that storage bucket `project-images` is public

**Issue: "Pages not loading"**
- Solution: Check browser console (F12) for errors

## 📚 Need More Help?

Check out the full [README.md](README.md) for:
- Detailed explanations
- Deployment guides
- Customization options
- Troubleshooting

## 🎯 Quick Commands

```bash
# Run in debug mode
flutter run -d chrome

# Build for production
flutter build web --release

# Check for errors
flutter analyze

# Format code
dart format .

# Update dependencies
flutter pub upgrade
```

---

**Happy coding! 🚀**
