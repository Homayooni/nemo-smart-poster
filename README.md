# Nemo Auto Folder Cover & Cleaner (Smart Poster Downloader) 📁🎨🎥

[English](#english) | [فارسی](#persian)

---

<a name="english"></a>
## 🌐 English Description

A smart, automated extension for the **Nemo File Manager** (Linux Mint) that helps you organize your media library. With a single right-click, it cleans up folder/file names and assigns official posters for movies, TV shows, and anime.

### 🔄 How It Works
1. **Clean Names:** Automatically converts dots (`.`) and underscores (`_`) into spaces, removing quality tags (e.g., `1080p`, `BluRay`, `x264`, `WEB-DL`, `YIFY`).
2. **Online Poster Fetching (Priority 1):** 
   - **Anime:** Searches **MyAnimeList** (via Jikan API).
   - **Movies & TV Shows:** Searches **IMDb** directly.
3. **Local Cover Backup (Priority 2):** Uses an existing image in the folder if offline or if no poster was found online.
4. **Video Frame Extraction (Priority 3):** Extracts a clear frame from `.mkv`, `.mp4`, or other video files using `ffmpeg` when no image is present.

### 🌟 Features
- **Dual Online Sources:** Reliable metadata from **MyAnimeList** & **IMDb**.
- **Auto Video Folder Creation:** Right-clicking an isolated video file cleans its name, moves it into a newly created folder, and sets the folder poster.
- **Noise Filter Engine:** Cleans unnecessary release tags before querying search engines for accurate results.
- **Fast & Lightweight:** No API keys required.

### 📋 Prerequisites
Make sure you have the required dependencies installed:
```bash
sudo apt update && sudo apt install ffmpeg curl python3 -y
```

### 🚀 Quick Installation
Run this single command in your terminal to install or update:
```bash
curl -sSL https://raw.githubusercontent.com/Homayooni/nemo-smart-poster/main/install.sh | bash
```

---

<a name="persian"></a>
## 🇮🇷 توضیحات فارسی

یک ابزار هوشمند و خودکار برای فایل‌منیجر **Nemo** (لینوکس مینت) که به شما در مرتب‌سازی آرشیو فیلم، سریال و انیمه کمک می‌کند. تنها با یک راست‌کلیک، نام فایل یا پوشه استاندارد شده و پوستر رسمی آن ست می‌شود.

### 🔄 نحوه عملکرد اسکریپت
1. **اصلاح و تمیزکاری نام:** تبدیل نقطه‌ها (`.`) و آندرلاین‌ها (`_`) به فاصله و حذف عبارات اضافه کیفیت (مانند `1080p`, `BluRay`, `x264`, `WEB-DL`, `YIFY`).
2. **دانلود آنلاین پوستر (اولویت ۱):** 
   - **انیمه‌ها:** جستجو در دیتابیس **MyAnimeList**.
   - **فیلم و سریال‌ها:** جستجوی مستقیم در دیتابیس **IMDb**.
3. **تصویر محلی (اولویت ۲):** در صورت قطع اینترنت یا پیدا نشدن پوستر، از عکس موجود درون پوشه استفاده می‌کند.
4. **استخراج فریم از ویدیو (اولویت ۳):** در صورت عدم وجود عکس، با ابزار `ffmpeg` یک فریم از ویدیوی درون پوشه استخراج کرده و به عنوان کاور ست می‌کند.

### 🌟 ویژگی‌ها
- **اتصال به دو منبع معتبر:** دریافت پوستر دقیق از **MyAnimeList** و **IMDb**.
- **پشتیبانی از تک فایل ویدیویی:** اگر روی یک فایل فیلم راست‌کلیک کنید، اسکریپت خودکار یک پوشه تمیز هم‌نام فیلم می‌سازد، فیلم را داخل آن قرار داده و پوستر را روی پوشه جدید تنظیم می‌کند.
- **بدون نیاز به API Key:** نصب و استفاده بسیار سریع و آسان بدون تنظیمات پیچیده.

### 📋 نیازمندی‌ها
پیش از نصب، از نصب بودن پیش‌نیازهای زیر در لینوکس خود مطمئن شوید:
```bash
sudo apt update && sudo apt install ffmpeg curl python3 -y
```

### 🚀 نحوه نصب سریع
کافی است دستور زیر را در ترمینال کپی و اجرا کنید:
```bash
curl -sSL https://raw.githubusercontent.com/Homayooni/nemo-smart-poster/main/install.sh | bash
```

---

## 📜 License

This project is licensed under the **MIT License**.
