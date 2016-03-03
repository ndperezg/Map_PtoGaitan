#!/bin/bash
###########GMT DEFAULTS#########
rm -rf .gmt*
#gmtset ANOT_FONT_SIZE 8
#gmtset LABEL_FONT_SIZE 8
#gmtset BASEMAP_TYPE plain
#gmtset PLOT_DEGREE_FORMAT DDD
#-------------------------------
name=locations.ps
namepdf=locations.pdf
namejpg=mapa_presentacion_sep02.jpg

#regions
region1=-71.45/-71.25/3.75/3.95
region2=-72.60/-70.4/3.2/4.6
region3=-75/-70/2/5.5
region4=-71.80/-71.1/3.6/4.1
region5=-72.0/-71.9/3.6/4.2
#colombia
bounds=-82.0/-67.0/-4.0/14.0

#cross section
lon1=-71.8 #-71.0 -71.610
lat1=3.8 #3.5 4.025
lon2=-71 #-71.8 -71.250
lat2=3.8 #4.2 3.750

#options
contour=1
ilu=1
pads=1
stations_PRE=0
names_PRE=0
stations_RSNC=1
stations_SUB=0
names_SUB=0
seismicity_PRE=0
seismicity_NEIC=0
seismicity_RSNC=0
cross_section_RSNC=0
cross_section_PRE=0
compare_locations=1
square=0
inset=0
legend=1
mfoc=1

#map parameters
region=$region4
west=`echo $region | awk 'BEGIN {FS="/"};{print $1}'`
east=`echo $region | awk 'BEGIN {FS="/"};{print $2}'`
north=`echo $region | awk 'BEGIN {FS="/"};{print $3}'`
south=`echo $region | awk 'BEGIN {FS="/"};{print $4}'`

topo=/home/topo/Col250m_bat30s.grd
topoIlu=/home/topo/Col250m_bat30s_int.grd
paleta=/home/nelson/mapa_cap1/coloibcaoNZ1_otra.cpt
paleta_SEIS=/home/nelson/mapa_cap1/depth.cpt
paleta_PRE=/home/nelson/mapa_cap1/mefoc2.cpt

#GMT commands
psbasemap -Ba0.2f0.1SEWN -JM17.5 -R$region     -Xc -Yc -P -V -K > $name #0.2
 if [ $ilu = 1 ] ; then
    grdimage $topo -C$paleta -B -J -I$topoIlu -R -P -V -O -K >> $name
else 
    grdimage $topo -C$paleta -B -J -R -P -V -O -K >> $name
fi
if [ $contour = 1 ] ; then
	grdcontour $topo -B -J -C100 -R -P -V -W0.08p,0/0/0 -GD10k -O -K>> $name
fi

pscoast -B -J -R$region  -Df   -Lf-71.25/3.7/3.5/15+l  -N2 -S255 -P -V -O -K >> $name # -T-71.15/4.0/1.5 -Lf-71.3/3.78/3.6/5+l    

if [ $seismicity_PRE = 1 ]; then
    awk 'BEGIN {FS=","};{if (NR>1) print $6, $7, $5/1000, $8*0.1}' camporubiales_events_2015-08-25.csv | psxy -R -JM -Sc -W1/0 -C$paleta_PRE -O -K >> $name  
fi    

if [ $seismicity_NEIC = 1 ]; then
    awk 'BEGIN {FS=","};{if (NR>1) print $3, $2, $4, $5*0.1}' query_NEIC.csv | psxy -R -JM -Sc -W1/0 -C$paleta_SEIS -O -K >> $name 
fi


if [ $seismicity_RSNC = 1 ]; then
    awk '{print $1, $2, -$3, $4}' seismicity_RSNC.out |psxy -R -JM -Sc -W0.1p,black -C$paleta_SEIS -t50 -O -K >> $name    
fi

if [ $stations_PRE = 1 ]; then
	awk 'BEGIN {FS=","};{if (NR>1) print $7, $8}' camporubiales_stations.csv | psxy -R -J -P -St0.36 -W0.2p,0/0/0 -G100/100/255 -O -K >> $name
