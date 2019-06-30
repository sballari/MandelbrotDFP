import numpy as np
import cv2 
import matplotlib as mp
from matplotlib import pyplot as plt
from os import listdir
from os.path import isfile, join
from PIL import Image
from PIL import ImageColor as imgc
import winsound

def parser(limit,xl,xr,yb,yt) :
    Xs = []
    Ys = []
    Zs = []
    mypath = "outdata/"
    onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
    for t_file in onlyfiles: 
        if t_file.split(".")[-1] == "csv" : 
            if fileIntersectRange(xl,xr,yb,yt,t_file): #RANGE INTERSECA
                f = file(str(mypath)+t_file)
                s = f.read()
                lines = s.split('\n')
                if lines[-1] == '':
                    del lines[-1]
                for line in lines :
                    elmnts = line.split(',')
                    if lineInRange(xl,xr,yb,yt,elmnts):
                        Xs.append(float(elmnts[0]))
                        Ys.append(float(elmnts[1]))
                        Zs.append(int(elmnts[2]))
                f.close()
    return Xs,Ys,Zs

def fileIntersectRange(xl,xr,yb,yt,filename):
    #RANGE INTERSECA sia su x che su y
    estremi = filename.split(" ")
    estremi[1] = float(estremi[1])
    estremi[2] = float(estremi[2])
    estremi[3] = float(estremi[3])
    estremi[4] = float(estremi[4])
    e = ((xl<=estremi[1] and estremi[1]<=xr) or (xl<=estremi[2] and xr>=estremi[2])) and ((yb<=estremi[3] and yt>=estremi[3]) or (yb<=estremi[4] and yt>=estremi[4]))
    return e

def lineInRange(xl,xr,yb,yt,elmnts):
    x = float(elmnts[0])
    y = float(elmnts[1])
    e = (x>=xl and x<=xr and y>=yb and y<=yt)
    return e

def readStepLimit() :
    filePath = "outdata/info.txt"
    f = file(filePath)
    s = f.read()
    infos = (s.split('\n')[0] ).split(',')
    return float(infos[0]),int(infos[1])

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
    



def showMand(xa,xb,ya,yb):
    step, limit = readStepLimit()
    xs, ys, zs = parser(limit,xa,xb,ya,yb)
    colors = getncolors(limit)
    printColorScale(colors)
    
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
    



def stdShowMand():
    showMand(-02.0,1.0,-1.0,1.0)

stdShowMand()