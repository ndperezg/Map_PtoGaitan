#!/bin/bash
###########GMT DEFAULTS#########
#rm -rf gmt.*
#gmtset ANOT_FONT_SIZE 8
#gmtset LABEL_FONT_SIZE 8
#gmtset BASEMAP_TYPE plain
#gmtset PLOT_DEGREE_FORMAT DDD
gmtset PS_PAGE_ORIENTATION portrait
#-------------------------------
dias=$1 
dias_=$(($dias-10))
name=Pad78_unificado_$dias.ps
mfoc_file=mecanismos_magnitude.txt
#regions
pad6=-71.4/-71.25/3.8/3.89
pad4=-71.50/-71.41/3.72/3.78
pad5=-75/-70/2/5.5
Quifa=-71.61/-71.47/3.88/3.98
Rubiales=-71.65/-71.2/3.60/4.0
pad7=-71.42/-71.37/3.83/3.91
pad78=-71.45/-71.37/3.83/3.91
#colombia
bounds=-82.0/-67.0/-4.0/14.0
#Meta: region3

#cross section 1
lon1=-71.3 # -71.65 
lat1=3.83 # 3.88 
lon2=-71.3 #-71.4 
lat2=3.91 # 3.99

#cross section 2
Lon1=-71.34 # -71.65 
Lat1=3.830 # 3.88 
Lon2=-71.26 #-71.4 
Lat2=3.86 # 3.99

#options
contour=0
ilu=0
pads=0
pad_names=1
pozos=1
stations_PRE=0
names_PRE=0
stations_RSNC=0
stations_SUB=0
names_SUB=0
seismicity_PRE=1
seismicity_NEIC=0
seismicity_RSNC=0
cross_section_RSNC=0
cross_section_PRE=0
histogram=1
compare_locations=0
square=0
inset=0
legend=0
axes=0
mfoc=0
rubiales=0
image=1

#map parameters
region=$pad78
west=`echo $region | awk 'BEGIN {FS="/"};{print $1}'`
east=`echo $region | awk 'BEGIN {FS="/"};{print $2}'`
north=`echo $region | awk 'BEGIN {FS="/"};{print $3}'`
south=`echo $region | awk 'BEGIN {FS="/"};{print $4}'`

data=catalogo_nov2017_enero2018.out
topo=/Users/ndperezg/topo/Col250m_bat30s.grd
topoIlu=/Users/ndperezg/topo/Col250m_bat30s_int.grd
paleta=/Users/ndperezg/Documents/Ecopetrol/Map_PtoGaitan/coloibcaoNZ1_otra.cpt
paleta_SEIS=/Users/ndperezg/Documents/Ecopetrol/Map_PtoGaitan/depth.cpt
paleta_PRE=/Users/ndperezg/Documents/Ecopetrol/Map_PtoGaitan/prof_osso.cpt  #fecha25.cpt
POZOS=/Users/ndperezg/Documents/Ecopetrol/PADS/TODOS/
date=`awk -v dias=$dias '$3 > dias-1 &&  $3 <= dias {print $1}' $data | awk 'NR==1 {print}'`
#imagepath=/Users/ndperezg/Documents/Ecopetrol/NDP/PADS_Rubiales_graficas/Iny_Sismicidad/PAD_6
imagepath=/Users/ndperezg/Documents/Ecopetrol/Diario/Pad7
#GMT commands
psbasemap -Ba0.02f0.02SEWN:."Dia $dias  - $date ":  -JM13.5 -R$region     -X4.5 -Y11.5  -V -K > $name #0.2
#psbasemap -Ba0.02f0.02SEWN:."$date ($dias_ - $dias)":  -JM15.5 -R$region     -X4.5 -Y11.5  -V -K > $name #0.2
 if [ $ilu = 1 ] ; then
    grdimage $topo -C$paleta -B -J -I$topoIlu -R -V -O -K >> $name
else 
    grdimage $topo -C$paleta -B -J -R -V -O -K -P >> $name 
fi
if [ $contour = 1 ] ; then
	grdcontour $topo -B -J -C100 -R  -V -W0.08p,0/0/0 -GD10k -O -K>> $name
fi

pscoast -B -J -R$region  -Df   -Lf-71.40/3.62/2.4/10+l  -N2 -Gblack -S255   -V -O -P -K >> $name # -T-71.15/4.0/1.5 -Lf-71.3/3.78/3.6/5+l  #-P  

if [ $rubiales = 1 ]; then
    psxy rubiales.txt  -R -J -O -K -W1p,black >> $name
