# 🌟 Portfolio Website - Alhussein AbdelSabour

A stunning Flutter Web portfolio showcasing mobile app development projects with full admin capabilities, built with Flutter, Supabase, and Riverpod.

**Developer:** Alhussein AbdelSabour (@toalhussein)  
**Stack:** Flutter Web • Supabase • Riverpod • GoRouter

---

## ✨ Features

### 🎨 Front-End
- **Home Page**: About Me section with skills showcase
- **Projects Page**: Dynamically displays projects from Supabase
- **Contact Page**: Form that stores messages in Supabase
- **Admin Dashboard**: Full CRUD operations for projects and message management
- **RTL Support**: Arabic (default) with English toggle
- **Responsive Design**: Optimized for mobile, tablet, and desktop
- **Blue Theme**: Modern design with soft glow effects and smooth animations

### 🔐 Back-End (Supabase)
- **Authentication**: Email/Password login for admins
- **Database Tables**:
  - `projects` - Portfolio projects
  - `contact_messages` - Messages from contact form
  - `admins` - Admin user management
- **Row Level Security (RLS)**:
  - Admins can CRUD projects
  - Anyone can submit contact messages
  - Only admins can read/manage messages
- **Storage**: Project images with public access

### 🚀 Technical Highlights
- **State Management**: Riverpod
- **Routing**: GoRouter with authentication guards
- **Internationalization**: Arabic & English with RTL support
- **Animations**: Flutter Animate for smooth transitions
- **Clean Architecture**: Organized folder structure

---

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (>=3.9.2)
- Supabase account
- Code editor (VS Code recommended)

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd portfolio
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Supabase Setup

#### A. Create a Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note your project URL and anon key

#### B. Run Database Setup
1. Open Supabase Dashboard → SQL Editor
2. Copy and paste the contents of `supabase_setup.sql`
3. Execute the script

#### C. Create Storage Bucket
1. Go to Storage in Supabase Dashboard
2. Create a new bucket named `project-images`
3. Make it public
4. Apply the storage policies from the SQL script

#### D. Create Admin User
1. Go to Authentication → Users
2. Create a new user with email and password
3. Copy the user's UUID
4. Run this SQL query (replace with your values):
```sql
INSERT INTO public.admins (user_id, email)
VALUES ('YOUR_USER_UUID', 'your-email@example.com');
```

### 4. Configure Environment Variables

Update `lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

**For production**, use environment variables:
```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### 5. Run the App
```bash
flutter run -d chrome
```

For production build:
```bash
flutter build web --release
```

---

## 🚀 Deployment

### Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init hosting

# Build and deploy
flutter build web --release
firebase deploy
```

### Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Build
flutter build web --release

# Deploy
vercel --prod
```

### Netlify

1. Build: `flutter build web --release`
2. Drag and drop `build/web` folder to Netlify
3. Or use Netlify CLI:
```bash
netlify deploy --prod --dir=build/web
```

---

## 🎯 Usage

### Public Pages
- **Home** (`/`): View about section and skills
- **Projects** (`/projects`): Browse portfolio projects
- **Contact** (`/contact`): Send a message

### Admin Pages
- **Login** (`/admin/login`): Admin authentication
- **Dashboard** (`/admin/dashboard`): Manage projects and messages

### Admin Credentials
Use the email and password you created in Supabase Auth.

---

## 🎨 Customization

### Update Personal Information
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String developerName = 'Your Name';
static const String username = 'your_username';
static const String emailAddress = 'your@email.com';
static const List<String> skills = ['Skill 1', 'Skill 2', ...];
```

### Change Theme Colors
Edit `lib/core/theme/app_theme.dart`:
```dart
static const Color primaryBlue = Color(0xFF2196F3);  // Your color
```

---

## 📦 Dependencies

```yaml
# State Management
flutter_riverpod: ^2.6.1

# Routing
go_router: ^14.6.2

# Backend
supabase_flutter: ^2.9.1

# UI & Utilities
google_fonts: ^6.2.1
flutter_animate: ^4.5.0
cached_network_image: ^3.4.1
intl: ^0.19.0

# Forms
flutter_form_builder: ^9.4.2
form_builder_validators: ^11.0.0

# File Upload
file_picker: ^8.1.6
image_picker: ^1.1.2
```

---

## 🐛 Troubleshooting

### Issue: Supabase connection error
- ✅ Check URL and anon key in `app_constants.dart`
- ✅ Verify RLS policies are enabled
- ✅ Check browser console for errors

### Issue: Admin can't login
- ✅ Verify user exists in Supabase Auth
- ✅ Confirm user is added to `admins` table
- ✅ Check RLS policies on `admins` table

### Issue: Images not displaying
- ✅ Verify storage bucket is public
- ✅ Check storage policies
- ✅ Ensure image URLs are correct

### Issue: RTL not working
- ✅ Check locale provider is initialized
- ✅ Verify MaterialApp has localizationsDelegates
- ✅ Run `flutter pub get` to generate localizations

---

## 👤 Author

**Alhussein AbdelSabour**
- GitHub: [@toalhussein](https://github.com/toalhussein)
- Email: alhussein@example.com

---

**Built with ❤️ using Flutter**
