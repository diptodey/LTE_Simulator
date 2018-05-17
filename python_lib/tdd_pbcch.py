import numpy as np
from sql import sql
from modulation import map_data_qpsk
import os, sqlite3, pickle

bin_repr = lambda var, bits : np.fromstring(np.binary_repr(var, bits),'u1') - ord('0')

pbch_crc_mask = {1: np.array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
                 4: np.array([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
                 16: np.array([0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1])}

inter_col_permut_pattern = [1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31,
                            0, 16, 8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, 30]





def add_crc():
    """
    Dummy to be implemented
    """
    return np.zeros(16, int)


def tail_bit_convolution_code(x):
    """
        TS36.321 Section 5.1.3.1 Tail biting convolutional coding
        The initial value of the shift register of the encoder shall be set to the values corresponding
        to the last 6 information bits in the input stream so that the initial and final
        states of the shift register are the same
    """
    s0, s1, s2, s3, s4, s5 = x[39], x[38], x[37], x[36], x[35], x[34]

    d0 = np.zeros(40, int)
    d1 = np.zeros(40, int)
    d2 = np.zeros(40, int)
    #print(d0)
    for i in range(0, 40):
        d0[i] = (((x[i] ^ s4) ^ s3) ^ s1) ^ s0
        d1[i] = (((x[i] ^ s5) ^ s4) ^ s3) ^ s0
        d2[i] = (((x[i] ^ s5) ^ s4) ^ s2) ^ s0
    return d0, d1, d2


def sub_block_interleaver(d):
    """
        TS 36.212 Section 5.1.4.1 Rate matching for turbo coded transport channels
        :param d0:
        :param d1:
        :param d2:
        :return:
    """
    c_tc_sub_block = 32
    r_tc_sub_block = int(np.ceil(len(d)/c_tc_sub_block))

    no_dummy_bits = (r_tc_sub_block * c_tc_sub_block) -  len(d)
    # We will use -1 as a placeholder for NULL
    dummy_bits = -1*np.ones(no_dummy_bits, int)
    _tmpv = np.concatenate( [dummy_bits, d]).reshape(-1)
    _tmpv = _tmpv.reshape([r_tc_sub_block, c_tc_sub_block ])
    v = np.zeros([r_tc_sub_block, c_tc_sub_block], int)
    for col in range(0, 32):
        v[:, col] = _tmpv[:,inter_col_permut_pattern[col]]
    return  np.reshape(v, -1, order = 'F')


def bit_collection(w):
    """ TS36.212 Section 5.1.4.2.2 Bit collection, selection and transmission"""
    k = 0
    j = 0
    e = np.zeros(1920 , int)
    while k < 1920 :
        # if null , -1 placeholder for null
        if w[j % 192] != -1:
            e[k] = w[j % 192]
            k = k +1
        j = j +1
    return e


def scramble(e):
    """
    We implement later
    :param e:
    :return:
    """
    return e


def rate_matching(d0, d1, d2):
    v0 = sub_block_interleaver(d0)
    v1 = np.concatenate([sub_block_interleaver(d1), v0]).reshape(-1)
    w = np.concatenate([sub_block_interleaver(d2), v1]).reshape(-1)
    e = bit_collection(w)
    return e


def generate_mib(bw, phich_mode, phich_ng, system_fn, number_enodeb_tx_ant ):
    """
    3 bits for system bandwidth
    3 bits for PHICH information,
        1 bit to indicate normal or extended PHICH
        2 bit to indicate the PHICH Ng value
    8 bits for system frame number
    10 bits are reserved for future use
    Apart from the information in the payload, the MIB CRC also conveys the number of transmit antennas used by the eNodeB.
    The MIB CRC is scrambled or XORed with a antenna specific mask.

    Every 10 ms System Frame number (SFN) is actually incremented by 1 and goes from 0..1023.
    Hence its a 10 bit number. What is actually transmitted in PBCH is SFN/4 which is 8 bit
    hence we save 2 bit for transmission. PBCH any way gets repeated every 10 ms for 4 time (40ms)
    and then new PBCH info is being transmitted from eNodeB. This new PBCH only have next
    SFN/4 number. to determine the actual SFN (10 bit one) UE find outs the frame in which 8-bit SFN
    decoded by UE is getting changed. This way it know 40 ms boundaries. and by multiplying 8-bit SFN by 4
    and adding offset from 40 ms boundary (actually the repetition count of PBCH) actual 10-bit SFN can be extracted.
    """

    """The MIB payload worth 24 bits"""
    mibdata_40ms_dict = {0: (0 + 0j)*np.zeros(240, int),
                        1: (0 + 0j)*np.zeros(240, int),
                        2: (0 + 0j)*np.zeros(240, int),
                        3: (0 + 0j)*np.zeros(240, int)}
    a = np.zeros(24, int)
    a[23:20:-1] = bin_repr(bw,3)
    a[20:19:-1] = bin_repr(phich_mode,1)
    a[19:17:-1] = bin_repr(phich_ng,2)
    a[17:9:-1] = bin_repr(system_fn, 8)

    """CRC Generation – where a 16 bit CRC and it is scrambled with a antenna specific mask"""
    p = add_crc()
    crc_mask = pbch_crc_mask[number_enodeb_tx_ant]

    c = np.zeros(40, int)
    c[0:24] = a
    c[24: 40] = (p + crc_mask) % 2
    d0, d1, d2 = tail_bit_convolution_code(c)
    e = rate_matching(d0, d1, d2)
    b = scramble(e)
    mibdata_40ms = map_data_qpsk(b)
    assert len(mibdata_40ms) == 960, "MIB dat sz wrong for 40 msec"
    mibdata_40ms_dict[0] = mibdata_40ms[0:240]
    mibdata_40ms_dict[1] = mibdata_40ms[240:480]
    mibdata_40ms_dict[1] = mibdata_40ms[480:720]
    mibdata_40ms_dict[1] = mibdata_40ms[720:960]
    pickle.dump(mibdata_40ms_dict, open("mib.p", "wb"))


def add_mib(frame, sfn, bw, ofdm_symbol):
    """ TS 36.211 Section: 6.6.4 Mapping to resource elements 
        
    """
    assert  sfn == 0, "MIB has to be in the first sf"
    assert  ofdm_symbol in [8, 9, 10, 11] # first sfn second slot
    indx = frame % 4
    mibdata_40ms_dict = pickle.load(open("mib.p", "rb"))
    data = mibdata_40ms_dict[indx]
    d = sql.get_data(ofdm_symbol)



generate_mib(0, 1, 1, 1, 1 )
