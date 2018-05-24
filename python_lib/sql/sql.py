
import numpy as np
import sqlite3
import io
import os


def adapt_array(arr):
    """
    http://stackoverflow.com/a/31312102/190597 (SoulNibbler)
    """
    out = io.BytesIO()
    np.save(out, arr)
    out.seek(0)
    return sqlite3.Binary(out.read())


def convert_array(text):
    out = io.BytesIO(text)
    out.seek(0)
    return np.load(out)


def conn_cursor():
    path = os.getcwd() + r'\\..\\python_lib\\sql\\subframe_rb.db'
    conn = sqlite3.connect(path, detect_types=sqlite3.PARSE_DECLTYPES)
    cursor = conn.cursor()
    return conn, cursor


def clear_all_ofdm_symbols():
    conn, cursor = conn_cursor()
    cursor.execute('DELETE FROM RB')
    conn.commit()


def init_db(total_no_carriers):
    path = os.getcwd() + r"\\..\\python_lib\\sql\\subframe_rb.db"
    try:
        os.remove(path)
    except FileNotFoundError:
        pass

    # Converts np.array to TEXT when inserting
    sqlite3.register_adapter(np.ndarray, adapt_array)

    # Converts TEXT to np.array when selecting
    sqlite3.register_converter("array", convert_array)

    conn = sqlite3.connect(path, detect_types=sqlite3.PARSE_DECLTYPES)
    cursor = conn.cursor()
    # Create table
    cursor.execute('''CREATE TABLE RB(SYMBOL INT PRIMARY KEY NOT NULL, arr array)''')
    """ insert all zeros for all symbols"""
    d = (0 + 0j) * np.zeros(total_no_carriers, int)
    for i in range(0,14):
        cursor.execute("insert into RB (SYMBOL, arr) values (?, ?)", (i, d,))
    conn.commit()


def insert_db(ofdm_symbol, d):
    conn, cursor = conn_cursor()
    cursor.execute("insert into RB (SYMBOL, arr) values (?, ?)", (ofdm_symbol, d,))
    conn.commit()


def update_db(ofdm_symbol, d):
    conn, cursor = conn_cursor()
    cursor.execute('''UPDATE RB SET arr = ? WHERE SYMBOL=? ''', (d, ofdm_symbol))
    conn.commit()


def get_one():
    conn, cursor = conn_cursor()
    cursor.execute("select arr from RB")
    data = cursor.fetchone()[0]
    return data


def get_data(ofdm_symbol):
    conn, cursor = conn_cursor()
    cursor.execute('''SELECT arr from RB WHERE SYMBOL=?''',(ofdm_symbol,))
    data = cursor.fetchone()[0]
    return data



init_db(12)