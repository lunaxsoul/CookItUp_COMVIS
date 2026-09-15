# Food Classifier App

Aplikasi Flutter untuk mengidentifikasi makanan dari foto menggunakan model
machine learning on-device (TensorFlow Lite / LiteRT), dilengkapi halaman
detail hasil prediksi dengan referensi resep dari MealDB API.

## Fitur

- **Pengambilan gambar** — foto langsung dari kamera atau pilih dari galeri
  (`image_picker`), lalu dipotong (`image_cropper`) sebelum dianalisis.
- **Klasifikasi ML on-device** — model `food_classifier.tflite` (AIY Vision
  Classifier - Food V1, 2024 kelas) dijalankan lewat `tflite_flutter`.
  Inferensi berjalan di background isolate (`IsolateInterpreter`) dan proses
  decode/resize gambar berjalan lewat `compute()`, sehingga UI tidak freeze.
- **Halaman prediksi** — menampilkan foto, nama makanan hasil deteksi,
  confidence score, serta bahan & langkah masak dari MealDB API
  (`search.php?s=`) berdasarkan nama makanan hasil inferensi.

## Struktur proyek

```
lib/
  main.dart                     # entry point + loading model
  models/
    food_prediction.dart        # hasil inferensi (label, confidence, image)
    meal.dart                   # model data MealDB
  services/
    image_preprocessor.dart     # decode + resize gambar -> buffer uint8 192x192x3
    classifier_service.dart     # load model & jalankan inferensi via isolate
    mealdb_service.dart         # panggil MealDB search API
  screens/
    home_screen.dart            # ambil/pilih/crop gambar (Kriteria 1)
    result_screen.dart          # halaman prediksi (Kriteria 3)
assets/
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

   Gunakan `assets/images/satay.jpg` untuk uji cepat lewat opsi "Galeri".

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
regional (mis. "Bazin", "Chaudin") yang mungkin tidak memiliki resep di
MealDB — pada kasus ini halaman prediksi tetap menampilkan hasil deteksi
& confidence, hanya bagian referensi resep yang menampilkan pesan "tidak
ditemukan".

