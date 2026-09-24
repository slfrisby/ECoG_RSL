#!/bin/bash

# Pushes figures and videos to GitHub in small batches (necessary for successful pushing).
# CAUTION: make sure you are properly ssh-authenticated before running, so that you are not prompted for a passphrase on every loop iteration! Run:
# eval "$(ssh-agent -s)"
# ssh-add ~/.ssh/id_ed25519

dirp=/group/mlr-lab/Saskia/ECoG_RSL/derivatives/results

# for invididual items and category centroids
for items in allitems categories; do

# for each type of time-frequency data 
for dataType in power phase; do

# for each frequency band
for frequency in all theta alpha beta gamma highGamma; do

# for dimensions 2 and 3
for dimension in 2 3; do
# add subpanel figures (-force adds files that are listed on the .gitignore)
git add --force $dirp/figures/trajectories/$items/$dataType/$frequency/panel/D$dimension 
# commit 
git commit -m "added figures: $dirp/figures/trajectories/$items/$dataType//$frequency/panel/D$dimension"
# push
git push 
done

# add whole figures (-force adds files that are listed on the .gitignore)
git add --force $dirp/figures/trajectories/$items/$dataType/$frequency/full
# commit 
git commit -m "added figures: $dirp/figures/trajectories/$items/$dataType//$frequency/full"
# push
git push 

# add videos
git add --force $dirp/videos/$items/"$dataType"_"$frequency".mp4
# commit 
git commit -m "added videos: $dirp/videos/$items/"$dataType"_"$frequency"_.mp4"
# push
git push

done
done

# do the same for voltage

for dimension in 2 3; do
# add subpanel figures 
git add --force $dirp/figures/trajectories/$items/voltage/panel/D$dimension
# commit 
git commit -m "added figures: $dirp/figures/trajectories/$items/voltage/panel/D$dimension"
# push
git push
done

# add whole figures 
git add --force $dirp/figures/trajectories/$items/voltage/full
# commit 
git commit -m "added figures: $dirp/figures/trajectories/$items/voltage/full/"
# push
git push

# add videos
git add --force $dirp/videos/$items/voltage_D"$dimension".mp4
# commit 
git commit -m "added videos: $dirp/videos/voltage_D$dimension.mp4"
# push
git push

done
