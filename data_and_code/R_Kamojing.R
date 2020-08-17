# remove list history
rm(list=ls())

# set working directory : ctrl+shift+h <<<<--Penting!

###----------------------settingan awal---------------###

# load library
library(ggplot2)
library(dplyr)
library(extremeStat)
library(lubridate)
library(hydroTSM)
library(plotly)

# jenis data debit atau curah hujan?
dbt <- "Debit"
hjn <- "Hujan"
dbt_title <- expression("Debit Harian"~(m^3/dtk))
dbt_labs <- expression("Debit"~(m^3/dtk))
hjn_title <- "Nilai Curah Hujan (mm)"
hjn_labs <- "Curah Hujan (mm)"

jenis_data <- hjn        # rubah sesuai jenis data yang ada, hujan atau debit?
judul_data <- hjn_title  # rubah sesuai jenis data yang ada, hujan atau debit?
judul_label <- hjn_labs  # rubah sesuai jenis data yang ada, hujan atau debit?


nama_pos <- "Stasiun Hujan Cisomang"

# 1. import data
data <- read.csv("sta_cisomang.csv")
names(data) <- c("Tanggal",jenis_data)

###----------------------settingan awal---------------###

# 1.1 filter to only data with values.
data <- subset(data,data[,2] != "-") 

# filter hanya di dua kolom pertama
data <- data[,1:2]

View(data)
str(data)

# 2. change format numbering instead of factor.
data$Tanggal <- as.Date(data[,1],format="%d-%b-%y") #cek format tanggal dari data original.
data[,2] <- as.numeric(as.character(data[,2])) #JANGAN LUPA as.character.

# 3. create a summary.
summary(data)

# 4. create a line plot of the data
g <- ggplot(data,aes(x=Tanggal, y=Hujan))+geom_line(col="blue3") + 
  labs(title=judul_data,subtitle = nama_pos,x = "Waktu",y=judul_label) +
  theme_update(plot.title=element_text(hjust=0.5))+
  theme_update(plot.subtitle=element_text(hjust=0.5))+
  theme_update(axis.title.y=element_text(angle=90))
g 



ggplotly(g)

# tandai data maksimum dan minimum
index_max <- data[,2] == max(data[,2])
index_min <- data[,2] == min(data[,2])
max_min_plot <- ggplot(data,aes(x=Tanggal, y=data[,2]),label=jenis_data)+geom_line(color="blue3") + 
  labs(title=judul_data,subtitle = nama_pos,x = "Waktu",y=judul_label) +
  geom_point(data=data[index_max,],aes(Tanggal,Hujan,color="MAX"))+
  geom_point(data=data[index_min,],aes(Tanggal,Hujan,color="MIN"))+
  geom_text(aes(label=ifelse(Hujan==max(data$Hujan),as.character(Hujan),'')),hjust=-0.5,vjust=0.5)

max_min_plot  




# cari tanggal berapa dia maksimum?
data[index_max,]

# ?geom_text

# buat histogram, bisa dijadikan indikasi jenis distribusi, bell shaped = normal,
ggplot(data,aes(data[,2]))+geom_histogram(bins = 50,col="blue3")+ 
  labs(title="Histogram Data",subtitle = nama_pos,x = judul_data,y="Jumlah") 

# buat density plot, bisa dijadikan indikasi jenis distribusi, bell shaped = normal,
ggplot(data,aes(data[,2]))+geom_density(col="blue3")+ 
  labs(title="Density Curve",subtitle = nama_pos,x = judul_data,y="Probabilitas")



# xx. cari hujan rendah dan hujan extrem
# h_less_20 <- data[data$Debit <= 20,][,2]
# h_less_20
# a <- length(h_less_20) 
# b <- length(data$Debit)
# a/b
# ch_kurang_20 <- data %>% filter(Debit <= 20) %>% summarise(Hujan_Ringan = length(Debit))
# ch_kurang_20
# Persentase <- (ch_kurang_20/b)*100
# Persentase

