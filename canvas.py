import numpy as np
import cv2 
import matplotlib as mp
from matplotlib import pyplot as plt
from os import listdir
from os.path import isfile, join
from PIL import Image


def parser(limit) :
    Xs = []
    Ys = []
    Zs = []
    mypath = "outdata/"
    onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
    for t_file in onlyfiles: 
        f = file(str(mypath)+t_file)
        s = f.read()
        lines = s.split('\n')
        if lines[-1] == '' :
            del lines[-1]
        for line in lines :
            elmnts = line.split(',')
            Xs.append(elmnts[0])
            Ys.append(elmnts[1])
            Zs.append(float(elmnts[2]))
    f.close()
    return Xs,Ys,Zs

def getncolors(n):
	space = 255*3//n
	
	colors=[[0,0,0] for i in range(n)]
	for i in range(1,n):
		num = sum(colors[i-1])+space
		for j in range(len(colors[i])):
			if num > 255:
				colors[i][j]=255
				num=num-255
			else:
				colors[i][j]=num
				num =0
	colors = [(color[0],color[1],color[2]) for color in colors]
	return colors

def showMand(limit):
    xs, ys, zs = parser(limit)
    norm_e = mp.colors.Normalize(0,limit)
    plt.scatter(xs,ys,c=zs, cmap='BrBG', norm = norm_e)
    plt.savefig('outdata/img.png')

def showMand1(limit,step):
    # drawing area 
    xs, ys, zs = parser(limit)
    colors = getncolors(limit)
    xa = -2.0
    xb = 1.0
    ya = -1.0
    yb = 1.0
    
    
    # image size 
    imgx = (xb-xa)/step
    imgy = (yb-ya)/step
    image = Image.new("RGB", (imgx, imgy)) 
    
    for i in range(ys):  
        x =   abs(xa/step) + xs[i]/step
        y =   abs(ya/step) + ys[i]/step
        c = colors[zs[i]]
        image.putpixel((x, y), c) 
    
    image.savefig('outdata/imgPIL.png') 
    

showMand(300)
#showMand1(300,0.001)