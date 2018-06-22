import numpy as np
#import matplotlib.pyplot as plt
from modulation import *

class Baseband_Signal():

    def __init__(self, bw="1M4", no_rbs=6, rb_pos="Mid"):
        nrSubCarriersRB = 12
        self.nrSamplesCp = 160
        self.nrSamples = 2048
        self.subCarrierBwHz = 15000
        self.no_rbs = no_rbs
        self.bw = bw
        self.rb_pos = rb_pos
        self.max_sub_carriers = {"1M4": 72, "3M": 180, "5M": 300, "10M": 600, "15M": 900, "20M": 1200 }[bw]
        self.occ_sub_carriers = no_rbs * nrSubCarriersRB
        self.data = np.zeros(self.max_sub_carriers, dtype=complex)
        data_occupied = map_data_qpsk(np.random.randint(2, size =2*self.occ_sub_carriers))

        if rb_pos == "Mid":
            x1 = int((len(self.data) - self.occ_sub_carriers)/2)
            x2 = int((len(self.data) + self.occ_sub_carriers)/2)
            self.data[x1:x2] = data_occupied
        elif rb_pos == "Low":
            self.data[0: self.occ_sub_carriers] = data_occupied
        elif rb_pos == "High":
            self.data[self.max_sub_carriers - self.occ_sub_carriers:] = data_occupied

    def generate_one_sf(self):
        ts = 1.0/30720000
        time = np.arange(0, 0.001 , ts)
        oup_wav = np.zeros(len(time), dtype=complex)
        z = 2 * np.pi * self.subCarrierBwHz * (time - (self.nrSamplesCp * ts))
        low_bound = int(np.floor(self.max_sub_carriers/2))
        high_bound = int(np.ceil(self.max_sub_carriers/2))

        for k in range(-low_bound, 0):
            index = k*z
            oup_wav += self.data[k + low_bound] * (np.cos(index) + 1j*np.sin(index))

        for k in range(1, high_bound +1):
            index = k * z
            oup_wav += self.data[k + high_bound -1] * (np.cos(index) + 1j*np.sin(index))

        return oup_wav

    def generate_tdd(self, no_subframes):
        ts = 1.0 / 30720000
        time = np.arange(0, 0.001*no_subframes, ts)
        oup_wav = np.zeros(len(time), dtype=complex)

        for i in range(0, no_subframes):
            oup_wav[30720*i:30720*(i+1)] = self.generate_one_sf()
        return oup_wav

    def scale_dbfs_and_save(self, nr_samples, dbfs, real, imag):
        ratio = np.power(np.power(10, dbfs/10), 0.5)
        # 16 bit -32768 to 32767
        max = 32767*ratio
        min = -32768*ratio
        span = max - min

        max_data = [np.max(real), np.max(imag)][np.max(imag) > np.max(real)]
        min_data = [np.min(real), np.min(imag)][np.min(imag) > np.min(real)]
        data_range = max_data - min_data

        factor = span/data_range
        ret_real = max - ((max_data - real)*factor)
        ret_imag = max - ((max_data - imag) * factor)
        real = ret_real.astype('int')
        imag = ret_imag.astype('int')

        filename = "iq_data_bw_%s_rbs_%s_pos_%s_%ddbfs" %(self.bw, self.no_rbs, self.rb_pos, dbfs)
        with open(filename, 'w') as f:
            for i in range(0, nr_samples):
                f.write("%d     %d\n" % (real[i], imag[i]))

    def plot_fft(self, data):
        y = np.fft.fft(data)/len(data)
        x = np.linspace(0, len(y), len(y))


        #markerline, stemlines, baseline = plt.stem(x, np.abs(y), '-.')
        #plt.setp(baseline, color='r', linewidth=2)
        #plt.show()

x = Baseband_Signal(bw="20M", no_rbs=20, rb_pos = "High")
y = x.generate_tdd(10)
x.scale_dbfs_and_save(8192, -14, np.real(y), np.imag(y))

"""
z1 = np.fft.fft(y)/len(y)
z2 = np.linspace(0, len(y), len(y))
markerline, stemlines, baseline = plt.stem(z2, np.abs(z1), '-.')
plt.setp(baseline, color='r', linewidth=2)
plt.show()

z1 = np.abs(np.fft.fft(y))
z2 = np.linspace(0, len(z1), len(z1))
"""
#print(z1)
#plt.plot(z2, z1)


#plt.show()
