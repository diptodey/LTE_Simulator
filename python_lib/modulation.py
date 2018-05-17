import numpy as np


IQ = {
        "BPSK" : { "0":  np.power(2, -0.5)  + 1j*np.power(2, -0.5),
                   "1": -np.power(2, -0.5)  - 1j*np.power(2, -0.5)
                 },
        "QPSK" : { "00": np.power(2, -0.5)  + 1j*np.power(2, -0.5),
                   "01": np.power(2, -0.5)  - 1j*np.power(2, -0.5),
                   "10": -np.power(2, -0.5) + 1j*np.power(2, -0.5),
                   "11": -np.power(2, -0.5) - 1j*np.power(2, -0.5)
                 },
        "16QAM" : { "0000": np.power(10, -0.5) + 1j*np.power(10, -0.5),
                    "0001": np.power(10, -0.5) + 3j*np.power(10, -0.5),
                    "0010": 3*np.power(10, -0.5) + 1j*np.power(10, -0.5),
                    "0011": 3*np.power(10, -0.5) + 3j*np.power(10, -0.5),
                    "0100": np.power(10, -0.5) + 1j*np.power(10, -0.5),
                    "0101": np.power(10, -0.5) - 3j*np.power(10, -0.5),
                    "0110": 3*np.power(10, -0.5)  - 1j*np.power(10, -0.5),
                    "0111": 3*np.power(10, -0.5)  - 3j*np.power(10, -0.5),
                    "1000": -1*np.power(10, -0.5) + 1j*np.power(10, -0.5),
                    "1001": -1*np.power(10, -0.5) + 3j*np.power(10, -0.5),
                    "1010": -3*np.power(10, -0.5) + 1j*np.power(10, -0.5),
                    "1011": -3*np.power(10, -0.5) + 3j*np.power(10, -0.5),
                    "1100": -1*np.power(10, -0.5) - 1j*np.power(10, -0.5),
                    "1101": -1*np.power(10, -0.5) - 3j*np.power(10, -0.5),
                    "1110": -3*np.power(10, -0.5) - 1j*np.power(10, -0.5),
                    "1111": -3*np.power(10, -0.5) - 3j*np.power(10, -0.5)
                }
}


def map_data_qpsk(x):

    I = x[0:len(x):2]
    Q = x[1:len(x):2]

    return np.array([IQ["QPSK"][str(i) + str(q)] for (i, q) in zip(I,Q)])