# buat grafik time series data dengan ggplot
library(lubridate)

## tambah kolom hari, tahun, bulan
data$DOY <- as.numeric(yday(data$Tanggal))
data$YEAR <- as.numeric(format(data$Tanggal,"%Y"))
data$MONTH <- as.numeric(format(data$Tanggal,"%m"))

## plot overlaped years
ggplot(data,aes(x=DOY,y=data[,2],group=YEAR))+geom_line()

## plot overlapeped years in different color
ggplot(data,aes(x=DOY,y=data[,2],group=YEAR,col=YEAR))+geom_line()

## create mean per day
mean_data <- aggregate(data[jenis_data],list(data$DOY),mean)

## add DOY and YEAR columns
mean_data <- cbind(DOY=seq(1:366),YEAR=2018,mean_data)

## plot overlaped years with mean per DOY
ggplot(data,aes(x=DOY,y=Hujan,col=YEAR,group=YEAR))+
  geom_line()+geom_line(data=mean_data,size=2,color="purple")+
  labs(title=judul_data,subtitle = nama_pos,x = "Waktu",y=judul_label)

## plot smoothed curve with span=0.3
qplot(x=mean_data$DOY,y=mean_data$Hujan,
      main = c("Rata-Rata",judul_data),
      ylab = judul_label,
      xlab = "Waktu (Hari)")+geom_smooth(span=0.3)

# View(mean_data)

## export hasil ke csv 
## write.csv(mean_data,file = "mean_data.csv")


# buat boxplot dengan ggplot

ggplot(data,aes(x=YEAR,y=Hujan,group=YEAR,col=YEAR))+geom_boxplot()+
  labs(title=c("Box Plot"),subtitle = nama_pos,x = "Tahun",y=jenis_data)


## custom bandwidht histogram
## binwidth_ch <- 2*IQR(data$Debit)/(length(data$Debit)^(1/3))
## ggplot(data,aes(Debit))+geom_histogram(binwidth = bindwidth_ch)

# create a kernel density estimate
# ggplot(data,aes(Debit))+geom_density()

# create a histogram for each month
# ggplot(data,aes(Debit,group=MONTH,col=month.abb[MONTH]))+geom_density()

# buat matrixplot
zoo_rr_data <- zoo(data[,2],data$Tanggal)
sapply(zoo_rr_data, class)

smry(zoo_rr_data)

## jumlah tahun pengamatan
total_year_observation <- yip("1995-01-01", "2018-12-31", out.type = "nmbr") ## tanggal mulai dan akhir lihat di summary
total_year_observation

## ini tambahan, cari rata2 hujan harian per tahun
rata2pertahun <- daily2annual(zoo_rr_data, FUN=mean, na.rm=T)
rata2pertahun

## fungsi "annualfunction" -> curah hujan ditambahkan sesuai dengan panjang data.
## angka ini berarti nilai rata2 jumlah hujan per tahun.
rata2tahunan <- annualfunction(zoo_rr_data, FUN=sum, na.rm = T)/total_year_observation 
rata2tahunan

# extract total monthly precipitation
bulanan_zoo_rr_data <- daily2monthly(zoo_rr_data, FUN=sum, na.rm = T)
bulanan_rata2_zoo <- daily2monthly(zoo_rr_data, FUN=mean, na.rm = T)


# buat grafik boxplot, ini grafik standard. coba nanti ganti dengan ggplot.

# cmonth <- format(time(bulanan_zoo_rr_data),"%b")
# months <- factor(cmonth, levels=unique(cmonth),ordered=T)

# boxplot(coredata(bulanan_zoo_rr_data)~months,col="blue3", 
     #   main = "Jumlah Hujan Bulanan", 
     #   ylab = "Curah Hujan (mm)", Xlab = "Bulan")

# buat matrix hujan bulanan

mat <- matrix(bulanan_zoo_rr_data, ncol=12, byrow = T)
mat_rata2 <- matrix(bulanan_rata2_zoo, ncol=12, byrow = T)

