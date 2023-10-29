#!/bin/bash -x
LOCAL_DIR="$(pwd)"
DATA_DIR="/data"
winpty docker run -v "${LOCAL_DIR}:${DATA_DIR}" -w "/${DATA_DIR}" latexbuilder xelatex resume.tex
