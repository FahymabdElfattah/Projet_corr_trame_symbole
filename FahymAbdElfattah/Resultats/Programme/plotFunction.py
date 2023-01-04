import matplotlib.pyplot as plt
import numpy as np

x = np.arange(1,3001)
y = np.arange(1,3001)

f = ""
n = 0

#file = open("in_re5_chan2.txt","r")

#file = open("corr_symbole.txt","r")

file = open("corr_trame.txt","r")

for i in range(3000):
    f = file.readline()
    n = int(f)
    y[i] = n

fig, ax = plt.subplots()
ax.plot(x,y)
#plt.title('in_re5_chan2.txt')
#plt.ylabel('in_re5_chan2')

#plt.title('corr_symbole.txt')
#plt.ylabel('corr_symbole')

plt.title('corr_trame.txt')
plt.ylabel('corr_trame')
plt.show()
