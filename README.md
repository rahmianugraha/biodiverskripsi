# Repositori ini berisi langkah-langkah untuk melakukan cleaning data pada kumpulan transkripsi dari project Biodiverskripsi.

Terdapat 3 folder:
1. input_xlsx: berisi data keseluruhan transkripsi yang masih raw (berbentuk xlsx dan xls)
2. output_csv: berisi data keseluruhan transkripsi yang sudah dipisahkan per sheet (berbentuk csv)
3. output_figure: berisi gambar grafik hasil dari visualisasi data (berbentuk png)

# Sebelum memulai, install packages:
1. rio
2. tidyverse
3. car
4. writexl
5. stringr
6. openxlsx

# Convert xls & xlsx to csv
regex_xls: Membaca semua file dengan format xls dan xlsx
xls: Dataframe berisi semua file yang terbaca oleh regex_xls yang berada di dalam folder input_xlsx

# Split all csv (Sheet 1)
Dataframe: bio_data1
Mengambil hanya sheet 1 pada setiap file di dalam folder input_xlsx
Convert menjadi csv
Hasilnya berada di folder output_csv

# Split all csv (Sheet 2)
Dataframe: bio_data2
Mengambil hanya sheet 2 pada setiap file di dalam folder input_xlsx
Convert menjadi csv
Hasilnya berada di folder output_csv

# TAKSA CLEANING
#IN -> FN
Mengubah IN menjadi FN pada occurrenceID
#AR -> TN
Mengubah AR menjadi TN pada occurrenceID

# PARENTEVENTID CLEANING
Mengecek parentEventID yang tidak sesuai format

# EVENTID CLEANING
Mengecek eventID yang tidak sesuai format
#Know the differences
Mengecek apakah ada eventID yang terdapat pada bio_data1 tetapi tidak ada pada bio_data2
Mengecek apakah ada eventID yang terdapat pada bio_data2 tetapi tidak ada pada bio_data1

# OCCURRENCEID CLEANING
Mengecek occurrenceID yang tidak sesuai format

# STATEPROVINCE CLEANING
Merecode typo pada penulisan stateProvince
Menyamaratakan istilah pada setiap provinsi

# Merged Sheet 1 & Sheet 2
Dataframe: merged_data
Menggabungkan sheet 1 dan sheet 2
#CHECK DUPLICATE
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
Dataframe: taksa_count
Mengetahui jumlah occurrence dari setiap taksa

# COUNT YEAR
Dataframe: year_count
Mengetahui jumlah occurrence dari setiap tahun

# COUNT UNIV
Dataframe: univ_count
Mengetahui jumlah occurrence dari setiap universitas

# SCIENTIFIC NAME DATA CLEANING
Mengecek format setiap tingkatan taksa yang tidak sesuai pattern
#Cleaning 1
Merecode scientific name yang mempunyai tanda kurung, spasi double, dan mempunyai tanda titik pada genus
#Cleaning 2
Merecode genus yang tidak tepat pada scientificName
#Cleaning 3
Menghapus sp, sp., sp ., Sp., dan spp. yang terletak di belakang genus pada scientificName
#Cleaning 4
Menghapus sp. tanpa spasi yang terletak di belakang genus pada scientificName
#Cleaning 5 dan 6
Menghapus kata ketiga pada scientificName yang diawali dengan huruf kapital
#Cleaning 7
Menghapus angka dan kata+angka pada scientificName
#Cleaning 8
Merecode jenis yang tidak teridentifikasi menjadi tingkatan kingdom
#Cleaning 11
Menghapus tanda -- di belakang genus pada scientificName
#Cleaning 12
Menghapus cf di tengah-tengah nama pada scientificName
#Cleaning 13
Merecode nama-nama yang typo pada scientificName dari dataset typo_lookup

# Write cleaned data to xlsx
Dataset: All Occurrences_19681_7 August.xlsx
Save hasil dari cleaning data dalam bentuk xlsx

# VISUALIZATION
(Semua figure hasilnya akan diexport ke dalam folder output_figure)

# Create + export barchart (TAXA)
Membuat barchart jumlah occurrence per taksa
# Create + export barchart (TAXA WITH YEAR)
Membuat barchart jumlah occurrence per taksa dari setiap tahun
# Create + export barchart (TAXA WITH LOCATION)
Membuat barchart jumlah occurrence per taksa dari setiap provinsi
# Create + export barchart (TAXA WITH UNIV)
Membuat barchart jumlah occurrence per taksa dari setiap universitas

# Create + export barchart (UNIV WITH TAXA)
Membuat barchart jumlah occurrence per universitas dari setiap taksa
# Create + export barchart (UNIV WITH YEAR)
Membuat barchart jumlah occurrence per universitas dari setiap tahun
# Create + export barchart (UNIV WITH LOCATION)
Membuat barchart jumlah occurrence per universitas dari setiap provinsi