fi

if [ $seismicity_PRE = 1 ]; then
    awk -v dias=$dias '$3 < dias &&  $7 >= 1.5 {print $5, $4, -$6/1000}' $data | psxy -R -JM -Sc0.2  -C$paleta_PRE -W+  -O -K >> $name 
    #awk -v dias=$dias -v dias_=$dias_ '$3 >= dias_ && $3 < dias &&  $7 >= 1.5 {print $5, $4, -$6/1000}' $data | psxy -R -JM -Sc0.2  -C$paleta_PRE -W+  -O -K >> $name 
fi    

if [ $pozos = 1 ]; then
	for p in `ls $POZOS*.out`
	do
		awk '{print $1, $2}' $p | psxy  -R -J  -W3p,0/255/255  -O -P -K >> $name
	done 
fi


if [ $seismicity_NEIC = 1 ]; then
    awk 'BEGIN {FS=","};{if (NR>1) print $3, $2, $4, $5*0.1}' query_NEIC.csv | psxy -R -JM -Sc -W1/0 -C$paleta_SEIS -O -K >> $name 
fi


if [ $seismicity_RSNC = 1 ]; then
    awk '{print $1, $2, -$3, $4}' seismicity_RSNC.out |psxy -R -JM -Sc -W0.1p,black -C$paleta_SEIS -t50 -O -K >> $name    
fi

if [ $stations_PRE = 1 ]; then
	awk 'BEGIN {FS=","};{if (NR>1) print $7, $8}' camporubiales_stations.csv | psxy -R -J  -St0.36 -W0.2p,0/0/0 -G100/100/255 -P -O -K >> $name 
fi
if [ $axes = 1 ]; then
   awk '{print $5,$3, $18,5*cos(($19*1.5*3.141592653589793)/180)}' $mfoc_file >vectors.txt
   #awk '{print $13,$14, $8, 1.5}' paxes.txt >vectors.txt
   psxy vectors.txt -R -J -SV1+jc+p -Gblue  -W3,blue -O -K >>$name
   psxy vectors.txt -R -J -Sc0.15 -Gyellow  -W0.1p -O -K >>$name
fi


if [ $mfoc = 1 ]; then
    awk '$2 > 3.858 {print $1, $2, $3/1000, $5, $6, $7, $4}' $mfoc_file | psmeca -Sa1.5 -Gred  -Fp -R -J -O -K>> $name
fi

if [ $pads = 1 ]; then
	awk 'BEGIN {FS=","};{if (NR>1) print $2, $3}' CoordsPads.csv | psxy -R -J -Sd0.8 -W0.2p,0/0/0 -G0/255/255 -O -P -K >> $name 
	#awk 'BEGIN {FS=","};{if (NR>1) print $2+0.0099, $3, $1}' CoordsPads.csv | pstext -R -J -G  -F+f10p,15,black+jLB+a0 -O -P -K >> $name
fi
if [ $pad_names = 1 ]; then
    awk '{print $1, $2, $3}' pad_names.txt | pstext -R -J -G  -F+f10p,13,255/255/255+jLB+a0 -O -P -K >> $name 
fi

if [ $seismicity_PRE = 1 ]; then
    psscale -D17.0/5.0/3i/0.10ih -Ba2:"Depth (km)": -X-9 -Y-7.0 -K -C$paleta_PRE  -O >> $name
    psxy -R-70/-25/-10/-4 -Jm0.40 -O  escalaM.txt -Sc -W0.5 -X5.0 -Y3.1 -K >> $name  #bolitas
    pstext  -R-70/-55/-10/4 textoM.txt -Jm  -O -K -P -W,255/255/255  -X0.0 -Y0.0 -K >> $name #texto
fi

if [ $histogram = 1 ]; then
	gmtset FONT_ANNOT_PRIMARY 250p
	gmtset FONT_LABEL 250p
	awk -v dias=$dias '$3 < dias &&  $7 >= 1.5 {print -$6/1000}' $data | pshistogram -R-15/0/0/300 -Ba2f0.5:"Depth (km)":/a50f50:"Earthquakes":WesN  -JX250/125 -W0.5 -A -N -L2p -C$paleta_PRE -X400 -Y180  -P -K >> $name
	#awk -v dias=$dias -v dias_=$dias_ '$3 >= dias_ && $3 < dias &&  $7 >= 1.5 {print -$6/1000}' $data | pshistogram -R-15/0/0/50 -Ba2f0.5:"Depth (km)":/a10f10:"Earthquakes":WesN  -JX250/125 -W0.5 -A -N -L2p -C$paleta_PRE -X400 -Y150  -P -K >> $name
	gmtset FONT_ANNOT_PRIMARY 12p
	gmtset FONT_LABEL 12p
