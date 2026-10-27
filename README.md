# nemo-smart-poster
Markdown
# Nemo Auto Folder Cover & Cleaner (Smart Poster Downloader) 📁🎨🎥

[English](#english) | [فارسی](#persian)

---

<a name="english"></a>
## 🌐 English Description

A smart and automated extension for the **Nemo File Manager** (Linux Mint) that allows you to easily clean up folder names and set movie or anime posters with a single right-click:

1. **Clean Folder Names:** Automatically replaces dots (`.`) and underscores (`_`) with spaces and strips out quality tags (e.g., 1080p, BluRay, x264, WEB-DL).
2. **Smart Poster Search (Priority 1):** Automatically fetches official anime posters from **MyAnimeList (Jikan API)** and movie/TV show posters directly from **IMDb**.
3. **Local Cover Backup (Priority 2):** Uses an existing image in the folder if offline or if no online poster is found.
4. **Video Frame Extraction (Priority 3):** Automatically extracts a video frame using `ffmpeg` if no cover image is available.

### 🌟 Features
- **Dual-Source Poster Fetcher:** Uses **MyAnimeList** for anime titles and **IMDb** for mainstream movies & TV shows.
- **Offline Fallback:** Automatically extracts a thumbnail from `.mkv`, `.mp4`, or other video formats when offline.
- **Auto-Cleaning Engine:** Intelligently ignores noise keywords (resolutions, codecs, release group names) during search.
- **Folder Metadata Manager:** Writes proper `.directory` entries and updates GIO metadata instantly.

### 📋 Prerequisites
To run the script, make sure the required packages are installed:
```bash
sudo apt update && sudo apt install ffmpeg curl python3 -y
🚀 Quick Installation
Run the following one-liner command in your terminal (replace YOUR_USERNAME with your GitHub username):

Bash
curl -sSL [https://raw.githubusercontent.com/YOUR_USERNAME/nemo-smart-poster/main/install.sh](https://raw.githubusercontent.com/YOUR_USERNAME/nemo-smart-poster/main/install.sh) | bash
🇮🇷 توضیحات فارسی
یک ابزار هوشمند و خودکار برای فایل‌منیجر Nemo (لینوکس مینت) که با یک راست‌کلیک:

اصلاح نام پوشه‌ها: نام پوشه‌ها را استاندارد و تمیز می‌کند (حذف نقطه‌ها، آندرلاین‌ها و عبارت‌های اضافی کیفیت).

دانلود هوشمند پوستر (اولویت ۱): پوستر رسمی فیلم/انیمه را بر اساس نام پوشه از دیتابیس‌های معتبر سینمایی و انیمه‌ای (MyAnimeList و IMDb) سرچ و دانلود کرده و روی پوشه ست می‌کند.

تصویر محلی (اولویت ۲): در صورت قطعی اینترنت یا وجود تصویر، عکس موجود داخل پوشه را جایگزین می‌کند.

استخراج کاور از ویدیو (اولویت ۳): در صورت عدم وجود عکس، با ابزار ffmpeg از ویدیوی داخل پوشه یک فریم استخراج کرده و به عنوان آیکون ست می‌کند.

🌟 ویژگی‌ها
دانلود هوشمند پوستر: متصل به API دیتابیس MyAnimeList (Jikan) برای انیمه‌ها و سرچ مستقیم IMDb برای فیلم و سریال‌ها.

استخراج کاور از ویدیو (Backup): ساخت خودکار عکس از فایل‌های MKV, MP4 و... در حالت آفلاین.

پاک‌سازی هوشمند نام: حذف عباراتی مثل 1080p, BluRay, x264, WEB-DL و... موقع سرچ پوستر.

📋 نیازمندی‌ها
برای استخراج عکس و دانلود از API، ابزارهای زیر مورد نیاز هستند:

Bash
sudo apt update && sudo apt install ffmpeg curl python3 -y
🚀 نحوه نصب سریع
کافی است ترمینال را باز کرده و دستور زیر را اجرا کنید (نام کاربری خود در گیت‌هاب را جایگزین YOUR_USERNAME کنید):

Bash
curl -sSL [https://raw.githubusercontent.com/YOUR_USERNAME/nemo-smart-poster/main/install.sh](https://raw.githubusercontent.com/YOUR_USERNAME/nemo-smart-poster/main/install.sh) | bash
📜 License
This project is licensed under the MIT License.