# rename the matrix column as the 12 months
# and the matrix row as a unique time of data

colnames(mat) <- month.abb
rownames(mat) <- unique(format(time(bulanan_zoo_rr_data), "%Y"))

colnames(mat_rata2) <- month.abb
rownames(mat_rata2) <- unique(format(time(bulanan_rata2_zoo), "%Y"))

# load "lattice" and plotting matrixplot

library(lattice)
require(lattice)

# matrixplot untuk jumlah curah hujan
print(matrixplot(mat, ColorRamp = "Precipitation",
                 main="Jumlah Curah Hujan Bulanan Rata-Rata (mm)")) #ganti judul kalau data hujan.

# matrixplot untuk rata-rata curah hujan
print(matrixplot(mat_rata2, ColorRamp = "Precipitation",
                 main="Curah Hujan Bulanan Rata-Rata (mm)")) #ganti judul kalau data hujan.

### ?matrixplot

# buat summary grafik hidrologi

hydroplot(zoo_rr_data[,1], var.type = "Precipitation"
          , ptype = "ts+hist", main = nama_pos,
          pfreq = "dm", from="2009-01-01", ylab = "Data",var.unit = "flow")

### ?hydroplot

# Analisa Frekuensi

## maksimal tahun hidrologi (30 September - 1 Oktober)
# data$hydyear <- as.numeric(format(data$Tanggal+61, "%Y"))
# annmax <- tapply(data$Debit, data$hydyear, max, na.rm=TRUE)
# annmax <- annmax[-1]
# annmax
# str(annmax)
# hydyear <- as.numeric(names(annmax)) 
# plot(hydyear, annmax, type="o", las=1)

# dlf <- distLfit(annmax)
# plotLfit(dlf)
# plotLfit(dlf, cdf=TRUE)
# dle <- distLextreme(dlf=dlf, RPs=c(1.5,2,5,10,50,100,200,1000), gpd=F)
# plotLextreme(dle)

# plotLextreme(dle, nbest=4, log=TRUE,ylab="Curah Hujan (mm)",xlab="Kala Ulang",main="Analisa Frekuensi")

# dle$returnlev


## untuk periode waktu tahun normal (bukan tahun hidrologi)
data$normal <- as.numeric(format(data$Tanggal, "%Y"))
Data_Max_Harian <- tapply(data[,2],data$normal, max, na.rm=TRUE)


data_max <- as.numeric(names(Data_Max_Harian))
plot(data_max,Data_Max_Harian,type="o",las=1,col="blue3",ylab=judul_label,xlab="Tahun",
     main = c("Nilai Maksimum Harian",nama_pos))

dlf <- distLfit(Data_Max_Harian)
plotLfit(dlf,legend = T,col = "cyan4")
plotLfit(dlf, cdf=TRUE)
dle <- distLextreme(dlf=dlf, RPs=c(1.5,2,5,10,50,100,200,1000), gpd=F)
plotLextreme(dle)
plotLextreme(dle, nbest=5, log=TRUE,ylab=judul_label,xlab="Periode Kala Ulang (Tahun)",
             main=c("Analisa Frekuensi",nama_pos),legargs = list(cex=0.6,bg="transparent"))
dle$returnlev

## export hasil ke csv 
write.csv(dle$returnlev,file = "curah hujan atau debit Rencana.csv")


## mencari hasil uji outlier
data_max$log_x <- log10(data_max$Hujan_Max)

data_max_rata2 <- mean(data_max$Hujan_Max)

data_max_rata2

sd(data_max$Hujan_Max)

str(data_max)

data_max <- data_max[,1:2]

nilai_kn <- data_max$Hujan_Max

data_max$Hujan_Max



install.packages("expss")
library(expss)

jumlah_data <- count(data_max)

str(jumlah_data)

View(jumlah_data)

jumlah_data <- as.numeric(jumlah_data[1,1])

vlookup_df(jumlah_data,Uji_Outlier,result_column=2,
        lookup_column=1)

??vlookup
