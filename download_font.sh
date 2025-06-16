#!/bin/bash

# Create fonts directory if it doesn't exist
mkdir -p assets/fonts

# Download Orbitron font
curl -L "https://fonts.google.com/download?family=Orbitron" -o orbitron.zip

# Unzip the font file
unzip -j orbitron.zip "static/Orbitron-VariableFont_wght.ttf" -d assets/fonts/

# Clean up
rm orbitron.zip 