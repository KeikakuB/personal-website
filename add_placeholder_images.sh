#!/bin/bash
base_path="source/images/projects"
ids="2019-02-03-Framestore-VR 2018-06-05-Machine-Head 2013-02-01-Writerator"
filename="thumbnail.png"
size_text="250x180"
size_final="318x180"
cwd=$(pwd)
for i in $ids; do
    cd "${cwd}/${base_path}/${i}"
    # Get name from id.
    name=${i#*-*-*-}
    # Convert dashes to spaces in name.
    name=$(echo ${name} | sed 's/-/ /g')
    echo "Generating ${name}... in $(pwd)"
    # Generate image with text filling the whole given space.
    convert -background black -fill white -gravity center -size ${size_text} -font Noto-Mono label:"${name}" ${filename}
    # Extend the "canvas" of the image to give the text some room to breath.
    mogrify -background black -gravity center -extent ${size_final} ${filename}
done
cd ${cwd}
