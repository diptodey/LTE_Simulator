import numpy as np


ModMapper = {
        "bpsk" : { "0":  np.power(2, -0.5)  + 1j*np.power(2, -0.5),
                   "1": -np.power(2, -0.5)  - 1j*np.power(2, -0.5)
                 },
        "qpsk" : { "00": 1.0*np.power(2, -0.5)  + 1j*np.power(2, -0.5),
                   "01": 1.0*np.power(2, -0.5)  - 1j*np.power(2, -0.5),
                   "10": -1.0*np.power(2, -0.5) + 1j*np.power(2, -0.5),
                   "11": -1.0*np.power(2, -0.5) - 1j*np.power(2, -0.5)
                 },
        "16qam" : { "0000": 1.0*np.power(10, -0.5) + 1j*np.power(10, -0.5),
                    "0001": 1.0*np.power(10, -0.5) + 3j*np.power(10, -0.5),
                    "0010": 3.0*np.power(10, -0.5) + 1j*np.power(10, -0.5),
                    "0011": 3.0*np.power(10, -0.5) + 3j*np.power(10, -0.5),
                    "0100": 1.0*np.power(10, -0.5) + 1j*np.power(10, -0.5),
                    "0101": 1.0*np.power(10, -0.5) - 3j*np.power(10, -0.5),
                    "0110": 3.0*np.power(10, -0.5)  - 1j*np.power(10, -0.5),
                    "0111": 3.0*np.power(10, -0.5)  - 3j*np.power(10, -0.5),
                    "1000": -1.0*np.power(10, -0.5) + 1j*np.power(10, -0.5),
                    "1001": -1.0*np.power(10, -0.5) + 3j*np.power(10, -0.5),
                    "1010": -3.0*np.power(10, -0.5) + 1j*np.power(10, -0.5),
                    "1011": -3.0*np.power(10, -0.5) + 3j*np.power(10, -0.5),
                    "1100": -1.0*np.power(10, -0.5) - 1j*np.power(10, -0.5),
                    "1101": -1.0*np.power(10, -0.5) - 3j*np.power(10, -0.5),
                    "1110": -3.0*np.power(10, -0.5) - 1j*np.power(10, -0.5),
                    "1111": -3.0*np.power(10, -0.5) - 3j*np.power(10, -0.5)
                }
}


def map_data_qpsk(x, mod = "qpsk"):
    if mod == "qpsk":
        x1 = x[0:len(x):2]
        x2 = x[1:len(x):2]
        return np.array([ModMapper["qpsk"][str(v1) + str(v2)] for (v1, v2) in zip(x1,x2)])
    elif mod == "bpsk":
        return np.array([ModMapper["bpsk"][str(v1)] for v1 in x])
    elif mod == "16qam":
        x1 = x[0:len(x):2]
        x2 = x[1:len(x):2]
        x3 = x[2:len(x):2]
        x4 = x[3:len(x):2]
        return np.array([ModMapper["16qam"][str(v1) + str(v2) + str(v3) + str(v4)] for (v1, v2, v3, v4) in zip(x1, x2, x3, x4)])
