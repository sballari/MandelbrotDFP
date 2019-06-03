import numpy as np
import cv2 
from matplotlib import pyplot as plt
from os import listdir
from os.path import isfile, join

def parser() :
    mypath = "outdata/"
    onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
    for t_file in onlyfiles: 