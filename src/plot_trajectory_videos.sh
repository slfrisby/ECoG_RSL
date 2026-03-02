#!/bin/bash

# load ffmpeg
module load ffmpeg

dirp=/group/mlr-lab/Saskia/ECoG_RSL/derivatives/results/

mkdir -p $dirp/videos/

# for dimensions 2 and 3
for dimension in 2 3; do

# for each type of time-frequency data 
for dataType in power phase; do

# for each frequency band
for frequency in all theta alpha beta gamma highGamma; do

# make the video
ffmpeg -r 10 -pattern_type glob -i "$dirp/figures/trajectories/"$dataType"/"$frequency"/D"$dimension"/*.png" -vf "scale=1280:-2,minterpolate" -c:v libx264 -pix_fmt yuv420p $dirp/videos/"$dataType"_"$frequency"_D"$dimension".mp4

done
done

# for voltage data, make the video
ffmpeg -r 10 -pattern_type glob -i "$dirp/figures/trajectories/voltage/D"$dimension"/*.png" -vf "scale=1280:-2,minterpolate" -c:v libx264 -pix_fmt yuv420p $dirp/videos/voltage_D"$dimension".mp4

done

zip $dirp/videos.zip $dirp/videos/


