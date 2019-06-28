import numpy as np
import cv2 
import matplotlib as mp
from matplotlib import pyplot as plt
from os import listdir
from os.path import isfile, join
from PIL import Image
from PIL import ImageColor as imgc
import winsound

def parser(limit) :
    Xs = []
    Ys = []
    Zs = []
    mypath = "outdata/"
    onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
    for t_file in onlyfiles: 
        if t_file.split(".")[-1] == "csv" : 
            f = file(str(mypath)+t_file)
            s = f.read()
            lines = s.split('\n')
            if lines[-1] == '' :
                del lines[-1]
            for line in lines :
                elmnts = line.split(',')
                Xs.append(float(elmnts[0]))
                Ys.append(float(elmnts[1]))
                Zs.append(int(elmnts[2]))
            f.close()
    return Xs,Ys,Zs

def readStepLimit() :
    filePath = "outdata/info.info"
    f = file(filePath)
    s = f.read()
    infos = s.split(',')
    return infos[0],infos[1]

def getncolors(n):
	space = (255.0*3)/n
	colors = [[0.0,0.0,0.0] for i in range(n)]	
        for i in range(1,n):
            if i < n/3 : 
                colors[i][0] = colors[i-1][0] + space 
                colors[i][1] = colors[i-1][1]
                colors[i][2] = colors[i-1][2]
            else : 
                if i < 2*n/3:
                    colors[i][1] = colors[i-1][1] + space 
                    colors[i][0] = colors[i-1][0]
                    colors[i][2] = colors[i-1][2]
                else :
                    colors[i][2]= colors[i-1][2] + space 
                    colors[i][1] = colors[i-1][1]
                    colors[i][0] = colors[i-1][0]

        colors = [(int(color[0]),int(color[1]),int(color[2])) for color in colors]
        winsound.Beep(2500, 1000)

	return colors


def getncolors1(n) :
    space = 360.0/n
    colors = []
    s = 100
    l = 50

    for i in range(n) :
        h = space*i
        hsl_String = "hsl(" + str(h) + "," + str(s) + "%," + str(l) + "%)"
        colors.append(imgc.getrgb(hsl_String))
    winsound.Beep(2500, 1000)
    return colors



def printColorScale(colors):
    b = 500
    image = Image.new("RGB", (b,10*len(colors)))
    for c in range(len(colors)) :
        for x in range(b):
            for u in range(10):
                image.putpixel((x,10*c+u), colors[c])
    
    image.save('outdata/colorscale.png') 
    



def showMand():
    step, limit = readStepLimit()
    xs, ys, zs = parser(limit)
    colors = getncolors(limit)
    printColorScale(colors)
    
    xa = -2.0
    xb = 1.0
    ya = -1.0
    yb = 1.0
    
    
    # image size 
    imgx = int ((xb-xa)/step)+1
    imgy = int ((yb-ya)/step)+1
    image = Image.new("RGB", (imgx, imgy))
    
    for i in range(len(ys)):  
        x =   (abs(xa/step) + xs[i]/step)
        y =   (abs(ya/step) + ys[i]/step)
        c = colors[zs[i]-1]
        image.putpixel((int(x), int(y)), c) 
    
    image.save('outdata/imgPIL.png') 
    winsound.Beep(2500, 1000)
    



showMand(700,0.001)