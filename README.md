# Prima Extra Web - Classroom Management System

Platform pembelajaran online untuk les komputer dengan fitur manajemen murid, materi, dan kehadiran.

## 🚀 Fitur Utama

### Admin Dashboard
- ✅ Buat akun murid (username/password)
- ✅ Tambah materi dalam bentuk kartu (dengan foto, pertanyaan/tugas)
- ✅ Kelola kehadiran per sesi (Selasa 15:30-17:00 WIB)
- ✅ Lihat kehadiran dan nilai (C sampai A)

### Student Dashboard
- ✅ Lihat materi bersama dalam bentuk kartu
- ✅ Kirim tugas jika ada
- ✅ Tracking kehadiran terpisah

## 🛠️ Setup Instructions

### 1. Setup Supabase

1. Buat akun di [supabase.com](https://supabase.com)
2. Buat project baru
3. Pergi ke Settings > API
4. Copy Project URL dan anon key

### 2. Environment Variables

Buat file `.env.local` di folder `prima-extra-web/`:

```env
NEXT_PUBLIC_SUPABASE_URL=your_project_url_here
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
```

### 3. Database Setup

1. Pergi ke Supabase SQL Editor
2. Copy dan paste seluruh isi file `supabase-setup.sql`
3. Jalankan query

### 4. Buat Admin User

1. Di Supabase Authentication, buat user admin
2. Insert record admin di table users:

```sql
INSERT INTO users (id, email, username, role)
VALUES ('admin_user_id_from_auth', 'admin@email.com', 'admin', 'admin');
```

### 5. Jalankan Aplikasi

```bash
cd prima-extra-web
npm install
npm run dev
```

Buka [http://localhost:3000](http://localhost:3000) di browser.

## 📱 Responsive Design

Aplikasi ini sudah dioptimalkan untuk PC dan Android.

## 🚀 Deploy ke Vercel

1. Push code ke GitHub
2. Connect repository ke Vercel
3. Set environment variables di Vercel dashboard
4. Deploy!

## 📁 Struktur Project

```
prima-extra-web/
├── src/
│   ├── app/
│   │   ├── dashboard/
│   │   │   ├── admin/page.tsx      # Admin dashboard
│   │   │   ├── student/page.tsx    # Student dashboard
│   │   │   └── page.tsx            # Dashboard redirect
│   │   ├── login/page.tsx          # Login page
│   │   ├── layout.tsx              # Root layout with AuthProvider
│   │   └── page.tsx                # Home page
│   ├── contexts/
│   │   └── AuthContext.tsx         # Authentication context
│   └── lib/
│       ├── supabase.ts             # Supabase client
│       └── database.types.ts       # Database types
├── supabase-setup.sql              # Database schema
└── README.md
```

## 🔧 Tech Stack

- **Frontend**: Next.js 14, TypeScript, Tailwind CSS
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Deployment**: Vercel

## 📋 TODO

Lihat `TODO.md` untuk fitur yang masih dalam development.

## 🤝 Support

Jika ada pertanyaan atau butuh bantuan, silakan hubungi developer.
