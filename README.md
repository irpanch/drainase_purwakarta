# Pivot project - RMarkdown-LaTex-Github

Percobaan pertama integrasi pembuatan laporan proyek dengan menggunakan RMarkdown dan bahasa latex. Didasari oleh blog yang dibuat Rosanna Van Hespen [disini](https://www.rosannavanhespen.nl/thesis_in_rmarkdown/) dan Dr. Alison Hale [disini](https://achale.gitlab.io/tutorialmarkdownthesis/).

## Kendala dan Solusi
1. Tidak bisa insert gambar di cover?  
   Gunakan package dari latex. Di YAML tambahkan:  
   ```
   header-includes: 
   \usepackage{graphicx}
   ```
   Lalu pada cover tambahkan code `\includegraphics{gambar/"lokasi dan nama gambar"}`  
2. Tambahkan header dan footer sesuai judul pekerjaan.  
   Pada bagian YAML di index tambahkan kode:
   ```
   header-includes:
   \usepackage{fancyhdr}
   ```  
   Kemudian masih di preamble, ketik kode:
   ```
   \pagestyle{fancy} <untuk merubah tipe dokumen dari plain ke fancy>

   \fancyhead[LE,RO]{}  <posisi ditengah untuk Even (genap), dan odd (ganjil)>
   \fancyhead[LO,RE]{} 
   \renewcommand{\headrulewidth}{0.4pt} <garis dibawah header>
   \renewcommand{\footrulewidth}{0.4pt} <garis dibawah footer>
   \fancyhead[CO,CE]{\scriptsize Abstract} <untuk ukuran font>
   ```   
   Itu untuk header, untuk footer juga sama:
   ```
    \fancyfoot{} <membersihkan header sebelumnya, supaya tidak double>
    \fancyfoot[L]{\scriptsize Perencanaan Drainase Kecamatan Purwakarta}
    \fancyfoot[RO,LE]{\scriptsize \thepage} 
   ```  
   Untuk lebih jelas mengenai aturan header dan footer di latex, bisa dilihat pada website [ini](https://texblog.org/2007/11/07/headerfooter-in-latex-with-fancyhdr/).

3. Tambah halaman baru dalam bentuk landscape.  
    Pada bagian YAML di index tambahkan kode:
   ```
   header-includes:
   \usepackage{pdflscape}
   ```
   Kemudian set halaman yang akan dijadikan landscape seperti ini:
    ```   
   \begin{landscape}
    
    {r, include=TRUE, echo=FALSE, message=FALSE, warning=FALSE, fig.height=5.2, fig.width=9.5, fig.align="center", fig.cap="petal versus septal width\\label{fig:figLand}"}
    plot(x=iris$Petal.Width, y=iris$Sepal.Width, xlab="petal", ylab="sepal")
    
    \end{landscape}
    ```  

4. Oke, halaman sudah landscape, sekarang cara header dan footer nya juga ikut landscape bagaimana?  
   **Belum Selesai**, Pelajari dari jawaban tex.stackexchange [disini](https://tex.stackexchange.com/questions/444913/how-do-i-rotate-a-header-and-footer-in-latex-landscape-page?rq=1).

5. Cara tulisan caption default dari latex? karena defaultnya masih "Figure.." Inginnya jadi "Gambar.." atau "Tabel..".  
**Terjawab**. Di file index tambahkan kode berikut

   ```
   \renewcommand{\tablename}{Tabel}
   \renewcommand{\figurename}{Gambar}
   ```
   
6. Sama dengan point 6, rubah tulisan default daftar isi, daftar gambar, dan daftar tabel. Karena defaultnya masih bahasa inggris. Kalau dipaksakan nantinya jadi ada double tulisan. Diatasnya "Content", dibawahnya "Daftar Isi"..  
   **Belum terjawab**  

7. Ingin buat folder baru yang terhubung dengan github? folder eksisting sudah ada.  
   **Terjawab**.  
   Caranya tidak sesimple buat folder baru di eksplorer atau RStudio, lalu pindahkan file, lalu push ke github. Karena dengan cara tersebut akan **error** (sudah coba 3x).  
   Yang benar adalah kita buat folder baru dulu di github, caranya bisa dilihat [disini](https://stackoverflow.com/questions/12258399/how-do-i-create-a-folder-in-a-github-repository) (harus ada filenya, kasih aja file keterangan). Lalu di RStudio baru kita **pull**. Baru kemudian bisa kita pindahkan file (cut) dan masukkan ke folder baru yang barusan di buat di github. Baru kita **push** kembali ke github. Dan bisa terkoneksi.
   
8. Antara bab 2 dan bab 3 kenapa tidak ada jarak halaman? padahal sudah coba pakai `\new page`, `\pagebreak`, `Floatbarrier`, baik di index maupun di akhir bab 2 dan awal bab 3 . Tetap tidak berhasil. Hadeuh.  
   **Terjawab**.  
   Jadi dibawah bab 2, paling akhir, harus ada text lagi. Jangan langsung jawaban. Baru nanti bisa misah