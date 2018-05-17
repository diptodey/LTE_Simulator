

import numpy as np
from sql import sql


"""
The duration of the data part of OFDM symbol is 1 / 15KHz = 66.7 us, where 15KHz is the sub-carrier spacing.
For Normal Cyclic Prefix, the CP duration for the first symbol of a slot is 5.2 us long and for the rest of the symbols
in the slot the CP duration is 4.7 us long. So the first symbol of the slot is 71.9 us long and rest of symbols in the slot 71.3 us long.
The duration of one subframe is 2*71.9 us + 12*71.3 us = 1 ms. The Extended CP duration is 16.67 us and is same for all
symbols of the slot. Refer tables 3.1.1-1 and 3.1.1-2 in the following documents for details.
"""

available_rbs = {0: 6, 1: 15, 2: 25, 3: 50, 4: 75, 5: 100}
number_carriers_one_rb = 12


def tddsfn_init( ):
    sql.init_db()


def add_pss(sfn, bw, ofdm_symbol, cell_number = 0, ):
    assert sfn in [1, 6], "Only TDD SubFrames 1 and 6 carry PSS"
    assert ofdm_symbol == 2, "TDD — The PSS is mapped to the third OFDM symbol in subframes 1 and 6,"
    """
        36.211  Section 6.11.1.1 Sequence generation
    """

    d = sql.get_data(ofdm_symbol)
    root_index_map = {0: 25, 1: 29, 2: 34}
    u = root_index_map[cell_number]

    x1 = np.arange(0, 31, 1)
    k1 = np.pi * u * x1 * (x1 + 1)/63.0
    y1 = np.cos(k1) - (1j* np.sin(k1))

    x2 = np.arange(31, 62, 1)
    k2 = np.pi * u * (x2 + 1) * (x2 + 2)/63.0
    y2 = np.cos(k2) - (1j * np.sin(k2))

    """
        36.211 Section 6.11.1.2 Mapping to resource elements
        The PSS is mapped into the first 31 subcarriers either side of the DC subcarrier. Therefore, the PSS uses
        six resource blocks with five reserved subcarriers each side, as shown in the following figure.
    """
    start_pos = int(-31 + (available_rbs[bw] * number_carriers_one_rb)/2)
    d[start_pos: start_pos + 62] = np.concatenate([y1, y2])
    sql.update_db(ofdm_symbol, d)


def add_sss(sfn, bw, ofdm_symbol, nid_1 = 20, nid_2 =0 ):
    assert  sfn in [0, 5], "Only TDD SubFrames 0 and 5 carry SSS"
    assert ofdm_symbol == 13, "TDD — The SSS is mapped to the last OFDM symbol in subframes 0 and 5,"
    assert nid_1 in range(0, 168), "Cell Identity group must be in 0,1...167"
    assert nid_2 in range(0, 2), "Cell Identity within group must be in 0,1,2"

    d = sql.get_data(ofdm_symbol)
    """
        36.211 Section 6.11.2.1 Sequence generation
    """
    q_prime = int(nid_1/30)
    q = int((nid_1 + q_prime*(q_prime + 1)/2) / 30)
    m_prime = nid_1 + q*(q + 1)/2
    m0 = m_prime % 31
    m1 = (m0 + int(m_prime/31) + 1) % 31

    x = np.array([0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1])
    s = 1 - 2*x
    s0_m0 = [s[int((i + m0) % 31)] for i in range(0, 31)]
    s1_m1 = [s[int((i + m1) % 31)] for i in range(0, 31)]

    x = np.array([0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1])
    c = 1 - 2*x
    c0 = [c[ int((i + nid_2) % 31)] for i in range(0, 31)]
    c1 = [c[ int((i + nid_2 + 3) % 31)] for i in range(0, 31)]

    x = np.array([ 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1])
    z = 1 - 2*x
    z1_m0 = [z[ int((i + int(m0 % 8)) % 31)] for i in range(0, 31)]
    z1_m1 = [z[ int((i + int(m1 % 8)) % 31)] for i in range(0, 31)]
    if sfn == 0:
        d_2n =np.multiply(s0_m0, c0)
        d_2n_plus_one = np.multiply(np.multiply(s1_m1, c1), z1_m0)
    else:
        d_2n = np.multiply(s1_m1, c0)
        d_2n_plus_one = np.multiply(np.multiply(s0_m0, c1), z1_m1)

    """
        36.211 Section 6.11.2.2 Sequence generation
    """
    start_pos = int(-31 + (available_rbs[bw] * number_carriers_one_rb) / 2)
    d[start_pos: start_pos + 62] = np.ravel(np.column_stack((d_2n, d_2n_plus_one)))
    sql.update_db(ofdm_symbol, d)


def add_sib():
    pass


def add_pdsch():
    pass


def add_pihch():
    pass


def generate_downlink():
    pass


def add_prach():
    pass


def add_pucch():
    pass


def add_pusch():
    pass


def add_dmrs():
    pass


def add_srs():
    pass


def generate_uplink():
    pass


"""
def gen_x():
    x = np.zeros([1, 31])
    for i in range(0,31):
        if i in [0,1,2,3]:
            x[0][i] = 0
        elif i == 4:
            x[0][i] = 1
        else:
            x[0][i] = (x[0][i -1] + x[0][i-3] + x[0][i - 4] + x[0][i -5]) % 2
    print(x)

gen_x()
"""

#p = TddSubframe()
sql.init_db( 72)
#add_pss(1,0 , 2)
add_sss(0,0, 13)
#p.clear_all_ofdm_symbols()