fi

if [ $image = 1 ]; then
	psimage $imagepath/Dia$dias.jpg -W4500c/0  -F -X-700 -Y-4200 >> $name
fi

if [ $stations_SUB = 1 ]; then
	psxy st_sub_PTG.txt -R -J  -St0.36 -W0.2p,0/0/0 -G0/255/255 -O -P -K >> $name
fi

if [ $stations_RSNC = 1 ]; then
	psxy nombres_RSNC.txt -R -J  -St0.36 -W0.2p,0/0/0 -G0/0/255 -O -P -K >> $name
	awk '{print $1+0.03, $2+0.0099, $7}' nombres_RSNC.txt | pstext -R -J -G -F+f10p,15,black+jLT+a0  -O -P -K  >> $name 
fi

if [ $names_SUB = 1 ]; then
    awk '{print $1+0.0099, $2, $3}' st_sub_PTG.txt | pstext -R -J -G -F+f10p,15,black+jLB+a0  -O -P -K >> $name 
fi
if [ $names_PRE = 1 ]; then
    awk 'BEGIN {FS=","};{if (NR>1) print $7+0.0099, $8, $1}' camporubiales_stations.csv | pstext -R -J -G  -F+f10p,15,black+jLB+a0 -O -P -K >> $name 
fi


if [ $compare_locations = 1 ]; then
    psxy  -R -J -O -K -W1p,black << END >> $name
$lon1 $lat1
$lon2 $lat2
END
    pstext -R -J -F+a0+f15p,Helvetica-Bold,black+jLB -O -K -P -G << EOF >> $name
$lon1+0.001 $lat1  A 
$lon2+0.001 $lat2  A'
EOF
    awk '{if (NR==8) print $5, $3,  0.2, $6, $4}' errores_SGC.out | psxy -R -J -Sc  -G255/0/0 -W1p,black  -O -K >> $name
    awk '{if (NR==8)print $5, $3,  0.2, $6, $4}' errores_RELOC.out | psxy -R -J -Sc  -G0/255/0 -W1p,black  -O -K >> $name
    awk '{if (NR==9) print $2, $3,  0.2, $6/1000, $7/1000}' errores_SPECTRA.out | psxy -R -J -Sc  -G0/0/255 -W1p,black  -O -K >> $name
    awk '{if (NR==8) print $3, $2, 0.2, $6, $7}' errores_NEIC.out | psxy -R -J -Sc -W1p,black -G255/255/0 -O -K >> $name
    awk '{if (NR==8) print $5, $3, 90, $6, $4}' errores_SGC.out | psxy -R -J -SE  -W0.5p,255/0/0  -O -K >> $name
    awk '{if (NR==8) print $5, $3, 90, $6, $4}' errores_RELOC.out | psxy -R -J -SE -W0.5p,0/255/0  -O -K >> $name
    awk '{if (NR==9) print $2, $3,  90, $6/1000, $7/1000}' errores_SPECTRA.out | psxy -R -J -SE  -W0.5,0/0/255 -O -K >> $name
    awk '{if (NR==8) print $3, $2, 0.2, $6, $7}' errores_NEIC.out | psxy -R -J -SE -W0.5p,255/255/0 -O -K >> $name
fi

if [ $compare_locations = 1 ]; then
     awk  '{if (NR==8) print $5, $3,  $7, $6, $4}' errores_SGC.out | pscoupe -Aa$lon1/$lat1/$lon2/$lat2/90/100/-1.5/40f -Jx0.20/-0.10 -R -Sa1 -Fsc0.3 -W  -G255/0/0 -O -K -L0.5p -B20/10WESn -X0.0 -Y-5.5 >> $name
     awk  '{if (NR==8)print $5, $3,  $4, $6, $4}' errores_RELOC.out | pscoupe -Aa$lon1/$lat1/$lon2/$lat2/90/100/-1.5/40f -Jx0.20/-0.10 -R -Sa1 -Fsc0.3 -W  -G0/255/0 -O -K  >> $name
     awk  '{if (NR==9) print $2, $3,  $7/1000, $6/1000, $7/1000}' errores_SPECTRA.out | pscoupe -Aa$lon1/$lat1/$lon2/$lat2/90/100/-1.5/40f -Jx0.20/-0.10 -R -Sa1 -Fsc0.3 -W  -G0/0/255 -O -K  >> $name
     awk  '{if (NR==8) print $3, $2, $4, $6, $7}' errores_NEIC.out | pscoupe -Aa$lon1/$lat1/$lon2/$lat2/90/100/-1.5/40f -Jx0.20/-0.10 -R -Sa1 -Fsc0.3 -W  -G255/255/0 -O -K  >> $name
