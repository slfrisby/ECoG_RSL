#!/bin/bash

# load ffmpeg
module load ffmpeg

dirp=/group/mlr-lab/Saskia/ECoG_RSL/derivatives/results
work=/group/mlr-lab/Saskia/ECoG_RSL/work

# for invididual items and category centroids
for items in allitems categories; do

mkdir -p $dirp/videos/$items/

# for dimensions 2 and 3
for dimension in 2 3; do

# for each type of time-frequency data 
for dataType in power phase; do

# for each frequency band
for frequency in all theta alpha beta gamma highGamma; do

# make a text file, containing all the input .png files in the right order
ls "$dirp/figures/trajectories/$items/$dataType/$frequency/D$dimension/"*.png | sort > $work/filelist.txt
# Prepend "file '", append "'" to each line, and make each frame 0.1 seconds in duration 
sed -i "s/^/file '/; s/$/'\nduration 0.1/" "$work/filelist.txt"

# make the video
ffmpeg -f concat \
-r 10 \
-safe 0 \
-i $work/filelist.txt \
-vf "scale=1280:-2,format=yuv420p" \
-c:v libx264 \
-crf 18 \
-pix_fmt yuv420p \
-movflags +faststart \
"$dirp/videos/$items/${dataType}_${frequency}_D${dimension}.mp4"

done
done

#now do voltage
ls "$dirp/figures/trajectories/$items/voltage/D$dimension/"*.png | sort > $work/filelist.txt
# Prepend "file '", append "'" to each line, and make each frame 0.1 seconds in duration 
sed -i "s/^/file '/; s/$/'\nduration 0.1/" "$work/filelist.txt"

# make the video
ffmpeg -f concat \
-r 10 \
-safe 0 \
-i $work/filelist.txt \
-vf "scale=1280:-2,format=yuv420p" \
-c:v libx264 \
-crf 18 \
-pix_fmt yuv420p \
-movflags +faststart \
"$dirp/videos/$items/voltage_D${dimension}.mp4"

done
done



