# Food Classifier App

Aplikasi Flutter untuk mengidentifikasi makanan dari foto menggunakan model
machine learning on-device (TensorFlow Lite / LiteRT), dilengkapi halaman
detail hasil prediksi dengan resep dan estimasi nutrisi dari database resep lokal
(2.164 resep, fokus masakan Indonesia).

## Fitur

- **Pengambilan gambar** — foto langsung dari kamera atau pilih dari galeri
  (`image_picker`), lalu dipotong (`image_cropper`) sebelum dianalisis.
- **Klasifikasi ML on-device** — model `food_classifier.tflite` (AIY Vision
  Classifier - Food V1, 2024 kelas) dijalankan lewat `tflite_flutter`.
  Inferensi berjalan di background isolate (`IsolateInterpreter`) dan proses
  decode/resize gambar berjalan lewat `compute()`, sehingga UI tidak freeze.
- **Halaman prediksi** — menampilkan foto, nama makanan hasil deteksi,
  confidence score, estimasi nutrisi, serta bahan & langkah masak dari
  database resep lokal (`assets/data/local_recipes.json`) berdasarkan nama
  makanan hasil inferensi. Tidak butuh internet untuk data resep.
- **Estimasi nutrisi** — kalori, protein, karbohidrat, lemak, serat, gula,
  natrium, dan kolesterol per porsi. Nilainya ESTIMASI (berbasis aturan
  per jenis masakan), bukan data terukur. Lihat `NUTRITION_DATA.md`.
- **Riwayat scan** — setiap scan disimpan lokal (`shared_preferences`) untuk
  layar History, Nutrition, dan Profile (total harian, goals, streak).

## Struktur proyek

```
lib/
  main.dart                     # entry point + loading model
  models/
    food_prediction.dart        # hasil inferensi (label, confidence, image)
    meal.dart                   # model resep + Nutrition (estimasi per porsi)
  services/
    image_preprocessor.dart     # decode + resize gambar -> buffer uint8 192x192x3
    classifier_service.dart     # load model & jalankan inferensi via isolate
    local_recipe_service.dart   # cari resep & nutrisi dari asset lokal (+ alias label)
    scan_history_service.dart   # simpan scan, total harian, streak, goals
    mealdb_service.dart         # (lama, tidak dipakai lagi) MealDB search API
  screens/
    home_screen.dart            # ambil/pilih/crop gambar (Kriteria 1)
    result_screen.dart          # halaman prediksi (Kriteria 3)
    nutrition_detail_screen.dart # detail nutrisi & bahan
    recipe_screen.dart          # ide resep & resep lengkap
assets/
  data/local_recipes.json       # 2.164 resep + estimasi nutrisi per resep
  data/label_nutrition.json     # estimasi nutrisi per label (untuk label tanpa resep)
  models/food_classifier.tflite # model TFLite (~20MB)
  models/labels.txt             # 2024 label kelas (index sejajar output model)
  images/satay.jpg              # sampel gambar makanan untuk uji manual
```

## Cara menjalankan

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```

## Tentang model ML

Model diunduh dari Kaggle Models:
`google/aiy/tfLite/vision-classifier-food-v1`
(MobileNetV1 terkuantisasi, dilatih untuk mengenali 2023 jenis makanan +
1 kelas `__background__`).

- Input: `uint8 [1, 192, 192, 3]` — piksel RGB mentah 0–255, tanpa
  normalisasi tambahan (sudah termasuk dalam kuantisasi model).
- Output: `uint8 [1, 2024]` — didekuantisasi dengan `nilai / 256.0` untuk
  mendapatkan confidence score per kelas.
- `assets/models/labels.txt` berisi 2024 label yang urutannya sejajar
  (1:1) dengan index output model.

Label hasil inferensi sesekali berupa nama masakan yang sangat spesifik/
regional (mis. "Bazin", "Chaudin") yang tidak memiliki resep lokal — pada
kasus ini halaman prediksi tetap menampilkan hasil deteksi & confidence,
hanya bagian resep yang menampilkan pesan "tidak ditemukan", dan nutrisi
ditampilkan "-" bila tidak ada estimasi.

## Data resep & nutrisi

- Resep: dikumpulkan dari Cookpad Indonesia + resep kurasi manual
  (lihat `RECIPE_DATABASE_MIGRATION.md`).
- Nutrisi: estimasi per porsi, belum bersumber data resmi. Sebagian kecil
  label (~16% dari 2.023) punya nutrisi. Versi bersumber (USDA FoodData
  Central + TKPI) sedang disiapkan untuk paper. Detail di `NUTRITION_DATA.md`.