fi

if [ $square = 1 ]; then 
    psxy cuadrado_spectraseis.txt -R -J -O -K -W0.8p,0/0/0 >> $name
fi


if [ $cross_section_RSNC = 1 ]; then
    psxy  -R -J -O -K -W1p,black << END >> $name
$lon1 $lat1
$lon2 $lat2
END
  
    pstext -R -J -O -K -P -G<< EOF >> $name
$lon1+0.001 $lat1 12 0 15 LB A 
$lon2+0.001 $lat2 12 0 15 LT A'
EOF
      awk '{print $1, $2, -$3, 0, 0, 0, $4}' seismicity_RSNC.out | pscoupe -Aa$lon1/$lat1/$lon2/$lat2/90/100/-1/30f -Jx0.15/-0.10 -R -Sa4p -Fsc -W  -Z$paleta_SEIS -O -K -L0.5p -B10/5WESn -X0.0 -Y-4.5 >> $name
fi


if [ $cross_section_PRE = 1 ]; then

    psxy  -R -J -O -K -W1.5p,white << END >> $name
$lon1 $lat1
$lon2 $lat2
END
    pstext -R -J -O -K -P -G<< EOF >> $name
$lon1+0.001 $lat1 12 0 15 LB A 
$lon2+0.001 $lat2 12 0 15 LT A'
EOF
#    psxy  -R -J -O -K -W1.5p,white << END >> $name
#$Lon1 $Lat1
#$Lon2 $Lat2
#END
#    pstext -R -J -O -K -P -G<< EOF >> $name
#$Lon1+0.001 $Lat1 12 0 15 LB B 
#$Lon2+0.001 $Lat2 12 0 15 LT B'
#EOF
     awk -v dias=$dias '($3-2091.011) < dias &&  $7 >= 1.5 {print $5, $4, $6/1000, $7, $3-2091.011}' $data | pscoupe -Aa$lon1/$lat1/$lon2/$lat2/90/3.0/-1/16f -Jx1.5/-0.5 -R  -Sa1 -Fsc0.15 -W  -O -K -Z$paleta_SEIS -L0.5p -B10/2WESn -X20.0 -Y5.0 >> $name
for p in `ls $POZOS*.out`
do
     awk '{print $1, $2, $3/1000}' $p | pscoupe -Aa$lon1/$lat1/$lon2/$lat2/90/40/-1/16f -J -R  -Sa1 -Fsc0.1 -Gblue -W,blue -O -K >> $name
done
if [ $mfoc = 1 ]; then
    awk '{print $1, $2, $3/1000, $5, $6, $7, $4, 0, 0, 0}' $mfoc_file | pscoupe -Aa$lon1/$lat1/$lon2/$lat2/90/3.0/-1/16f  -Sa1.5 -Gred -J -R -W  -O -K >> $name
fi

fi


if [ $seismicity_RSNC = 1 ]; then
    psscale -D17.0/5.0/3i/0.15ih -Ba20:"Profundidad (km)": -X-3.0 -Y-7.0 -K -C$paleta_SEIS  -O >> $name
    psxy -R-70/-25/-10/-4 -Jm0.40 -O  escalaM.txt -Sc -W0.5p,black  -X1.0 -Y3.0 -K >> $name  #bolitas
    pstext  -R-70/-55/-10/4 textoM.txt -Jm  -O -K -P -W0.5p,255/255/255  -X0.0 -Y0.0 -K >> $name #texto
fi


if [ $inset = 1 ]; then
   pscoast -JM3.5 -Bwesn -W0.5p -R$bounds -Y0.0 -X0.0 -Df -Swhite -G250/235/215 -N1 -N20.001pblack -O -K >> $name
   psxy  -R -J -O -K -W1.5p,red  << END >> $name
$west $south
$east $south
$east $north
$west $north
$west $south
END
 
fi

if [ $legend = 1 ]; then
    pslegend legend.gmt -Dx2/17.5/3.5c/3.0c/TC -R -J -F -G255/255/255 -V -O >> $name
fi


#format convertion
#ps2pdf $name $namepdf
ps2raster -Tf -V -A -P $name 
ps2epsi  $name
#display $name &
#evince $namepdf &
