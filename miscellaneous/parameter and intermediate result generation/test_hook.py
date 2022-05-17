import torch.nn as nn
import torch
import time
import numpy as np
from torchvision import datasets
from torchvision.transforms import ToTensor

class CNN(nn.Module):
    def __init__(self):
        super(CNN, self).__init__()
        self.conv1 = nn.Sequential(         
            nn.Conv2d(
                in_channels=1,              
                out_channels=2,            
                kernel_size=5,              
                stride=1,                   
                padding=0,                  
            ),                     
            nn.ReLU(),                      
            nn.MaxPool2d(kernel_size=2), 
        )
        self.conv2 = nn.Sequential(         
            nn.Conv2d(2, 3, 3, 1, 0),                      
            nn.ReLU(),                                     
            nn.MaxPool2d(2),                                
        )
        # fully connected layer, output 10 classes
        self.out = nn.Linear(3 * 5 * 5, 10)
    def forward(self, x):
        x = self.conv1(x)
        x = self.conv2(x)
        # flatten the output of conv2 to (batch_size, 32 * 7 * 7)
        x = x.view(1, -1)
        output = self.out(x)
        return output, x    # return x for visualization

activation = {}
def get_activation(name):
    def hook(model, input, output):
        activation[name] = output.detach()
    return hook


model = CNN()
model.load_state_dict(torch.load("./simplecnn"))
model.eval()

model.out.register_forward_hook(get_activation('out'))

train_data = datasets.MNIST(
    root = 'data',
    train = True,                         
    transform = ToTensor(), 
    download = True,            
)
test_data = datasets.MNIST(
    root = 'data', 
    train = False, 
    transform = ToTensor()
)

# print("print train data")
# print(test_data[0][0].type)
start = time.time()
output = model(test_data[0][0])
end = time.time()
print ("Time elapsed:", end - start)
# print(activation['out'])
# print(train_data[0][0].shape)