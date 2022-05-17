import torch
import torchvision
import torchvision.transforms as transforms
from PIL import Image
import matplotlib.pyplot as plt
import numpy as np
import os
# 10k test data in total, please select data here
DATA_NUM = 3999 # from 0 to 9999


# Parameters
DEC_BITS = 9

img = Image.open('C:/Users/ys566/Documents/GitHub/ECE5760/final project/demo_pack/image_data/image_raw.png')
transform = transforms.Grayscale()
img = transform(img)
# img.show()

transform_ts = transforms.ToTensor()
tensor = transform_ts(img)
print(tensor)
listTensor = tensor.numpy()
listTensor = listTensor.squeeze()
plt.imshow(listTensor, cmap='gray')
plt.show()

lines = list(listTensor.flatten())
# print(lines)

def list_to_unsigned(lines):
    k=0
    for line in lines:
        lines[k] =  int(np.round(line * (2**DEC_BITS)))
        if(lines[k] < 0):
            lines[k] = lines[k] + 4294967296 # +2**32, signed to unsigned
        k = k + 1
    return lines

lines = list_to_unsigned(lines)
print(lines)
str1 = "".join((str(line)+",") for line in lines)
str1 = str1[:-1]
str1 = "int mnist_in[784] = {" + str1 + "};"
with open("C:/Users/ys566/Documents/GitHub/ECE5760/final project/demo_pack/image_data/mnist_in.dat", 'w') as f:
    f.write(str1)

print("success")

os.system('scp "C:/Users/ys566/Documents/GitHub/ECE5760/final project/demo_pack/image_data/mnist_in.dat"  root@10.253.17.15:/home/root/final_project/demo/')
