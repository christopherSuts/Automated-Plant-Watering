# Automated Plant Watering

## i. Introduction to the Problem and the Solution

### Masalah utama
Pengelolaan air secara efisien dan ramah lingkungan menjadi semakin penting, terutama di tengah krisis air dan perubahan iklim. Salah satu kegiatan pengelolaan air yang di-highlight untuk tema proyek kali ini adalah penyiraman tanaman, yang pada umumnya dilakukan secara manual menggunakan selang air ataupun pot penyiram tanaman. Namun, penyiraman tanaman secara manual sering kali tidak efisien dan dapat menyebabkan masalah seperti pembusukan akar atau kekeringan, serta kurangnya perawatan akibat keterbatasan waktu.

### Solusi
Program "Automated Plant Watering" dirancang untuk mengatasi masalah ini dengan mengotomatisasi proses penyiraman berdasarkan tingkat kelembaban tanah. Alat ini memanfaatkan sensor dan mikrokontroler untuk memantau kelembaban tanah dan mengontrol pompa air untuk menyiram tanamannya sesuai dengan waktu yang ditentukan. Tujuan utama dari "Automated Plant Watering" ini adalah untuk memastikan kesehatan tanaman yang optimal serta meminimalisir terjadinya pemborosan air.

## ii. Hardware Design and Implementation Details
Gambar di bawah adalah skematik untuk rangkaian asli dari program "Automated Plant Watering" ini.
![Screenshot 2024-05-25 163105](https://github.com/christopherSuts/Automated-Plant-Watering/assets/144332036/fe2c9136-04c5-4155-9600-8af3b81f8b68)

Dalam rangkaian ini, kami menggunakan komponen-komponen sebagai berikut :
![Screenshot 2024-05-28 122350](https://github.com/christopherSuts/Automated-Plant-Watering/assets/144332036/477911d0-8bb8-4226-a453-22f0e804325e)

- Arduino Uno (ARD1 - master dan ARD2 - slave) : Penggunaan arduino memang sudah menjadi komponen dasar yang biasa digunakan pada rangkaian pemrograman dengan bahasa Assembly sebagai mikrokontroller yang akan mengontrol alur komunikasi alat dalam sistem. Peran kedua arduino itu merupakan implementasi dari modul I2C, yang memiliki konfigurasi master dan slave.
- DHT11 : Sensor DHT11 merupakan sensor yang digunakan untuk memeriksa dan mengukur tingkat kelembaban tanah.
- Relay (RL1) : Relay berfungsi sebagai switch elektronik yang diaktifkan oleh sinyal dari Arduino. Ketika kelembaban rendah (disini ambang batasnya jika dibawah 50% akan diaktifkan), Arduino mengirimkan sinyal ke relay untuk mengaktifkan pompa air, dan ketika kondisi sebaliknya, relay akan mematikan pompa dan akan mengaktifkan pompa berdasarkan timer.
- LCD 16x2 : Penggunaan LCD ini adalah pengimplementasian modul serial port, berguna untuk menampilkan data kelembaban tanah setelah diukur oleh sensor DHT11. 
- Resistor Pull-Up (R3 dan R4) : Resistor ini digunakan sebagai pull-up untuk jalur SDA dan SCL pada komunikasi I2C. Hal ini penting untuk memastikan bahwa jalur I2C berfungsi dengan baik.

## iii. Software Implementation Details
Program "Automated Plant Watering" overall dikontrol dengan sistem master dan slave yang menggunakan protokol I2C dan sensor DHT11 yang akan mengukur kelembaban tanah, lalu menjalankan water pump untuk menyiram tanaman tergantung pada time limit yang sudah ditentukan. Berikut adalah penjelasan lebih lengkap dari pengimplementasian master dan slave menggunakan flowchart sehingga alat penyiraman otomatis ini dapat bekerja.

![Screenshot 2024-05-26 182845](https://github.com/christopherSuts/Automated-Plant-Watering/assets/144332036/39307876-ecd5-4e04-98cc-cb71a94576bf) ![Screenshot 2024-05-26 182808](https://github.com/christopherSuts/Automated-Plant-Watering/assets/144332036/7a58aa0c-6572-401d-8ff7-58aef00917d9)

## iv. Test Results and Performance Evaluation

Hasil run rangkaian pada proteus : 

![Screenshot 2024-05-28 201444](https://github.com/christopherSuts/Automated-Plant-Watering/assets/144332036/4423b9c5-7bb5-4f9e-815e-1c0e03fc25cc)


Hasil run rangkaian fisik : 

![output lcd testing](https://github.com/christopherSuts/Automated-Plant-Watering/assets/144332036/641aeeaf-c221-42be-99e5-861679bfd412)

LCD pada rangkaian di Proteus dan rangkaian aslinya sudah memenuhi objektif pembuatan proyek ini, yaitu menampilkan tingkat kelembapan lingkungannya. Motor DC yang bekerja sebagai water pump pada rangkaian ini juga sudah dapat berjalan.

## v. Conclusion and Future Work
Program "Automated Plant Watering" merupakan solusi inovatif untuk pengelolaan penyiraman tanaman secara otomatis berdasarkan tingkat kelembapan, sehingga menghindari pembusukan akar atau kekeringan yang mengganggu produktivitas. Teknologi ini sangat membantu bagi mereka yang memiliki keterbatasan waktu dan masih ingin memastikan tanaman tetap terjaga dengan baik. Alat penyiraman otomatis ini menggunakan sensor DHT11, relay, dan dua Arduino (konfigurasi Master-Slave) untuk mengukur kelembapan, mengirim data, dan mengendalikan motor DC yang menjaga kelembapan lingkungan. Meski dikatakan cukup efektif, proyek ini memerlukan perbaikan pada delay rangkaian fisik dan penyesuaian sensor menjadi soil moisture sensor. Dengan perbaikan dan riset lebih lanjut, proyek ini dapat memberikan dampak positif yang lebih besar bagi sektor pertanian.