fi

if [ $mfoc = 1 ]; then
    awk '{if (NR==8) print $5, $3, $7, $11, $12, $13, $10, $15, $14, $1"-Mw:"$10}' mecanismos.out | psmeca -Sa1.5 -C1.5,1 -G255/0/0 -R -J -O -K>> $name
fi

if [ $pads = 1 ]; then
	awk 'BEGIN {FS=","};{if (NR>1) print $2, $3}' CoordsPads.csv | psxy -R -J -P -Sd0.4 -W0.2p,0/0/0 -G0/255/255 -O -K >> $name
	#awk 'BEGIN {FS=","};{if (NR>1) print $2+0.0099, $3, $1}' CoordsPads.csv | pstext -R -J -G  -F+f10p,15,black+jLB+a0 -O -P -K >> $name
fi

if [ $stations_SUB = 1 ]; then
	psxy st_sub_PTG.txt -R -J -P -St0.36 -W0.2p,0/0/0 -G0/255/255 -O -K >> $name
fi

if [ $stations_RSNC = 1 ]; then
	psxy nombres_RSNC.txt -R -J -P -St0.36 -W0.2p,0/0/0 -G0/0/255 -O -K >> $name
	 awk '{print $1+0.03, $2+0.0099, $7}' nombres_RSNC.txt | pstext -R -J -G -F+f10p,15,black+jLT+a0  -O -P -K >> $name
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
    psxy  -R -J -O -K -W1p,black << END >> $name
$lon1 $lat1
$lon2 $lat2
END
  
    pstext -R -J -O -K -P -G<< EOF >> $name
$lon1+0.001 $lat1 12 0 15 LB A 
$lon2+0.001 $lat2 12 0 15 LT A'
EOF
     awk  'BEGIN {FS=","};{if (NR>1) print $6, $7, $5/1000, $8*0.1}' camporubiales_events_2015-08-25.csv | pscoupe -Aa$lon1/$lat1/$lon2/$lat2/90/100/-1/10f -Jx0.35/-0.20 -R -Sa1 -Fsc0.1 -W  -Z$paleta_PRE -O -K -L0.5p -B10/2WESn -X0.0 -Y-3.5 >> $name
fi

if [ $seismicity_RSNC = 1 ]; then
    psscale -D17.0/5.0/3i/0.15ih -Ba20:"Profundidad (km)": -X-3.0 -Y-7.0 -K -C$paleta_SEIS  -O >> $name
    psxy -R-70/-25/-10/-4 -Jm0.40 -O  escalaM.txt -Sc -W0.5p,black  -X1.0 -Y3.0 -K >> $name  #bolitas
    pstext  -R-70/-55/-10/4 textoM.txt -Jm  -O -K -P -W0.5p,255/255/255  -X0.0 -Y0.0 -K >> $name #texto
fi

if [ $seismicity_PRE = 1 ]; then
    psscale -D17.0/5.0/2i/0.10ih -Ba5:"Profundidad (km)": -X-3.0 -Y-7.0 -K -C$paleta_PRE  -O >> $name
    psxy -R-70/-25/-10/-4 -Jm0.40 -O  escalaM.txt -Sc -W0.5 -X1.0 -Y3.1 -K >> $name  #bolitas
    pstext  -R-70/-55/-10/4 textoM.txt -Jm  -O -K -P -W,255/255/255  -X0.0 -Y0.0 -K >> $name #texto
fi

if [ $inset = 1 ]; then
   pscoast -JM3.5 -Bwesn -W0.5p -R$bounds -Y7.2 -X14.0 -Df -S0/75/255 -G250/235/215 -N1 -N20.001pblack -O -K >> $name
   psxy  -R -J -O -K -W1.5p,0/0/0  << END >> $name
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
ps2pdf $name $namepdf
ps2epsi  $name
#display $name &
evince $namepdf &
