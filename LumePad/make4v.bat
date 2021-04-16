rem Windows batch file runs magick to create 2x2 JPG for Leia Inc LumePad glasses free 3D tablet display
rem 4V full size remove -resize x1600 option
rem 4V resized to vertical 1600 pixels, no alignment
rem appends _2x2 suffix for LumePad
magick montage SAMxxxx_LL.jpg SAMxxxx_LM.jpg SAMxxxx_RM.jpg SAMxxxx_RR.jpg -resize x1600 -geometry +0+0 -tile 2x2 SAMxxxx_1600_2x2.jpg
