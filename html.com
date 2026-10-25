<!DOCTYPE html>
<html lang="id" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Media Pembelajaran Interaktif: Bilangan Bulat (SMP Kelas VII)</title>
    
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: {
                            50: '#eff6ff',
                            100: '#dbeafe',
                            500: '#3b82f6',
                            600: '#2563eb',
                            700: '#1d4ed8',
                            900: '#1e3a8a',
                        }
                    },
                    fontFamily: {
                        sans: ['Plus Jakarta Sans', 'sans-serif'],
                    }
                }
            }
        }
    </script>

    <!-- FontAwesome CDN -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <!-- Canvas Confetti CDN -->
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>

    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: #0f172a;
            color: #f8fafc;
            min-height: 100vh;
        }

        /* Glassmorphism Styles */
        .glass-panel {
            background: rgba(30, 41, 59, 0.7);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .glass-card {
            background: rgba(30, 41, 59, 0.5);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .glass-card:hover {
            border-color: rgba(99, 102, 241, 0.4);
            transform: translateY(-3px);
            box-shadow: 0 10px 25px -5px rgba(59, 130, 246, 0.15);
        }

        /* Custom Scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
        }
        ::-webkit-scrollbar-track {
            background: #0f172a;
        }
        ::-webkit-scrollbar-thumb {
            background: #334155;
            border-radius: 4px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: #475569;
        }

        /* Flip Card Effect */
        .perspective {
            perspective: 1000px;
        }
        .flip-card-inner {
            transition: transform 0.6s;
            transform-style: preserve-3d;
        }
        .flip-card.flipped .flip-card-inner {
            transform: rotateY(180deg);
        }
        .flip-card-front, .flip-card-back {
            backface-visibility: hidden;
            -webkit-backface-visibility: hidden;
        }
        .flip-card-back {
            transform: rotateY(180deg);
        }

        /* Active Navigation Tab */
        .nav-btn.active {
            background-color: #2563eb;
            color: #ffffff;
            box-shadow: 0 0 15px rgba(37, 99, 235, 0.4);
        }

        .subtab-btn.active {
            border-bottom: 2px solid #3b82f6;
            color: #60a5fa;
            background: rgba(59, 130, 246, 0.1);
        }
    </style>
</head>
<body class="bg-slate-950 text-slate-100 flex flex-col min-h-screen">

    <!-- AUDIO SYNTHESIZER SCRIPT & ENGINE -->
    <script>
        // Web Audio API Synthesizer Class for SFX
        class SoundEngine {
            constructor() {
                this.ctx = null;
                this.muted = false;
            }

            init() {
                if (!this.ctx) {
                    this.ctx = new (window.AudioContext || window.webkitAudioContext)();
                }
            }

            playClick() {
                if (this.muted) return;
                this.init();
                const osc = this.ctx.createOscillator();
                const gain = this.ctx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(600, this.ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(200, this.ctx.currentTime + 0.05);
                gain.gain.setValueAtTime(0.1, this.ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.05);
                osc.connect(gain);
                gain.connect(this.ctx.destination);
                osc.start();
                osc.stop(this.ctx.currentTime + 0.05);
            }

            playCorrect() {
                if (this.muted) return;
                this.init();
                const now = this.ctx.currentTime;
                const osc = this.ctx.createOscillator();
                const gain = this.ctx.createGain();
                osc.type = 'triangle';
                osc.frequency.setValueAtTime(523.25, now); // C5
                osc.frequency.setValueAtTime(659.25, now + 0.08); // E5
                osc.frequency.setValueAtTime(783.99, now + 0.16); // G5
                gain.gain.setValueAtTime(0.15, now);
                gain.gain.exponentialRampToValueAtTime(0.01, now + 0.3);
                osc.connect(gain);
                gain.connect(this.ctx.destination);
                osc.start(now);
                osc.stop(now + 0.3);
            }

            playWrong() {
                if (this.muted) return;
                this.init();
                const now = this.ctx.currentTime;
                const osc = this.ctx.createOscillator();
                const gain = this.ctx.createGain();
                osc.type = 'sawtooth';
                osc.frequency.setValueAtTime(180, now);
                osc.frequency.setValueAtTime(130, now + 0.12);
                gain.gain.setValueAtTime(0.15, now);
                gain.gain.exponentialRampToValueAtTime(0.01, now + 0.3);
                osc.connect(gain);
                gain.connect(this.ctx.destination);
                osc.start(now);
                osc.stop(now + 0.3);
            }

            playVictory() {
                if (this.muted) return;
                this.init();
                const notes = [261.63, 329.63, 392.00, 523.25, 659.25, 783.99];
                notes.forEach((freq, i) => {
                    const osc = this.ctx.createOscillator();
                    const gain = this.ctx.createGain();
                    const now = this.ctx.currentTime + (i * 0.08);
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(freq, now);
                    gain.gain.setValueAtTime(0.12, now);
                    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
                    osc.connect(gain);
                    gain.connect(this.ctx.destination);
                    osc.start(now);
                    osc.stop(now + 0.25);
                });
            }

            toggleMute() {
                this.muted = !this.muted;
                return this.muted;
            }
        }

        const sound = new SoundEngine();
    </script>

    <!-- HEADER & NAVIGATION -->
    <header class="sticky top-0 z-40 glass-panel border-b border-slate-800 px-4 lg:px-8 py-3">
        <div class="max-w-7xl mx-auto flex items-center justify-between gap-4">
            <!-- Brand & Title -->
            <div class="flex items-center gap-3 cursor-pointer" onclick="switchSection('hero')">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-blue-600 to-indigo-500 flex items-center justify-center text-white shadow-lg shadow-blue-500/30">
                    <i class="fa-solid font-bold text-lg fa-arrow-right-left"></i>
                </div>
                <div>
                    <h1 class="font-bold text-base md:text-lg text-slate-100 leading-tight">Bilangan Bulat</h1>
                    <p class="text-xs text-blue-400 font-medium hidden sm:block">Matematika SMP Kelas VII / Semester 1</p>
                </div>
            </div>

            <!-- Quick Navigation Controls -->
            <div class="flex items-center gap-2 md:gap-3">
                <!-- Status Badge Admin Active (Hidden by default) -->
                <div id="adminBadge" class="hidden px-2.5 py-1 rounded-lg bg-amber-500/20 text-amber-300 border border-amber-500/40 text-xs font-bold flex items-center gap-1.5 animate-pulse">
                    <i class="fa-solid fa-user-shield"></i>
                    <span class="hidden lg:inline">Admin: Depri Yesemo</span>
                </div>

                <!-- Admin Button (Left of Beranda) -->
                <button onclick="openAdminModal()" id="adminNavBtn" class="px-3 py-1.5 rounded-lg text-xs md:text-sm font-semibold bg-amber-500/10 hover:bg-amber-500/20 text-amber-400 transition flex items-center gap-2 border border-amber-500/30">
                    <i class="fa-solid fa-user-gear text-amber-400"></i>
                    <span class="hidden sm:inline">Admin</span>
                </button>

                <!-- Beranda Button -->
                <button onclick="switchSection('hero')" id="navBtnHero" class="nav-btn active px-3 py-1.5 rounded-lg text-xs md:text-sm font-medium transition flex items-center gap-2 hover:bg-slate-800 text-slate-300">
                    <i class="fa-solid fa-house"></i>
                    <span class="hidden md:inline">Beranda</span>
                </button>

                <!-- Audio Sound Toggle Button -->
                <button onclick="toggleSound()" id="soundToggleBtn" class="px-3 py-1.5 rounded-lg text-xs md:text-sm font-medium bg-slate-800 hover:bg-slate-700 text-slate-200 transition flex items-center gap-2 border border-slate-700">
                    <i class="fa-solid fa-volume-high text-blue-400" id="soundIcon"></i>
                    <span class="hidden sm:inline" id="soundText">Suara: ON</span>
                </button>
            </div>
        </div>
    </header>

    <!-- ADMIN MODAL DIALOG -->
    <div id="adminModal" class="fixed inset-0 z-50 hidden flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-md animate-fade-in">
        <div class="glass-panel w-full max-w-md rounded-3xl p-6 sm:p-8 space-y-6 border border-slate-700/80 shadow-2xl relative">
            <button onclick="closeAdminModal()" class="absolute top-4 right-4 w-8 h-8 rounded-full bg-slate-800 hover:bg-slate-700 text-slate-400 flex items-center justify-center transition">
                <i class="fa-solid fa-xmark"></i>
            </button>

            <div class="text-center space-y-2">
                <div class="w-16 h-16 mx-auto rounded-2xl bg-amber-500/10 border border-amber-500/30 flex items-center justify-center text-amber-400 text-2xl shadow-lg shadow-amber-500/10">
                    <i class="fa-solid fa-user-shield"></i>
                </div>
                <h3 class="text-2xl font-bold text-white">Hubungi Depri Yesemo</h3>
                <p class="text-xs text-slate-400 leading-relaxed">
                    Akses kontrol administrator diperlukan untuk mengedit konten media pembelajaran, soal kuis, serta manajemen refleksi.
                </p>
            </div>

            <!-- Modal Form -->
            <form onsubmit="handleAdminAuth(event)" class="space-y-4">
                <div class="space-y-1.5">
                    <label class="text-xs font-semibold text-slate-300">Password Administrator</label>
                    <div class="relative">
                        <input type="password" id="adminPassInput" placeholder="Masukkan Password" class="w-full pl-10 pr-4 py-3 bg-slate-900/90 border border-slate-700 rounded-xl text-sm text-white focus:outline-none focus:border-amber-500 transition">
                        <i class="fa-solid fa-key absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500 text-sm"></i>
                    </div>
                </div>

                <!-- Error Message Banner -->
                <div id="adminErrorMsg" class="hidden p-3 rounded-xl bg-rose-950/60 border border-rose-500/40 text-rose-300 text-xs font-medium space-y-1">
                    <div class="flex items-center gap-2 font-bold text-rose-400">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <span>Password Salah!</span>
                    </div>
                    <p>Silakan hubungi <strong class="text-white">Depri Yesemo</strong> untuk mendapatkan akses password administrator.</p>
                </div>

                <div class="flex gap-3 pt-2">
                    <button type="button" onclick="closeAdminModal()" class="w-1/2 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 font-semibold text-sm border border-slate-700 transition">
                        Batal
                    </button>
                    <button type="submit" class="w-1/2 py-2.5 rounded-xl bg-amber-500 hover:bg-amber-400 text-slate-950 font-bold text-sm shadow-lg shadow-amber-500/20 transition flex items-center justify-center gap-2">
                        <i class="fa-solid fa-lock-open"></i> Verifikasi
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- MAIN SPA CONTAINER -->
    <main class="flex-grow max-w-7xl w-full mx-auto p-4 sm:p-6 lg:p-8">

        <!-- ADMIN CONTROL PANEL BANNER (Visible when Edit Mode active) -->
        <div id="adminControlPanel" class="hidden mb-6 p-4 rounded-2xl bg-gradient-to-r from-amber-950/80 via-slate-900 to-indigo-950/80 border border-amber-500/40 shadow-xl space-y-3">
            <div class="flex items-center justify-between flex-wrap gap-3">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl bg-amber-500/20 border border-amber-500/40 flex items-center justify-center text-amber-400">
                        <i class="fa-solid fa-user-check text-lg"></i>
                    </div>
                    <div>
                        <h4 class="font-bold text-sm text-white flex items-center gap-2">
                            Mode Edit Aktif! <span class="text-xs bg-amber-500/20 text-amber-300 px-2 py-0.5 rounded-md font-normal border border-amber-500/30">Admin: Depri Yesemo</span>
                        </h4>
                        <p class="text-xs text-slate-300">Anda sekarang dapat mengedit materi, pertanyaan kuis, dan mengelola refleksi siswa.</p>
                    </div>
                </div>
                <div class="flex items-center gap-2">
                    <button onclick="saveAdminChanges()" class="px-3.5 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-semibold text-xs transition flex items-center gap-2 shadow-lg shadow-emerald-600/20">
                        <i class="fa-solid fa-floppy-disk"></i> Simpan Perubahan
                    </button>
                    <button onclick="lockAdminMode()" class="px-3.5 py-2 rounded-xl bg-rose-600/80 hover:bg-rose-600 text-white font-semibold text-xs transition flex items-center gap-2">
                        <i class="fa-solid fa-lock"></i> Keluar Admin
                    </button>
                </div>
            </div>
        </div>

        <!-- 1. HERO SECTION (MENU UTAMA) -->
        <section id="sec-hero" class="space-y-8 animate-fade-in">
            <!-- Banner Hero -->
            <div class="relative overflow-hidden rounded-3xl bg-gradient-to-r from-indigo-900/80 via-slate-900 to-blue-900/80 border border-indigo-500/20 p-8 sm:p-12 shadow-2xl">
                <div class="absolute -right-10 -bottom-10 w-80 h-80 bg-blue-500/10 rounded-full blur-3xl pointer-events-none"></div>
                <div class="relative z-10 max-w-2xl space-y-4">
                    <span class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-blue-500/10 text-blue-400 border border-blue-500/20">
                        <i class="fa-solid fa-sparkles"></i> Media Pembelajaran Interaktif
                    </span>
                    <h2 class="text-3xl sm:text-4xl lg:text-5xl font-extrabold tracking-tight text-white leading-tight">
                        Eksplorasi Dunia <span id="editableHeroTopic" class="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-indigo-300">Bilangan Bulat</span>
                    </h2>
                    <p id="editableHeroDesc" class="text-slate-300 text-sm sm:text-base leading-relaxed">
                        Pahami konsep titik acuan nol, garis bilangan, serta cara membandingkan bilangan positif dan negatif melalui simulasi interaktif dan mini games visual!
                    </p>
                    <div class="pt-2 flex flex-wrap gap-4">
                        <button onclick="switchSection('materi')" class="px-6 py-3 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-semibold shadow-lg shadow-blue-600/30 transition flex items-center gap-3 group">
                            Mulai Belajar
                            <i class="fa-solid fa-arrow-right transition-transform group-hover:translate-x-1"></i>
                        </button>
                        <button onclick="switchSection('tujuan')" class="px-6 py-3 rounded-xl bg-slate-800/80 hover:bg-slate-700 text-slate-200 font-semibold border border-slate-700 transition">
                            Lihat Tujuan
                        </button>
                    </div>
                </div>
            </div>

            <!-- Grid Navigation Cards -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
                <!-- Card 1: Tujuan -->
                <div onclick="switchSection('tujuan')" class="glass-card p-6 rounded-2xl cursor-pointer group">
                    <div class="w-12 h-12 rounded-xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center text-blue-400 text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-bullseye"></i>
                    </div>
                    <h3 class="text-lg font-bold text-slate-100 mb-1">Tujuan Pembelajaran</h3>
                    <p class="text-xs text-slate-400">Target kompetensi dan capaian pembelajaran yang akan dicapai.</p>
                </div>

                <!-- Card 2: Pemantik -->
                <div onclick="switchSection('pemantik')" class="glass-card p-6 rounded-2xl cursor-pointer group">
                    <div class="w-12 h-12 rounded-xl bg-indigo-500/10 border border-indigo-500/20 flex items-center justify-center text-indigo-400 text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-lightbulb"></i>
                    </div>
                    <h3 class="text-lg font-bold text-slate-100 mb-1">Pertanyaan Pemantik</h3>
                    <p class="text-xs text-slate-400">Uji rasa ingin tahu kamu dengan flip card interaktif.</p>
                </div>

                <!-- Card 3: Materi & Simulasi -->
                <div onclick="switchSection('materi')" class="glass-card p-6 rounded-2xl cursor-pointer group">
                    <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400 text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-book-open"></i>
                    </div>
                    <h3 class="text-lg font-bold text-slate-100 mb-1">Materi & Simulasi</h3>
                    <p class="text-xs text-slate-400">Pelajari modul visual & eksperimen garis bilangan interaktif.</p>
                </div>

                <!-- Card 4: Kuis -->
                <div onclick="switchSection('kuis')" class="glass-card p-6 rounded-2xl cursor-pointer group">
                    <div class="w-12 h-12 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400 text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </div>
                    <h3 class="text-lg font-bold text-slate-100 mb-1">Kuis Interaktif</h3>
                    <p class="text-xs text-slate-400">10 Soal latihan evaluasi pemahaman dengan skor real-time.</p>
                </div>

                <!-- Card 5: Mini Game -->
                <div onclick="switchSection('game')" class="glass-card p-6 rounded-2xl cursor-pointer group">
                    <div class="w-12 h-12 rounded-xl bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-purple-400 text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-gamepad"></i>
                    </div>
                    <h3 class="text-lg font-bold text-slate-100 mb-1">Sorting Game</h3>
                    <p class="text-xs text-slate-400">Permainan pengelompokan bilangan positif dan negatif.</p>
                </div>

                <!-- Card 6: Refleksi -->
                <div onclick="switchSection('refleksi')" class="glass-card p-6 rounded-2xl cursor-pointer group">
                    <div class="w-12 h-12 rounded-xl bg-rose-500/10 border border-rose-500/20 flex items-center justify-center text-rose-400 text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-comments"></i>
                    </div>
                    <h3 class="text-lg font-bold text-slate-100 mb-1">Papan Refleksi</h3>
                    <p class="text-xs text-slate-400">Bagikan pesan, perasaan, dan pengalaman belajarmu.</p>
                </div>
            </div>
        </section>

        <!-- 2. TUJUAN PEMBELAJARAN SECTION -->
        <section id="sec-tujuan" class="hidden space-y-6">
            <div class="flex items-center gap-3 mb-6">
                <div class="p-3 bg-blue-500/10 rounded-xl text-blue-400 border border-blue-500/20">
                    <i class="fa-solid fa-bullseye text-2xl"></i>
                </div>
                <div>
                    <h2 class="text-2xl font-bold text-white">Tujuan Pembelajaran</h2>
                    <p class="text-sm text-slate-400">Target ketercapaian materi Bilangan Bulat</p>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <!-- Target 1 -->
                <div class="glass-panel p-6 rounded-2xl border-l-4 border-l-blue-500 flex flex-col justify-between space-y-4">
                    <div>
                        <span class="text-xs font-bold px-2.5 py-1 bg-blue-500/20 text-blue-300 rounded-md">Indikator 1</span>
                        <h3 class="text-lg font-bold text-white mt-3">Konsep & Titik Acuan 0</h3>
                        <p id="targetDesc1" class="text-slate-300 text-sm mt-2 leading-relaxed">
                            Peserta didik mampu memahami konsep bilangan bulat positif dan negatif yang menggunakan titik acuan 0 dalam kehidupan sehari-hari (seperti suhu, kedalaman laut, dan finansial).
                        </p>
                    </div>
                    <div class="text-xs text-blue-400 font-semibold flex items-center gap-2">
                        <i class="fa-solid fa-circle-check"></i> Pemahaman Konseptual
                    </div>
                </div>

                <!-- Target 2 -->
                <div class="glass-panel p-6 rounded-2xl border-l-4 border-l-indigo-500 flex flex-col justify-between space-y-4">
                    <div>
                        <span class="text-xs font-bold px-2.5 py-1 bg-indigo-500/20 text-indigo-300 rounded-md">Indikator 2</span>
                        <h3 class="text-lg font-bold text-white mt-3">Garis Bilangan</h3>
                        <p id="targetDesc2" class="text-slate-300 text-sm mt-2 leading-relaxed">
                            Peserta didik mampu menentukan dan menyajikan letak bilangan bulat positif dan negatif secara presisi pada garis bilangan horizontal maupun vertikal.
                        </p>
                    </div>
                    <div class="text-xs text-indigo-400 font-semibold flex items-center gap-2">
                        <i class="fa-solid fa-circle-check"></i> Keterampilan Visual
                    </div>
                </div>

                <!-- Target 3 -->
                <div class="glass-panel p-6 rounded-2xl border-l-4 border-l-emerald-500 flex flex-col justify-between space-y-4">
                    <div>
                        <span class="text-xs font-bold px-2.5 py-1 bg-emerald-500/20 text-emerald-300 rounded-md">Indikator 3</span>
                        <h3 class="text-lg font-bold text-white mt-3">Membandingkan Bilangan</h3>
                        <p id="targetDesc3" class="text-slate-300 text-sm mt-2 leading-relaxed">
                            Peserta didik mampu membandingkan dan mengurutkan pasangan/sekelompok bilangan bulat menggunakan relasi simbol (&lt;, &gt;, =).
                        </p>
                    </div>
                    <div class="text-xs text-emerald-400 font-semibold flex items-center gap-2">
                        <i class="fa-solid fa-circle-check"></i> Analisis & Penalaran
                    </div>
                </div>
            </div>
        </section>

        <!-- 3. PERTANYAAN PEMANTIK SECTION -->
        <section id="sec-pemantik" class="hidden space-y-6">
            <div class="flex items-center gap-3 mb-6">
                <div class="p-3 bg-indigo-500/10 rounded-xl text-indigo-400 border border-indigo-500/20">
                    <i class="fa-solid fa-lightbulb text-2xl"></i>
                </div>
                <div>
                    <h2 class="text-2xl font-bold text-white">Pertanyaan Pemantik</h2>
                    <p class="text-sm text-slate-400">Klik kartu di bawah ini untuk membuka konsep dasar!</p>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <!-- Card Pemantik 1 -->
                <div class="flip-card perspective h-64 cursor-pointer" onclick="toggleFlip(this)">
                    <div class="flip-card-inner relative w-full h-full rounded-2xl shadow-xl transition-all duration-500">
                        <!-- Front -->
                        <div class="flip-card-front absolute inset-0 glass-panel rounded-2xl p-6 flex flex-col justify-between border border-indigo-500/30">
                            <div>
                                <span class="px-3 py-1 bg-indigo-500/20 text-indigo-300 rounded-full text-xs font-semibold">Teka-Teki Suhu</span>
                                <h3 class="text-xl font-bold text-white mt-4">
                                    "Apakah ada suhu udara di bawah 0°C? Bagaimana cara kita menuliskannya secara matematis?"
                                </h3>
                            </div>
                            <div class="text-xs text-indigo-400 font-medium flex items-center justify-between">
                                <span>Klik kartu untuk melihat jawaban</span>
                                <i class="fa-solid fa-rotate-right"></i>
                            </div>
                        </div>
                        <!-- Back -->
                        <div class="flip-card-back absolute inset-0 bg-gradient-to-br from-indigo-900 to-slate-900 rounded-2xl p-6 flex flex-col justify-between border border-indigo-500/50">
                            <div>
                                <h4 class="font-bold text-indigo-300 mb-2">Penjelasan Konsep:</h4>
                                <p class="text-slate-200 text-sm leading-relaxed">
                                    Ada! Suhu di bawah 0°C ditulis menggunakan tanda negatif (–). Misalnya, suhu 5 derajat di bawah nol ditulis sebagai <strong class="text-blue-400 font-bold">-5°C</strong>. Angka 0 menjadi titik acuannya!
                                </p>
                            </div>
                            <div class="text-xs text-slate-400 flex items-center justify-between">
                                <span>Titik Acuan 0°C</span>
                                <i class="fa-solid fa-temperature-arrow-down text-blue-400 text-lg"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card Pemantik 2 -->
                <div class="flip-card perspective h-64 cursor-pointer" onclick="toggleFlip(this)">
                    <div class="flip-card-inner relative w-full h-full rounded-2xl shadow-xl transition-all duration-500">
                        <!-- Front -->
                        <div class="flip-card-front absolute inset-0 glass-panel rounded-2xl p-6 flex flex-col justify-between border border-blue-500/30">
                            <div>
                                <span class="px-3 py-1 bg-blue-500/20 text-blue-300 rounded-full text-xs font-semibold">Teka-Teki Ketinggian</span>
                                <h3 class="text-xl font-bold text-white mt-4">
                                    "Penyelam berada 10 meter di bawah laut, pendaki di 10 meter di atas permukaan laut. Apakah nilainya sama?"
                                </h3>
                            </div>
                            <div class="text-xs text-blue-400 font-medium flex items-center justify-between">
                                <span>Klik kartu untuk melihat jawaban</span>
                                <i class="fa-solid fa-rotate-right"></i>
                            </div>
                        </div>
                        <!-- Back -->
                        <div class="flip-card-back absolute inset-0 bg-gradient-to-br from-blue-900 to-slate-900 rounded-2xl p-6 flex flex-col justify-between border border-blue-500/50">
                            <div>
                                <h4 class="font-bold text-blue-300 mb-2">Penjelasan Konsep:</h4>
                                <p class="text-slate-200 text-sm leading-relaxed">
                                    Meskipun jaraknya sama (10m), arahnya berlawanan! Permukaan laut adalah titik acuan (0). Mendaki 10m bernilai <strong class="text-emerald-400">+10m</strong>, sedangkan menyelam 10m di bawah laut bernilai <strong class="text-rose-400">-10m</strong>.
                                </p>
                            </div>
                            <div class="text-xs text-slate-400 flex items-center justify-between">
                                <span>Titik Acuan Permukaan Laut (0m)</span>
                                <i class="fa-solid fa-water-ladder text-blue-400 text-lg"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- 4. MATERI & SIMULASI SECTION -->
        <section id="sec-materi" class="hidden space-y-6">
            <div class="flex items-center justify-between flex-wrap gap-4 mb-2">
                <div class="flex items-center gap-3">
                    <div class="p-3 bg-emerald-500/10 rounded-xl text-emerald-400 border border-emerald-500/20">
                        <i class="fa-solid fa-book-open text-2xl"></i>
                    </div>
                    <div>
                        <h2 class="text-2xl font-bold text-white">Materi & Simulasi Interaktif</h2>
                        <p class="text-sm text-slate-400">Pelajari konsep dan uji coba langsung</p>
                    </div>
                </div>
            </div>

            <!-- Sub-Tabs Navigation -->
            <div class="flex border-b border-slate-800 overflow-x-auto">
                <button onclick="switchSubTab('tab1')" id="btn-tab1" class="subtab-btn active px-5 py-3 text-sm font-semibold text-slate-300 hover:text-white transition whitespace-nowrap">
                    1. Bilangan Ber-Tanda
                </button>
                <button onclick="switchSubTab('tab2')" id="btn-tab2" class="subtab-btn px-5 py-3 text-sm font-semibold text-slate-400 hover:text-white transition whitespace-nowrap">
                    2. Garis Bilangan
                </button>
                <button onclick="switchSubTab('tab3')" id="btn-tab3" class="subtab-btn px-5 py-3 text-sm font-semibold text-slate-400 hover:text-white transition whitespace-nowrap">
                    3. Membandingkan Bilangan
                </button>
                <button onclick="switchSubTab('tab-simulasi')" id="btn-tab-simulasi" class="subtab-btn px-5 py-3 text-sm font-semibold text-emerald-400 hover:text-emerald-300 transition whitespace-nowrap flex items-center gap-2">
                    <i class="fa-solid fa-flask"></i> Laboratorium Simulasi
                </button>
            </div>

            <!-- SUBTAB 1: BILANGAN DENGAN TANDA -->
            <div id="subtab-tab1" class="subtab-content space-y-6">
                <div class="glass-panel p-6 rounded-2xl space-y-4">
                    <h3 class="text-xl font-bold text-blue-400">Besaran dengan Titik Acuan 0</h3>
                    <p class="text-slate-300 text-sm leading-relaxed">
                        Dalam kehidupan nyata, terdapat besaran yang saling berlawanan arah. Untuk membedakannya, kita menetapkan satu titik awal yang dinamakan <strong class="text-white">Titik Acuan 0</strong>.
                    </p>
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 pt-2">
                        <div class="p-4 rounded-xl bg-emerald-950/40 border border-emerald-500/30">
                            <h4 class="font-bold text-emerald-400 flex items-center gap-2 mb-2">
                                <i class="fa-solid fa-plus-circle"></i> Bilangan Positif (+)
                            </h4>
                            <p class="text-xs text-slate-300 leading-relaxed">
                                Menyatakan nilai di atas/sebelah kanan titik acuan 0. Contoh: Keuntungan, suhu di atas 0°C, ketinggian di atas permukaan laut.
                            </p>
                        </div>
                        <div class="p-4 rounded-xl bg-rose-950/40 border border-rose-500/30">
                            <h4 class="font-bold text-rose-400 flex items-center gap-2 mb-2">
                                <i class="fa-solid fa-minus-circle"></i> Bilangan Negatif (-)
                            </h4>
                            <p class="text-xs text-slate-300 leading-relaxed">
                                Menyatakan nilai di bawah/sebelah kiri titik acuan 0. Contoh: Kerugian, suhu di bawah 0°C, kedalaman di bawah laut.
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- SUBTAB 2: GARIS BILANGAN -->
            <div id="subtab-tab2" class="subtab-content hidden space-y-6">
                <div class="glass-panel p-6 rounded-2xl space-y-4">
                    <h3 class="text-xl font-bold text-blue-400">Prinsip Garis Bilangan</h3>
                    <p class="text-slate-300 text-sm leading-relaxed">
                        Garis bilangan membantu kita mengurutkan dan memvisualisasikan posisi bilangan bulat:
                    </p>
                    <ul class="list-disc list-inside text-sm text-slate-300 space-y-2 pl-2">
                        <li>Angka <strong class="text-white">0</strong> berada tepat di tengah sebagai titik acuan.</li>
                        <li>Bilangan di sebelah <strong class="text-emerald-400">kanan 0</strong> adalah bilangan <strong class="text-emerald-400">Positif</strong> (+1, +2, +3, ...).</li>
                        <li>Bilangan di sebelah <strong class="text-rose-400">kiri 0</strong> adalah bilangan <strong class="text-rose-400">Negatif</strong> (-1, -2, -3, ...).</li>
                        <li>Makin ke <strong class="text-white">kanan</strong>, nilainya makin <strong class="text-emerald-400">besar</strong>. Makin ke <strong class="text-white">kiri</strong>, nilainya makin <strong class="text-rose-400">kecil</strong>.</li>
                    </ul>
                </div>
            </div>

            <!-- SUBTAB 3: MEMBANDINGKAN BILANGAN -->
            <div id="subtab-tab3" class="subtab-content hidden space-y-6">
                <div class="glass-panel p-6 rounded-2xl space-y-4">
                    <h3 class="text-xl font-bold text-blue-400">Aturan Membandingkan Bilangan Bulat</h3>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div class="p-4 bg-slate-800/60 rounded-xl border border-slate-700">
                            <h4 class="font-bold text-white text-sm mb-2">Simbol Perbandingan</h4>
                            <p class="text-xs text-slate-300 leading-relaxed">
                                <span class="text-blue-400 font-bold">&lt;</span> : Lebih kecil dari<br>
                                <span class="text-blue-400 font-bold">&gt;</span> : Lebih besar dari<br>
                                <span class="text-blue-400 font-bold">=</span> : Sama dengan
                            </p>
                        </div>
                        <div class="p-4 bg-slate-800/60 rounded-xl border border-slate-700">
                            <h4 class="font-bold text-white text-sm mb-2">Positif vs Negatif</h4>
                            <p class="text-xs text-slate-300 leading-relaxed">
                                Bilangan positif selalu <strong>lebih besar</strong> daripada bilangan negatif.<br> Contoh: <span class="text-emerald-400">+2 &gt; -100</span>.
                            </p>
                        </div>
                        <div class="p-4 bg-slate-800/60 rounded-xl border border-slate-700">
                            <h4 class="font-bold text-white text-sm mb-2">Sesama Negatif</h4>
                            <p class="text-xs text-slate-300 leading-relaxed">
                                Pada bilangan negatif, makin besar angkanya, nilainya justru <strong>makin kecil</strong> (karena lebih jauh di kiri). Contoh: <span class="text-rose-400">-2 &gt; -5</span>.
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- SUBTAB 4: SIMULASI INTERAKTIF WAJIB -->
            <div id="subtab-tab-simulasi" class="subtab-content hidden space-y-8">
                <!-- Simulation 1: Interactive Number Line & Thermometer -->
                <div class="glass-panel p-6 rounded-2xl space-y-6">
                    <div class="flex items-center justify-between">
                        <h3 class="text-xl font-bold text-emerald-400 flex items-center gap-2">
                            <i class="fa-solid fa-sliders"></i> Simulasi Garis Bilangan & Termometer Digital
                        </h3>
                        <span class="text-xs bg-emerald-500/20 text-emerald-300 px-3 py-1 rounded-full border border-emerald-500/30">Manipulasi Real-Time</span>
                    </div>

                    <!-- Controller Input -->
                    <div class="flex flex-col sm:flex-row items-center gap-4 bg-slate-900/80 p-4 rounded-xl border border-slate-800">
                        <label for="simSlider" class="text-sm font-semibold text-slate-200">Geser Nilai Bilangan:</label>
                        <input type="range" id="simSlider" min="-10" max="10" value="0" class="w-full accent-blue-500 cursor-pointer" oninput="updateSim(this.value)">
                        <input type="number" id="simNumberInput" min="-10" max="10" value="0" class="w-20 px-3 py-1.5 bg-slate-800 border border-slate-700 rounded-lg text-center font-bold text-blue-400" onchange="updateSim(this.value)">
                    </div>

                    <!-- Visual Output Canvas -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4">
                        <!-- Horizontal Number Line Display -->
                        <div class="bg-slate-900/90 p-6 rounded-xl border border-slate-800 flex flex-col justify-between items-center min-h-[200px]">
                            <span class="text-xs text-slate-400 font-semibold mb-2">GARIS BILANGAN HORIZONTAL</span>
                            
                            <!-- Graphic Number Line -->
                            <div class="w-full relative py-8">
                                <div class="w-full h-1 bg-slate-700 rounded relative"></div>
                                <div id="simPointer" class="absolute top-1/2 -translate-y-1/2 -translate-x-1/2 transition-all duration-300 flex flex-col items-center" style="left: 50%;">
                                    <span id="simBadge" class="px-2 py-1 bg-blue-600 text-white font-extrabold text-xs rounded shadow-lg mb-1">0</span>
                                    <div class="w-3 h-3 bg-blue-400 rounded-full border-2 border-white animate-ping"></div>
                                </div>
                            </div>

                            <div class="flex justify-between w-full text-xs font-mono text-slate-400">
                                <span>-10</span>
                                <span>-5</span>
                                <span class="text-white font-bold">0</span>
                                <span>+5</span>
                                <span>+10</span>
                            </div>
                        </div>

                        <!-- Real-World Indicator (Thermometer & Sea Level) -->
                        <div class="bg-slate-900/90 p-6 rounded-xl border border-slate-800 flex items-center justify-around">
                            <!-- Thermometer Graphic -->
                            <div class="flex flex-col items-center gap-2">
                                <span class="text-xs text-slate-400 font-semibold">TERMOMETER</span>
                                <div class="w-6 h-32 bg-slate-800 rounded-full border-2 border-slate-700 relative overflow-hidden flex flex-col justify-end">
                                    <div id="thermoFill" class="w-full bg-blue-500 transition-all duration-300" style="height: 50%;"></div>
                                </div>
                                <span id="thermoText" class="text-sm font-bold text-blue-400">0°C</span>
                            </div>

                            <!-- Context Status Text -->
                            <div class="space-y-2 text-left max-w-[200px]">
                                <span class="text-xs text-slate-400 font-semibold block">STATUS KONTEKS</span>
                                <div id="simContextBox" class="p-3 bg-slate-800/80 rounded-lg text-xs space-y-1 border border-slate-700">
                                    <p class="font-bold text-white" id="simContextTitle">Titik Acuan (Nol)</p>
                                    <p class="text-slate-300" id="simContextDesc">Berada tepat di posisi netral.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Simulation 2: Interactive Number Comparator -->
                <div class="glass-panel p-6 rounded-2xl space-y-6">
                    <h3 class="text-xl font-bold text-indigo-400 flex items-center gap-2">
                        <i class="fa-solid fa-scale-balanced"></i> Pembanding Dua Bilangan Bulat
                    </h3>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-center bg-slate-900/80 p-6 rounded-xl border border-slate-800 text-center">
                        <!-- Input Bilangan A -->
                        <div class="space-y-2">
                            <label class="text-xs font-semibold text-slate-400">Bilangan Pertama (A)</label>
                            <input type="number" id="compA" value="-3" class="w-full text-center py-2 bg-slate-800 border border-slate-700 rounded-xl font-bold text-xl text-white focus:outline-none focus:border-blue-500" oninput="compareNumbers()">
                        </div>

                        <!-- Result Symbol -->
                        <div class="space-y-1">
                            <span class="text-xs text-slate-400 block">Simbol Relasi</span>
                            <div id="compSymbol" class="text-4xl font-extrabold text-blue-400 py-2">?</div>
                        </div>

                        <!-- Input Bilangan B -->
                        <div class="space-y-2">
                            <label class="text-xs font-semibold text-slate-400">Bilangan Kedua (B)</label>
                            <input type="number" id="compB" value="4" class="w-full text-center py-2 bg-slate-800 border border-slate-700 rounded-xl font-bold text-xl text-white focus:outline-none focus:border-blue-500" oninput="compareNumbers()">
                        </div>
                    </div>

                    <!-- Comparison Feedback Banner -->
                    <div id="compFeedback" class="p-4 rounded-xl bg-blue-950/40 border border-blue-500/30 text-center text-sm font-medium text-slate-200">
                        Masukkan angka untuk melihat perbandingan.
                    </div>
                </div>
            </div>
        </section>

        <!-- 5. KUIS INTERAKTIF SECTION -->
        <section id="sec-kuis" class="hidden space-y-6">
            <div class="flex items-center justify-between flex-wrap gap-4">
                <div class="flex items-center gap-3">
                    <div class="p-3 bg-amber-500/10 rounded-xl text-amber-400 border border-amber-500/20">
                        <i class="fa-solid fa-pen-to-square text-2xl"></i>
                    </div>
                    <div>
                        <h2 class="text-2xl font-bold text-white">Kuis Interaktif Bilangan Bulat</h2>
                        <p class="text-sm text-slate-400">Evaluasi pemahamanmu melalui 10 soal pilihan ganda</p>
                    </div>
                </div>

                <div class="flex items-center gap-4">
                    <!-- Score Tracker -->
                    <div class="px-4 py-2 glass-card rounded-xl border border-slate-700 text-right">
                        <span class="text-xs text-slate-400 block">Skor Saat Ini</span>
                        <span id="quizScoreText" class="text-lg font-extrabold text-amber-400">0 / 100</span>
                    </div>
                </div>
            </div>

            <!-- Quiz Container Card -->
            <div id="quizContainer" class="glass-panel p-6 sm:p-8 rounded-2xl space-y-6 relative">
                <!-- Progress Bar -->
                <div class="space-y-2">
                    <div class="flex justify-between text-xs text-slate-400 font-semibold">
                        <span id="quizProgressNum">Soal 1 dari 10</span>
                        <span id="quizProgressPercent">10% Selesai</span>
                    </div>
                    <div class="w-full h-2 bg-slate-800 rounded-full overflow-hidden">
                        <div id="quizProgressBar" class="h-full bg-gradient-to-r from-amber-500 to-blue-500 transition-all duration-300" style="width: 10%;"></div>
                    </div>
                </div>

                <!-- Question Text -->
                <div class="pt-2">
                    <h3 id="quizQuestionText" class="text-lg sm:text-xl font-bold text-white leading-relaxed">
                        Memuat Pertanyaan...
                    </h3>
                </div>

                <!-- Options Grid -->
                <div id="quizOptionsContainer" class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <!-- Options inserted dynamically via JS -->
                </div>

                <!-- Explanation Box -->
                <div id="quizExplanationBox" class="hidden p-4 rounded-xl bg-slate-900/90 border border-slate-700 space-y-2">
                    <h4 id="quizResultStatus" class="font-bold text-sm"></h4>
                    <p id="quizExplanationText" class="text-xs text-slate-300 leading-relaxed"></p>
                </div>

                <!-- Action Button -->
                <div class="flex justify-end pt-2">
                    <button id="quizNextBtn" onclick="nextQuestion()" class="hidden px-6 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-semibold text-sm shadow-lg transition flex items-center gap-2">
                        Soal Berikutnya <i class="fa-solid fa-arrow-right"></i>
                    </button>
                </div>
            </div>

            <!-- Quiz Score Result Summary Card (Hidden by default) -->
            <div id="quizResultSummary" class="hidden glass-panel p-8 rounded-2xl text-center space-y-6">
                <div class="w-20 h-20 mx-auto rounded-full bg-amber-500/20 border border-amber-500/40 flex items-center justify-center text-amber-400 text-3xl">
                    <i class="fa-solid fa-trophy"></i>
                </div>
                <div>
                    <h3 class="text-2xl font-bold text-white">Kuis Selesai!</h3>
                    <p class="text-slate-400 text-sm mt-1">Berikut adalah hasil evaluasi kamu:</p>
                </div>
                <div class="text-5xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-amber-400 to-blue-400" id="finalScoreVal">
                    0
                </div>
                <p id="finalScorePredicate" class="text-slate-300 font-semibold text-sm"></p>
                <button onclick="resetQuiz()" class="px-6 py-3 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-semibold text-sm shadow-lg transition">
                    Ulangi Kuis
                </button>
            </div>
        </section>

        <!-- 6. EVALUASI INTERAKTIF & GAMES (SORTING GAME) -->
        <section id="sec-game" class="hidden space-y-6">
            <div class="flex items-center gap-3 mb-4">
                <div class="p-3 bg-purple-500/10 rounded-xl text-purple-400 border border-purple-500/20">
                    <i class="fa-solid fa-gamepad text-2xl"></i>
                </div>
                <div>
                    <h2 class="text-2xl font-bold text-white">Mini Game: Pengelompokan Bilangan</h2>
                    <p class="text-sm text-slate-400">Klasifikasikan kartu ke wadah yang tepat (Drag & Drop atau Tap)</p>
                </div>
            </div>

            <!-- Game Board -->
            <div class="glass-panel p-6 rounded-2xl space-y-6">
                <!-- Source Cards Pool -->
                <div class="space-y-2">
                    <span class="text-xs font-semibold text-slate-400">KARTU PILIHAN (Klik/Tap atau Drag kartu ke wadah tujuan):</span>
                    <div id="gameCardPool" class="flex flex-wrap gap-3 p-4 bg-slate-900/80 rounded-xl border border-slate-800 min-h-[100px] items-center">
                        <!-- Cards dynamically inserted -->
                    </div>
                </div>

                <!-- 2 Target Containers -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Drop Zone 1: Positif -->
                    <div id="dropPositiv" ondragover="allowDrop(event)" ondrop="handleDrop(event, 'positive')" class="p-6 rounded-2xl bg-emerald-950/20 border-2 border-dashed border-emerald-500/40 flex flex-col justify-between min-h-[220px] transition-colors">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-bold text-emerald-400 flex items-center gap-2 text-sm sm:text-base">
                                <i class="fa-solid fa-arrow-up-right-dots"></i> Bilangan Positif / Di Atas 0
                            </h3>
                            <span class="text-xs bg-emerald-500/20 text-emerald-300 px-2.5 py-0.5 rounded-full" id="countPositive">0 Kartu</span>
                        </div>
                        <div id="containerPositive" class="flex flex-wrap gap-2 flex-grow items-start">
                            <!-- Selected cards appear here -->
                        </div>
                    </div>

                    <!-- Drop Zone 2: Negatif -->
                    <div id="dropNegativ" ondragover="allowDrop(event)" ondrop="handleDrop(event, 'negative')" class="p-6 rounded-2xl bg-rose-950/20 border-2 border-dashed border-rose-500/40 flex flex-col justify-between min-h-[220px] transition-colors">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-bold text-rose-400 flex items-center gap-2 text-sm sm:text-base">
                                <i class="fa-solid fa-arrow-down-left-dots"></i> Bilangan Negatif / Di Bawah 0
                            </h3>
                            <span class="text-xs bg-rose-500/20 text-rose-300 px-2.5 py-0.5 rounded-full" id="countNegative">0 Kartu</span>
                        </div>
                        <div id="containerNegative" class="flex flex-wrap gap-2 flex-grow items-start">
                            <!-- Selected cards appear here -->
                        </div>
                    </div>
                </div>

                <!-- Game Controls & Validation -->
                <div class="flex justify-between items-center pt-2">
                    <button onclick="resetGame()" class="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-semibold border border-slate-700 transition">
                        Reset Permainan
                    </button>
                    <button onclick="validateGame()" class="px-6 py-2.5 rounded-xl bg-purple-600 hover:bg-purple-500 text-white font-semibold text-sm shadow-lg shadow-purple-600/30 transition">
                        Periksa Jawaban
                    </button>
                </div>
            </div>
        </section>

        <!-- 7. PAPAN REFLEKSI KOLABORATIF -->
        <section id="sec-refleksi" class="hidden space-y-6">
            <div class="flex items-center justify-between flex-wrap gap-4 mb-4">
                <div class="flex items-center gap-3">
                    <div class="p-3 bg-rose-500/10 rounded-xl text-rose-400 border border-rose-500/20">
                        <i class="fa-solid fa-comments text-2xl"></i>
                    </div>
                    <div>
                        <h2 class="text-2xl font-bold text-white">Papan Refleksi Belajar</h2>
                        <p class="text-sm text-slate-400">Ungkapkan pesan, kesan, dan perasaanmu setelah belajar!</p>
                    </div>
                </div>

                <!-- Admin Clear Notes Option -->
                <button id="adminClearReflectionsBtn" onclick="clearAllReflections()" class="hidden px-3.5 py-2 rounded-xl bg-rose-950/60 hover:bg-rose-900 border border-rose-500/40 text-rose-300 font-semibold text-xs transition flex items-center gap-2">
                    <i class="fa-solid fa-trash-can"></i> Bersihkan Semua Note
                </button>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                <!-- Input Form -->
                <div class="glass-panel p-6 rounded-2xl space-y-4 h-fit">
                    <h3 class="text-lg font-bold text-white">Tambah Catatan Refleksi</h3>
                    
                    <div class="space-y-1">
                        <label class="text-xs text-slate-400 font-semibold">Nama Siswa</label>
                        <input type="text" id="refName" placeholder="Contoh: Budi Santoso" class="w-full px-3 py-2 bg-slate-900 border border-slate-700 rounded-xl text-sm text-white focus:outline-none focus:border-rose-500">
                    </div>

                    <div class="space-y-1">
                        <label class="text-xs text-slate-400 font-semibold">Perasaan Kamu</label>
                        <select id="refEmoji" class="w-full px-3 py-2 bg-slate-900 border border-slate-700 rounded-xl text-sm text-white focus:outline-none focus:border-rose-500">
                            <option value="😃 Sangat Paham">😃 Sangat Paham & Senang</option>
                            <option value="🤔 Masih Perlu Berlatih">🤔 Masih Perlu Berlatih</option>
                            <option value="🚀 Sangat Seru!">🚀 Sangat Seru!</option>
                        </select>
                    </div>

                    <div class="space-y-1">
                        <label class="text-xs text-slate-400 font-semibold">Pesan / Hal yang Dipelajari</label>
                        <textarea id="refMessage" rows="3" placeholder="Tuliskan pengalaman belajarmu di sini..." class="w-full px-3 py-2 bg-slate-900 border border-slate-700 rounded-xl text-sm text-white focus:outline-none focus:border-rose-500 resize-none"></textarea>
                    </div>

                    <button onclick="addReflection()" class="w-full py-2.5 bg-rose-600 hover:bg-rose-500 text-white font-semibold text-sm rounded-xl shadow-lg transition">
                        Tempel Sticky Note
                    </button>
                </div>

                <!-- Virtual Board for Sticky Notes -->
                <div class="lg:col-span-2 glass-panel p-6 rounded-2xl min-h-[350px]">
                    <h3 class="text-sm font-bold text-slate-400 uppercase tracking-wider mb-4">Papan Sticky Notes Virtual</h3>
                    <div id="stickyBoard" class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <!-- Default Sticky Notes -->
                    </div>
                </div>
            </div>
        </section>

    </main>

    <!-- FOOTER -->
    <footer class="glass-panel border-t border-slate-800 py-6 px-4 text-center text-xs text-slate-400 mt-12">
        <div class="max-w-7xl mx-auto space-y-2">
            <p class="font-medium text-slate-300">Media Pembelajaran Interaktif Matematika — Kurikulum Merdeka</p>
            <p>Dirancang khusus untuk Jenjang SMP Kelas VII (Semester 1) • Topik: Bilangan Bulat</p>
            <p class="text-slate-500">© 2026 Admin Depri Yesemo • All Rights Reserved.</p>
        </div>
    </footer>

    <!-- MAIN JAVASCRIPT ENGINE -->
    <script>
        // ADMIN STATE MANAGEMENT
        let isAdminLoggedIn = false;

        function openAdminModal() {
            sound.playClick();
            document.getElementById('adminModal').classList.remove('hidden');
            document.getElementById('adminErrorMsg').classList.add('hidden');
            document.getElementById('adminPassInput').value = '';
            document.getElementById('adminPassInput').focus();
        }

        function closeAdminModal() {
            sound.playClick();
            document.getElementById('adminModal').classList.add('hidden');
        }

        function handleAdminAuth(e) {
            e.preventDefault();
            const pass = document.getElementById('adminPassInput').value.trim();

            if (pass.toLowerCase() === 'yesemo') {
                sound.playCorrect();
                isAdminLoggedIn = true;
                closeAdminModal();
                enableAdminEditMode();
            } else {
                sound.playWrong();
                document.getElementById('adminErrorMsg').classList.remove('hidden');
            }
        }

        function enableAdminEditMode() {
            // Show Admin Banner & Badge
            document.getElementById('adminControlPanel').classList.remove('hidden');
            document.getElementById('adminBadge').classList.remove('hidden');
            document.getElementById('adminClearReflectionsBtn').classList.remove('hidden');

            // Update Admin Nav Button
            const adminBtn = document.getElementById('adminNavBtn');
            adminBtn.className = 'px-3 py-1.5 rounded-lg text-xs md:text-sm font-semibold bg-emerald-500/20 text-emerald-400 border border-emerald-500/40 transition flex items-center gap-2';
            adminBtn.innerHTML = `<i class="fa-solid fa-user-check text-emerald-400"></i><span class="hidden sm:inline">Admin Active</span>`;

            // Make text areas editable
            makeElementsEditable(true);

            // Confetti effect for successful admin login
            confetti({ particleCount: 50, spread: 50, origin: { y: 0.2 } });
            renderReflections();
        }

        function lockAdminMode() {
            sound.playClick();
            isAdminLoggedIn = false;

            // Hide Admin Panels
            document.getElementById('adminControlPanel').classList.add('hidden');
            document.getElementById('adminBadge').classList.add('hidden');
            document.getElementById('adminClearReflectionsBtn').classList.add('hidden');

            // Reset Nav Button
            const adminBtn = document.getElementById('adminNavBtn');
            adminBtn.className = 'px-3 py-1.5 rounded-lg text-xs md:text-sm font-semibold bg-amber-500/10 hover:bg-amber-500/20 text-amber-400 transition flex items-center gap-2 border border-amber-500/30';
            adminBtn.innerHTML = `<i class="fa-solid fa-user-gear text-amber-400"></i><span class="hidden sm:inline">Admin</span>`;

            makeElementsEditable(false);
            renderReflections();
        }

        function makeElementsEditable(editable) {
            const editables = ['editableHeroTopic', 'editableHeroDesc', 'targetDesc1', 'targetDesc2', 'targetDesc3'];
            editables.forEach(id => {
                const el = document.getElementById(id);
                if (el) {
                    el.contentEditable = editable;
                    if (editable) {
                        el.classList.add('ring-2', 'ring-amber-500/60', 'p-1', 'rounded');
                    } else {
                        el.classList.remove('ring-2', 'ring-amber-500/60', 'p-1', 'rounded');
                    }
                }
            });
        }

        function saveAdminChanges() {
            sound.playVictory();
            alert("Perubahan media pembelajaran berhasil disimpan!");
        }

        // SPA NAVIGATION LOGIC
        function switchSection(sectionId) {
            sound.playClick();
            const sections = ['hero', 'tujuan', 'pemantik', 'materi', 'kuis', 'game', 'refleksi'];
            sections.forEach(sec => {
                const el = document.getElementById(`sec-${sec}`);
                if (el) el.classList.add('hidden');
            });

            const activeSec = document.getElementById(`sec-${sectionId}`);
            if (activeSec) {
                activeSec.classList.remove('hidden');
            }

            // Update active nav style
            document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.remove('active'));
            if (sectionId === 'hero') {
                document.getElementById('navBtnHero').classList.add('active');
            }

            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        // AUDIO TOGGLE LOGIC
        function toggleSound() {
            const isMuted = sound.toggleMute();
            const icon = document.getElementById('soundIcon');
            const text = document.getElementById('soundText');
            
            if (isMuted) {
                icon.className = 'fa-solid fa-volume-xmark text-slate-500';
                text.innerText = 'Suara: OFF';
            } else {
                icon.className = 'fa-solid fa-volume-high text-blue-400';
                text.innerText = 'Suara: ON';
                sound.playClick();
            }
        }

        // FLIP CARD LOGIC
        function toggleFlip(cardEl) {
            sound.playClick();
            cardEl.classList.toggle('flipped');
        }

        // SUBTAB MATERI LOGIC
        function switchSubTab(tabId) {
            sound.playClick();
            const tabs = ['tab1', 'tab2', 'tab3', 'tab-simulasi'];
            tabs.forEach(t => {
                const btn = document.getElementById(`btn-${t}`);
                const content = document.getElementById(`subtab-${t}`);
                if (btn) btn.classList.remove('active');
                if (content) content.classList.add('hidden');
            });

            const activeBtn = document.getElementById(`btn-${tabId}`);
            const activeContent = document.getElementById(`subtab-${tabId}`);
            if (activeBtn) activeBtn.classList.add('active');
            if (activeContent) activeContent.classList.remove('hidden');
        }

        // SIMULATION 1 LOGIC (GARIS BILANGAN & TERMOMETER)
        function updateSim(val) {
            const num = parseInt(val, 10);
            document.getElementById('simSlider').value = num;
            document.getElementById('simNumberInput').value = num;

            const percent = ((num + 10) / 20) * 100;
            const pointer = document.getElementById('simPointer');
            const badge = document.getElementById('simBadge');
            
            pointer.style.left = `${percent}%`;
            badge.innerText = num > 0 ? `+${num}` : `${num}`;

            // Update Thermometer Graphic
            const thermoPercent = ((num + 10) / 20) * 100;
            const fill = document.getElementById('thermoFill');
            const thermoText = document.getElementById('thermoText');
            fill.style.height = `${thermoPercent}%`;
            thermoText.innerText = `${num}°C`;

            // Update Context Text
            const title = document.getElementById('simContextTitle');
            const desc = document.getElementById('simContextDesc');

            if (num > 0) {
                fill.className = 'w-full bg-emerald-500 transition-all duration-300';
                badge.className = 'px-2 py-1 bg-emerald-600 text-white font-extrabold text-xs rounded shadow-lg mb-1';
                title.innerText = 'Bilangan Positif (+)';
                title.className = 'font-bold text-emerald-400';
                desc.innerText = `Nilai ${num} berada di sebelah kanan titik acuan 0. Menyatakan suhu di atas pembekuan.`;
            } else if (num < 0) {
                fill.className = 'w-full bg-rose-500 transition-all duration-300';
                badge.className = 'px-2 py-1 bg-rose-600 text-white font-extrabold text-xs rounded shadow-lg mb-1';
                title.innerText = 'Bilangan Negatif (-)';
                title.className = 'font-bold text-rose-400';
                desc.innerText = `Nilai ${num} berada di sebelah kiri titik acuan 0. Menyatakan suhu di bawah pembekuan.`;
            } else {
                fill.className = 'w-full bg-blue-500 transition-all duration-300';
                badge.className = 'px-2 py-1 bg-blue-600 text-white font-extrabold text-xs rounded shadow-lg mb-1';
                title.innerText = 'Titik Acuan (Nol)';
                title.className = 'font-bold text-blue-400';
                desc.innerText = 'Berada tepat di posisi netral (bukan positif maupun negatif).';
            }
        }

        // SIMULATION 2 LOGIC (NUMBER COMPARATOR)
        function compareNumbers() {
            const a = parseInt(document.getElementById('compA').value || 0, 10);
            const b = parseInt(document.getElementById('compB').value || 0, 10);
            const symbolEl = document.getElementById('compSymbol');
            const feedbackEl = document.getElementById('compFeedback');

            if (a > b) {
                symbolEl.innerText = '>';
                symbolEl.className = 'text-4xl font-extrabold text-emerald-400 py-2';
                feedbackEl.innerHTML = `<strong class="text-emerald-400">${a}</strong> lebih besar daripada <strong class="text-rose-400">${b}</strong> karena posisinya lebih di sebelah kanan pada garis bilangan.`;
            } else if (a < b) {
                symbolEl.innerText = '<';
                symbolEl.className = 'text-4xl font-extrabold text-rose-400 py-2';
                feedbackEl.innerHTML = `<strong class="text-rose-400">${a}</strong> lebih kecil daripada <strong class="text-emerald-400">${b}</strong> karena posisinya lebih di sebelah kiri pada garis bilangan.`;
            } else {
                symbolEl.innerText = '=';
                symbolEl.className = 'text-4xl font-extrabold text-blue-400 py-2';
                feedbackEl.innerHTML = `Kedua bilangan bernilai <strong class="text-blue-400">Sama Besar (${a} = ${b})</strong>.`;
            }
        }

        // QUIZ DATA & ENGINE
        const quizData = [
            {
                q: "Manakah penulisan matematis yang tepat untuk menyatakan suhu 8 derajat Celsius di bawah nol?",
                options: ["+8°C", "-8°C", "0°C", "80°C"],
                ans: 1,
                exp: "Suhu di bawah titik acuan nol selalu dinyatakan menggunakan tanda negatif (–), sehingga ditulis -8°C."
            },
            {
                q: "Sebuah kapal selam berada di kedalaman 15 meter di bawah permukaan laut. Jika permukaan laut dinamakan titik 0, posisi kapal selam berada di...",
                options: ["+15 m", "0 m", "-15 m", "150 m"],
                ans: 2,
                exp: "Kedalaman di bawah permukaan laut (titik acuan 0) bernilai negatif, yaitu -15 meter."
            },
            {
                q: "Manakah di antara bilangan berikut yang nilainya PALING BESAR?",
                options: ["-12", "-5", "0", "+3"],
                ans: 3,
                exp: "Bilangan positif (+3) selalu lebih besar daripada bilangan 0 dan bilangan negatif."
            },
            {
                q: "Bandingkan dua bilangan berikut: -10 ... -2. Simbol perbandingan yang paling tepat adalah...",
                options: [">", "<", "=", "≥"],
                ans: 1,
                exp: "-10 terletak lebih jauh di sebelah kiri daripada -2 pada garis bilangan, sehingga -10 < -2."
            },
            {
                q: "Pada garis bilangan horizontal, posisi bilangan negatif selalu berada di sebelah...",
                options: ["Kanan titik nol", "Kiri titik nol", "Atas titik nol", "Bawah titik nol"],
                ans: 1,
                exp: "Berdasarkan kesepakatan garis bilangan, bilangan negatif selalu berada di sebelah kiri titik nol."
            },
            {
                q: "Pedagang mengalami kerugian sebesar Rp5.000,00. Pernyataan ini jika ditulis dalam bilangan bulat adalah...",
                options: ["+5.000", "-5.000", "0", "50.000"],
                ans: 1,
                exp: "Kerugian bernilai negatif (-), sedangkan keuntungan bernilai positif (+)."
            },
            {
                q: "Urutkan bilangan berikut dari yang TERKECIL ke terbesar: -4, 2, -1, 0",
                options: ["-4, -1, 0, 2", "2, 0, -1, -4", "-1, -4, 0, 2", "0, -1, 2, -4"],
                ans: 0,
                exp: "Urutan dari paling kiri (terkecil) pada garis bilangan adalah -4, kemudian -1, 0, dan paling kanan adalah 2."
            },
            {
                q: "Pernyataan berikut yang bernilai BENAR adalah...",
                options: ["-5 > +2", "-8 > -3", "-1 < 0", "0 < -10"],
                ans: 2,
                exp: "-1 terletak di sebelah kiri 0, sehingga -1 < 0 bernilai benar."
            },
            {
                q: "Antok melangkah 6 langkah ke belakang dari titik awal (0). Posisi Antok sekarang dapat dituliskan sebagai...",
                options: ["+6", "-6", "0", "+12"],
                ans: 1,
                exp: "Maju bernilai positif (+), sedangkan mundur / ke belakang bernilai negatif (-)."
            },
            {
                q: "Antara bilangan -7 dan -3, manakah bilangan yang letaknya lebih dekat ke titik nol?",
                options: ["-7", "-3", "Kedua-duanya sama", "Tidak bisa ditentukan"],
                ans: 1,
                exp: "Jarak -3 ke nol adalah 3 langkah, sedangkan jarak -7 ke nol adalah 7 langkah. Jadi -3 lebih dekat ke nol."
            }
        ];

        let currentQIdx = 0;
        let userScore = 0;
        let answered = false;

        function loadQuestion() {
            answered = false;
            const q = quizData[currentQIdx];
            
            document.getElementById('quizProgressNum').innerText = `Soal ${currentQIdx + 1} dari ${quizData.length}`;
            document.getElementById('quizProgressPercent').innerText = `${((currentQIdx + 1) / quizData.length) * 100}% Selesai`;
            document.getElementById('quizProgressBar').style.width = `${((currentQIdx + 1) / quizData.length) * 100}%`;
            document.getElementById('quizQuestionText').innerText = `${currentQIdx + 1}. ${q.q}`;
            
            const optionsContainer = document.getElementById('quizOptionsContainer');
            optionsContainer.innerHTML = '';
            
            document.getElementById('quizExplanationBox').classList.add('hidden');
            document.getElementById('quizNextBtn').classList.add('hidden');

            q.options.forEach((opt, idx) => {
                const btn = document.createElement('button');
                btn.className = 'w-full p-4 rounded-xl glass-card text-left text-sm font-semibold text-slate-200 hover:border-blue-500 transition flex items-center gap-3';
                btn.innerHTML = `<span class="w-7 h-7 rounded-lg bg-slate-800 border border-slate-700 flex items-center justify-center text-xs font-bold text-blue-400">${String.fromCharCode(65 + idx)}</span> <span>${opt}</span>`;
                btn.onclick = () => checkAnswer(idx, btn);
                optionsContainer.appendChild(btn);
            });
        }

        function checkAnswer(selectedIdx, btnEl) {
            if (answered) return;
            answered = true;

            const q = quizData[currentQIdx];
            const optionsBtns = document.getElementById('quizOptionsContainer').children;
            const expBox = document.getElementById('quizExplanationBox');
            const expStatus = document.getElementById('quizResultStatus');
            const expText = document.getElementById('quizExplanationText');

            if (selectedIdx === q.ans) {
                sound.playCorrect();
                btnEl.classList.add('border-emerald-500', 'bg-emerald-950/40');
                userScore += 10;
                document.getElementById('quizScoreText').innerText = `${userScore} / 100`;
                expStatus.innerText = '✓ Jawaban Tepat!';
                expStatus.className = 'font-bold text-sm text-emerald-400';
            } else {
                sound.playWrong();
                btnEl.classList.add('border-rose-500', 'bg-rose-950/40');
                optionsBtns[q.ans].classList.add('border-emerald-500', 'bg-emerald-950/20');
                expStatus.innerText = '✕ Jawaban Kurang Tepat';
                expStatus.className = 'font-bold text-sm text-rose-400';
            }

            expText.innerText = q.exp;
            expBox.classList.remove('hidden');
            document.getElementById('quizNextBtn').classList.remove('hidden');
        }

        function nextQuestion() {
            sound.playClick();
            currentQIdx++;
            if (currentQIdx < quizData.length) {
                loadQuestion();
            } else {
                showQuizResult();
            }
        }

        function showQuizResult() {
            document.getElementById('quizContainer').classList.add('hidden');
            const resultSummary = document.getElementById('quizResultSummary');
            resultSummary.classList.remove('hidden');

            document.getElementById('finalScoreVal').innerText = userScore;
            const pred = document.getElementById('finalScorePredicate');

            if (userScore >= 80) {
                sound.playVictory();
                confetti({ particleCount: 100, spread: 70, origin: { y: 0.6 } });
                pred.innerText = 'Luar Biasa! Kamu Sangat Memahami Materi Bilangan Bulat 🎉';
            } else if (userScore >= 60) {
                pred.innerText = 'Bagus! Kamu Sudah Memahami Sebagian Besar Konsep 👍';
            } else {
                pred.innerText = 'Tetap Semangat! Pelajari Kembali Materi & Pelatihan Simulasi 😃';
            }
        }

        function resetQuiz() {
            sound.playClick();
            currentQIdx = 0;
            userScore = 0;
            document.getElementById('quizScoreText').innerText = '0 / 100';
            document.getElementById('quizResultSummary').classList.add('hidden');
            document.getElementById('quizContainer').classList.remove('hidden');
            loadQuestion();
        }

        // MINI GAME LOGIC (SORTING)
        const initialCards = [
            { id: 1, text: "Suhu -5°C", type: "negative" },
            { id: 2, text: "Ketinggian +100m", type: "positive" },
            { id: 3, text: "Rugi Rp5.000", type: "negative" },
            { id: 4, text: "Laba Rp10.000", type: "positive" },
            { id: 5, text: "-12", type: "negative" },
            { id: 6, text: "+8", type: "positive" },
            { id: 7, text: "Kedalaman 15m", type: "negative" },
            { id: 8, text: "Maju 4 Langkah", type: "positive" }
        ];

        let selectedCardId = null;

        function initGame() {
            const pool = document.getElementById('gameCardPool');
            const pos = document.getElementById('containerPositive');
            const neg = document.getElementById('containerNegative');
            
            pool.innerHTML = '';
            pos.innerHTML = '';
            neg.innerHTML = '';

            document.getElementById('countPositive').innerText = '0 Kartu';
            document.getElementById('countNegative').innerText = '0 Kartu';

            initialCards.forEach(card => {
                const el = document.createElement('div');
                el.className = 'px-3 py-2 bg-slate-800 border border-slate-700 rounded-xl text-xs font-bold text-slate-200 cursor-grab active:cursor-grabbing hover:border-purple-500 transition shadow-md select-none';
                el.innerText = card.text;
                el.draggable = true;
                el.id = `card-${card.id}`;
                el.setAttribute('data-type', card.type);

                el.onclick = () => selectCardForTap(card.id, el);

                el.ondragstart = (e) => {
                    e.dataTransfer.setData('text/plain', card.id);
                };

                pool.appendChild(el);
            });
        }

        function selectCardForTap(id, el) {
            sound.playClick();
            if (selectedCardId === id) {
                selectedCardId = null;
                el.classList.remove('ring-2', 'ring-purple-500');
            } else {
                document.querySelectorAll('#gameCardPool div').forEach(c => c.classList.remove('ring-2', 'ring-purple-500'));
                selectedCardId = id;
                el.classList.add('ring-2', 'ring-purple-500');
            }
        }

        function allowDrop(ev) {
            ev.preventDefault();
        }

        function handleDrop(ev, category) {
            ev.preventDefault();
            const cardId = ev.dataTransfer.getData('text/plain') || selectedCardId;
            if (!cardId) return;

            placeCard(cardId, category);
        }

        function placeCard(cardId, category) {
            sound.playClick();
            const cardEl = document.getElementById(`card-${cardId}`);
            if (!cardEl) return;

            cardEl.classList.remove('ring-2', 'ring-purple-500');
            selectedCardId = null;

            if (category === 'positive') {
                document.getElementById('containerPositive').appendChild(cardEl);
            } else {
                document.getElementById('containerNegative').appendChild(cardEl);
            }

            updateGameCounts();
        }

        document.getElementById('dropPositiv').onclick = () => {
            if (selectedCardId) placeCard(selectedCardId, 'positive');
        };
        document.getElementById('dropNegativ').onclick = () => {
            if (selectedCardId) placeCard(selectedCardId, 'negative');
        };

        function updateGameCounts() {
            const posCount = document.getElementById('containerPositive').children.length;
            const negCount = document.getElementById('containerNegative').children.length;

            document.getElementById('countPositive').innerText = `${posCount} Kartu`;
            document.getElementById('countNegative').innerText = `${negCount} Kartu`;
        }

        function validateGame() {
            const posContainer = document.getElementById('containerPositive').children;
            const negContainer = document.getElementById('containerNegative').children;

            let correct = 0;
            let total = initialCards.length;

            for (let card of posContainer) {
                if (card.getAttribute('data-type') === 'positive') correct++;
            }
            for (let card of negContainer) {
                if (card.getAttribute('data-type') === 'negative') correct++;
            }

            if (correct === total) {
                sound.playVictory();
                confetti({ particleCount: 80, spread: 60, origin: { y: 0.6 } });
                alert(`Luar Biasa! Semua kartu (${correct}/${total}) berhasil diklasifikasikan dengan tepat! 🎉`);
            } else {
                sound.playWrong();
                alert(`Kamu berhasil menempatkan ${correct} dari ${total} kartu dengan benar. Periksa kembali kartu kamu! 👍`);
            }
        }

        function resetGame() {
            sound.playClick();
            initGame();
        }

        // REFLECTION STICKY NOTES LOGIC
        let defaultReflections = [
            { id: 1, name: "Siti Rahma", emoji: "😃 Sangat Paham", msg: "Simulasi termometer membantu banget paham letak suhu di bawah nol!", color: "from-blue-900/60 to-slate-900" },
            { id: 2, name: "Rizky", emoji: "🚀 Sangat Seru!", msg: "Ternyata membandingkan bilangan negatif itu kebalikannya positif ya!", color: "from-indigo-900/60 to-slate-900" }
        ];

        function renderReflections() {
            const board = document.getElementById('stickyBoard');
            board.innerHTML = '';

            defaultReflections.forEach((item) => {
                const note = document.createElement('div');
                note.className = `p-4 rounded-2xl bg-gradient-to-br ${item.color} border border-slate-700/80 shadow-lg space-y-2 flex flex-col justify-between relative group`;
                note.innerHTML = `
                    <div class="space-y-1">
                        <div class="flex items-center justify-between gap-2">
                            <span class="font-bold text-sm text-white">${item.name}</span>
                            <span class="text-xs px-2 py-0.5 rounded-full bg-slate-800 text-blue-300 border border-slate-700">${item.emoji}</span>
                        </div>
                        <p class="text-xs text-slate-300 leading-relaxed pt-1">"${item.msg}"</p>
                    </div>
                    <div class="flex justify-between items-center text-[10px] text-slate-500 pt-2 border-t border-slate-800/80">
                        <span>Sticky Note Virtual</span>
                        ${isAdminLoggedIn ? `<button onclick="deleteReflection(${item.id})" class="text-rose-400 hover:text-rose-300 font-bold transition flex items-center gap-1"><i class="fa-solid fa-trash"></i> Hapus</button>` : ''}
                    </div>
                `;
                board.appendChild(note);
            });
        }

        function deleteReflection(id) {
            sound.playClick();
            defaultReflections = defaultReflections.filter(r => r.id !== id);
            renderReflections();
        }

        function clearAllReflections() {
            if (confirm("Apakah Anda yakin ingin menghapus seluruh sticky notes?")) {
                sound.playClick();
                defaultReflections = [];
                renderReflections();
            }
        }

        function addReflection() {
            const name = document.getElementById('refName').value.trim();
            const emoji = document.getElementById('refEmoji').value;
            const msg = document.getElementById('refMessage').value.trim();

            if (!name || !msg) {
                alert('Silakan isi Nama dan Pesan Refleksi terlebih dahulu!');
                return;
            }

            sound.playClick();
            defaultReflections.unshift({
                id: Date.now(),
                name: name,
                emoji: emoji,
                msg: msg,
                color: "from-purple-900/60 to-slate-900"
            });

            document.getElementById('refName').value = '';
            document.getElementById('refMessage').value = '';

            renderReflections();
        }

        // INITIALIZATION ON WINDOW LOAD
        window.onload = function () {
            updateSim(0);
            compareNumbers();
            loadQuestion();
            initGame();
            renderReflections();
        };
    </script>
</body>
</html>
