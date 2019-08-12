Repositori ini berisi langkah-langkah untuk melakukan cleaning data pada kumpulan transkripsi dari project Biodiverskripsi.

Terdapat 3 folder:
1. input_xlsx: berisi data keseluruhan transkripsi yang masih raw (berbentuk xlsx dan xls)
2. output_csv: berisi data keseluruhan transkripsi yang sudah dipisahkan per sheet (berbentuk csv)
3. output_figure: berisi gambar grafik hasil dari visualisasi data (berbentuk png)

Sebelum memulai, install packages:
1. rio
2. tidyverse
3. car
4. writexl
5. stringr
6. openxlsx

#Convert xls & xlsx to csv
regex_xls: Membaca semua file dengan format xls dan xlsx
xls: Dataframe berisi semua file yang terbaca oleh regex_xls yang berada di dalam folder input_xlsx

# Split all csv (Sheet 1)
-Dataframe: bio_data1
-Mengambil hanya sheet 1 pada setiap file di dalam folder input_xlsx
-Convert menjadi csv
-Hasilnya berada di folder output_csv

# Split all csv (Sheet 2)
-Dataframe: bio_data2
-Mengambil hanya sheet 2 pada setiap file di dalam folder input_xlsx
-Convert menjadi csv
-Hasilnya berada di folder output_csv

# TAKSA CLEANING
# IN -> FN
Mengubah IN menjadi FN pada occurrenceID
# AR -> TN
Mengubah AR menjadi TN pada occurrenceID

# PARENTEVENTID CLEANING
Mengecek parentEventID yang tidak sesuai format

# EVENTID CLEANING
Mengecek eventID yang tidak sesuai format
#Know the differences
-Mengecek apakah ada eventID yang terdapat pada bio_data1 tetapi tidak ada pada bio_data2
-Mengecek apakah ada eventID yang terdapat pada bio_data2 tetapi tidak ada pada bio_data1

# OCCURRENCEID CLEANING
Mengecek occurrenceID yang tidak sesuai format

# STATEPROVINCE CLEANING
-Merecode typo pada penulisan stateProvince
-Menyamaratakan istilah pada setiap provinsi

#Merged Sheet 1 & Sheet 2
-Dataframe: merged_data
-Menggabungkan sheet 1 dan sheet 2
# CHECK DUPLICATE
Mengecek dan meremove rows yang duplikat

#Bikin kolom baru kode taksa ke merged_data
taxaCode: Berisi code taksa yang diambil dari occurrenceID

#Bikin kolom baru tahun publikasi ke merged_data
publicationYear: Berisi tahun publikasi skripsi yang diambil dari occurrenceID

#Bikin kolom baru kode univ ke merged_data
univCode: Berisi code universitas yang diambil dari occurrenceID

#Delete all 2018 data
Meremove semua data dengan tahun publikasi 2018 (karena pembatasan hanya sampai tahun 2017)

# COUNT TAKSA
-Dataframe: taksa_count
-Mengetahui jumlah occurrence dari setiap taksa

# COUNT YEAR
-Dataframe: year_count
-Mengetahui jumlah occurrence dari setiap tahun

# COUNT UNIV
-Dataframe: univ_count
-Mengetahui jumlah occurrence dari setiap universitas
