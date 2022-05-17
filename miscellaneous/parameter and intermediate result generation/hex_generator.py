import numpy as np

#DEC_BITS
DEC_BITS = 5


#lines = ["00000001", "00000002","00000003","00000004","00000005","00000006","0000000B","00000008", "00000009","0000000A", "0000000B", "0000000C","0000000D", "0000000E", "0000000F"]
lines = [-1.0,2.3,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

# signed float to unsigned fixed point (4 bytes per data)
k=0
for line in lines:
    lines[k] =  int(np.round(line * (2**DEC_BITS))) 
    if(lines[k] < 0):
        lines[k] = lines[k] + 4294967296 # +2**32, signed to unsigned 
    k = k + 1

# unsigned to string  (eg: 1 to '00000001')
k=0
for line in lines:
    lines[k] = str(hex(int(line)).upper()[2:]).zfill(8)
    k = k+ 1

# add addr and 0400
i = 0
for line in lines:
    lines[i] = '04'+str(hex(i).upper()[2:]).zfill(4)+'00'+line
    if(i>=0xffff):
        print("Too Many Data!")
    data = bytearray.fromhex(lines[i])
    c_sum = 0x100-sum(data) & 0x0ff
    lines[i] = lines[i] + str(hex(c_sum).upper()[2:]).zfill(2)
    i = i + 1

# calculate checksum, and add end of file
with open('m10k.hex', 'w') as f:
    for line in lines:
        line = ':'+line
        f.write(line)
        f.write('\n')
    end = ":00000001FF"
    f.write(end)
    f.write('\n')
    