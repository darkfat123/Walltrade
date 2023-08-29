import time
import MySQLdb
from flask_mysqldb import MySQL
from flask import Flask, request, jsonify , session
import requests
import yfinance as yf
import pandas as pd
import numpy as np
import datetime as dt
from sklearn.preprocessing import MinMaxScaler
from keras.models import Sequential
from keras.layers import LSTM, Dropout, Dense
import json
from flask_cors import CORS
import alpaca_trade_api as tradeapi
import mysql.connector
from alpaca_trade_api import REST
import websockets
import asyncio
from tradingview_ta import TA_Handler, Interval, Exchange
from settrade_v2 import Investor
from bs4 import BeautifulSoup
from forex_python.converter import CurrencyRates



app = Flask(__name__)
app.config['MYSQL_HOST'] = 'localhost'  # หรือ hostname ของเซิร์ฟเวอร์ MySQL
app.config['MYSQL_USER'] = 'root'  # ชื่อผู้ใช้งานฐานข้อมูล
app.config['MYSQL_PASSWORD'] = ''  # รหัสผ่านของผู้ใช้งานฐานข้อมูล
app.config['MYSQL_DB'] = 'walltrade'  # ชื่อฐานข้อมูล
CORS(app)
mysql = MySQL(app)


@app.route('/predict', methods=['POST'])
def predict():
    name = request.json.get('name')

    info = yf.Ticker(name).info
    start = dt.datetime.now() - dt.timedelta(days=365)
    end = dt.datetime.now()
    data = yf.download(name, start, end)

    scaler = MinMaxScaler(feature_range=(0, 1))
    scaled_data = scaler.fit_transform(data['Close'].values.reshape(-1, 1))
    prediction_day = 60
    x_train = []
    y_train = []
    for x in range(prediction_day, len(scaled_data)):
        x_train.append(scaled_data[x-prediction_day:x, 0])
        y_train.append(scaled_data[x, 0])

    x_train, y_train = np.array(x_train), np.array(y_train)
    x_train = np.reshape(x_train, (x_train.shape[0], x_train.shape[1], 1))

    model = Sequential()
    model.add(LSTM(units=50, return_sequences=True, input_shape=(x_train.shape[1], 1)))
    model.add(Dropout(0.2))
    model.add(LSTM(units=50, return_sequences=True))
    model.add(Dropout(0.2))
    model.add(LSTM(units=50))
    model.add(Dropout(0.2))
    model.add(Dense(units=1))
    model.compile(optimizer='adam', loss='mean_squared_error')
    model.fit(x_train, y_train, epochs=25, batch_size=32)

    test_start = dt.datetime(2021, 1, 1)
    test_end = dt.datetime.now()
    test_data = yf.download(name, test_start, test_end)
    actual_prices = test_data['Close'].values
    total_dataset = pd.concat((data['Close'], test_data['Close']), axis=0)
    model_inputs = total_dataset[len(total_dataset)-len(test_data) - prediction_day:].values
    model_inputs = model_inputs.reshape(-1, 1)
    model_inputs = scaler.transform(model_inputs)

    x_test = []
    for x in range(prediction_day, len(model_inputs)):
        x_test.append(model_inputs[x-prediction_day:x, 0])
    x_test = np.array(x_test)
    x_test = np.reshape(x_test, (x_test.shape[0], x_test.shape[1], 1))

    predicted_prices = model.predict(x_test)
    predicted_prices = scaler.inverse_transform(predicted_prices)

    real_data = [
        model_inputs[len(model_inputs) - prediction_day:len(model_inputs+1), 0]]
    real_data = np.array(real_data)
    real_data = np.reshape(real_data, (real_data.shape[0], real_data.shape[1], 1))

    prediction = model.predict(real_data)
    prediction = scaler.inverse_transform(prediction)
    prediction_text = f"Prediction: {prediction}"

    return jsonify({'prediction': prediction_text})


@app.route('/getAccount', methods=['GET'])
def getAccount():
    API_KEY = 'PKOSUIG2YN42EOIQLBEE'
    SECRET_KEY = 'wohP73H9f7s6STxleaLL8FXCv7D5JZYHpGMRXNq5'

    # API endpoint URL
    endpoint = 'https://paper-api.alpaca.markets'

    # Set request headers
    headers = {
        'APCA-API-KEY-ID': API_KEY,
        'APCA-API-SECRET-KEY': SECRET_KEY
    }

    # Send GET request to the API endpoint
    response = requests.get(endpoint, headers=headers)

    # Check if the request was successful
    if response.status_code == 200:
        # Parse the JSON response
        account_data = response.json()
    
        # Retrieve the account balance
        balance = account_data['portfolio_value']
    
        return jsonify(balance)
    else:
        return (f"Error: {response.status_code} - {response.text}")



@app.route('/login', methods=['POST'])
def login():
    username = request.form.get('username')
    password = request.form.get('password')


    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM users_info WHERE username = %s AND password = %s", (username, password))
    user = cur.fetchone()
    cur.close()
    
    if user:
        return jsonify({'message': 'Login successful'})
    else:
        return jsonify({'message': 'Invalid username or password'})

@app.route('/register', methods=['POST'])
def register():
    try:
        # Get data from request
        email = request.json['email']
        username = request.json['username']
        password = request.json['password']

        # Establish connection to MySQL database
        conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
        cursor = conn.cursor()

        # Check if username already exists
        query = "SELECT * FROM users_info WHERE username = %s"
        cursor.execute(query, (username,))
        existing_user = cursor.fetchone()

        if existing_user:
            # Close cursor and connection
            cursor.close()
            conn.close()

            # Return error response as JSON
            response = {
                'message': 'Username already exists'
            }
            return jsonify(response), 400

        # Insert new user into the table
        query = "INSERT INTO users_info (Email, username, password) VALUES (%s, %s, %s)"
        values = (email, username, password)
        cursor.execute(query, values)
        conn.commit()

        # Close cursor and connection
        cursor.close()
        conn.close()

        # Return success response as JSON
        response = {
            'message': 'Registration successful',
            'email': email,
            'username': username
        }
        return jsonify(response), 200

    except Exception as e:
        # Return error response as JSON
        response = {
            'message': 'Registration failed',
            'error': str(e)
        }
        return jsonify(response), 400

@app.route('/asset_list', methods=['GET'])
def get_asset_list():
    api = tradeapi.REST(
        key_id='PK8NXGV44WWTJA356CDG',
        secret_key='nR9ySdpMSTKbnflGrJaBueH3EVCJ9fRV9gxOhnod',
        base_url='https://paper-api.alpaca.markets'
    )

    # Get a list of all active assets.
    active_assets = api.list_assets(status='active',)

    # Filter the assets down to just those on NASDAQ.
    nasdaq_assets = [a for a in active_assets if (a.exchange == 'NASDAQ' or a.exchange == 'NYSE') and a.marginable == True]

    # Create a list of dictionaries containing name and symbol of each NASDAQ asset.
    asset_list = [{'Name': a.name, 'Symbol': a.symbol} for a in nasdaq_assets]
    print(len(asset_list))
    # Return the asset list as JSON.
    return jsonify(assets=asset_list)

@app.route('/thStockList', methods=['GET'])
def thStockList():
    set_stocks = [
    "ADVANC",
    "AOT",
    "BBL",
    "BCP",
    "BDMS",
    "BEM",
    "BGRIM",
    "BH",
    "BJC",
    "BPP",
    "BTS",
    "CBG",
    "CENTEL",
    "CK",
    "CPALL",
    "CPF",
    "CPN",
    "CRC",
    "DELTA",
    "EA",
    "EGCO",
    "GGC",
    "GPSC",
    "GULF",
    "HANA",
    "IRPC",
    "IVL",
    "KBANK",
    "KCE",
    "KKP",
    "KTB",
    "LH",
    "M",
    "MAJOR",
    "OR",
    "PTT",
    "PTTEP",
    "PTTGC",
    "S",
    "SAMART",
    "SAWAD",
    "SCB",
    "SCC",
    "SCP",
    "SCGP",
    "SIRI",
    "SPALI",
    "SPRC",
    "STA",
    "SUPER",
    "TCAP",
    "THANI",
    "TISCO",
    "TKN",
    "TOA",
    "TOP",
    "TPIPP",
    "TRUE",
    "TTW",
    "TU",
    "WHA"
]

    investor = Investor(
        app_id="l6A2nvIv9t5YnPTE",
        app_secret="AJqOuo549hxwITYkBKDnd5dFQ08ogVG5qp6e7pBxnIdi",
        broker_id="SANDBOX",
        app_code="SANDBOX",
        is_auto_queue=False)
          
    mkt_data = investor.MarketData()
    stocks_list = []

    for symbol in set_stocks:
        res = mkt_data.get_quote_symbol(symbol)
        stock_data = {'Symbol': res['symbol'], 'Last': res['last']}
        stocks_list.append(stock_data)

    return jsonify(stocks_list)


@app.route('/api/user', methods=['POST'])
def create_user():
    api_key = request.form['api_key']
    secret_key = request.form['secret_key']
    username = request.form['username'] # ชื่อผู้ใช้งานที่ต้องการแทรก

    cur = mysql.connection.cursor()
    cur.execute("""
        UPDATE users_info SET api_key=%s, secret_key=%s WHERE username = %s
    """, (api_key, secret_key, username))
    mysql.connection.commit()
    cur.close()

    return jsonify({'message': 'User created successfully'})
   

@app.route('/update_watchlist', methods=['POST'])
def update_watchlist():
    # รับข้อมูลจากผู้ใช้ผ่านตัวแปร form
    name = request.form.get('name')
    username = request.form.get('username')
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    cursor = conn.cursor()
    # ส่งคำสั่ง SQL เพื่อดึงข้อมูล
    query = f"SELECT watchlist FROM users_info WHERE username = '{username}'"
    cursor.execute(query)

    # ดึงข้อมูลจากการสอบถาม
    result = cursor.fetchone()

    try:
        stock_names = json.loads(result[0])
    except json.decoder.JSONDecodeError:
        # หากมีข้อผิดพลาดในการแปลง JSON
        stock_names = []

    # เพิ่มชื่อใหม่ในรายการ
    stock_names.append(name)

    # แปลงรายการ Python เป็น JSON ใหม่
    updated_json = json.dumps(stock_names)

    # อัปเดตข้อมูลในฐานข้อมูล
    update_query = f"UPDATE users_info SET watchlist = %s WHERE username = '{username}'"
    cursor.execute(update_query, (updated_json,))

    # ยืนยันการเปลี่ยนแปลงข้อมูล
    conn.commit()

    return 'Watchlist updated successfully'

@app.route('/deleteWatchlist', methods=['POST'])
def deleteWatchlist():
    # รับข้อมูลจากผู้ใช้ผ่านตัวแปร form
    symbol = request.json.get('symbol')
    username = request.json.get('username')
    print(symbol)
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    cursor = conn.cursor()

    # ดึงข้อมูล watchlist ของผู้ใช้
    query = f"SELECT watchlist FROM users_info WHERE username = '{username}'"
    cursor.execute(query)
    result = cursor.fetchone()
    if result:
        watchlist = json.loads(result[0]) if result[0] else []  # แปลง JSON เป็น List

        if symbol in watchlist:
            watchlist.remove(symbol)  # ลบรายการหุ้นจาก List

        updated_watchlist = json.dumps(watchlist)  # แปลง List เป็น JSON เพื่อบันทึกในฐานข้อมูล

        # อัปเดตข้อมูล watchlist ในฐานข้อมูล
        update_query = f"UPDATE users_info SET watchlist = %s WHERE username = '{username}'"
        cursor.execute(update_query, (updated_watchlist,))

        # ยืนยันการเปลี่ยนแปลงข้อมูล
        conn.commit()
        conn.close()

        return 'Watchlist deleted successfully'

    conn.close()
    return 'User not found or watchlist is empty'


@app.route('/displayWatchlist', methods=['POST'])
def displayWatchlist():
    username = request.form.get('username')

    cur = mysql.connection.cursor()
    cur.execute("SELECT watchlist FROM users_info WHERE username = %s", (username,))
    watchlist = cur.fetchone()
    cur.close()

    if watchlist:
        watchlist = json.loads(watchlist[0])
        return jsonify(watchlist)
    else:
        return jsonify([])


@app.route('/getBalance', methods=['POST'])
def getBalance():
    username = request.form.get('username')
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    if result is not None:
        api_key, secret_key = result

        # Make the API request to get the account information
        response = requests.get(
            f'https://paper-api.alpaca.markets/v2/account',
            headers={'APCA-API-KEY-ID': api_key, 'APCA-API-SECRET-KEY': secret_key}
        )

        # Check if the request was successful
        if response.status_code == 200:
            account_info = response.json()
            wallet_balance = account_info['portfolio_value']            
            return jsonify({'wallet_balance': wallet_balance})
        else:
            return jsonify({'error': f"Failed to retrieve wallet balance. Error: {response.text}"})
    else:
        return jsonify({'error': 'User not found'})
    
@app.route('/getCash', methods=['POST'])
def getCash():
    username = request.form.get('username')
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    if result is not None:
        api_key, secret_key = result

        # Make the API request to get the account information
        response = requests.get(
            f'https://paper-api.alpaca.markets/v2/account',
            headers={'APCA-API-KEY-ID': api_key, 'APCA-API-SECRET-KEY': secret_key}
        )

        # Check if the request was successful
        if response.status_code == 200:
            account_info = response.json()
            wallet_balance = account_info['cash']            
            return jsonify({'wallet_balance': wallet_balance})
        else:
            return jsonify({'error': f"Failed to retrieve wallet balance. Error: {response.text}"})
    else:
        return jsonify({'error': 'User not found'})
    
@app.route('/get_balance_change', methods=['POST'])
def get_balance_change():
    username = request.json.get('username')
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    # Create the Alpaca REST API client
    api = REST(result[0], result[1], base_url='https://paper-api.alpaca.markets')

    # Get the account information
    account = api.get_account()

    # Check the current balance vs. the balance at the last market close
    balance_change = float(account.equity) - float(account.last_equity)
    percentage_change = ((float(account.equity) - float(account.last_equity)) / float(account.last_equity)) * 100

    # Return the result as JSON
    return jsonify({'balance_change': balance_change, 'percentage_change': percentage_change})

@app.route('/getAutoOrders', methods=['POST'])
def getAutoOrders():
    username = request.json.get('username')
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    cursor = conn.cursor()
    query = f"SELECT * FROM auto_order WHERE username = '{username}'"
    cursor.execute(query)
    result = cursor.fetchall()
    conn.close()

    if result:
        columns = [col[0] for col in cursor.description]
        data = [dict(zip(columns, row)) for row in result]

        # แก้ไขข้อมูลคอลัมน์ Date ใน data เป็นสตริงในรูปแบบที่กำหนด
        for entry in data:
            entry['Date'] = entry['Date'].strftime('%Y-%m-%d %H:%M:%S')

        json_data = json.dumps(data)  # แปลงเป็น JSON string
        print(json_data)
        return json_data
    else:
        return jsonify({"message": "No auto orders found for the username."})


@app.route('/place_order', methods=['POST'])
def place_order():
    username = request.json.get('username')
    symbol = request.json.get('symbol')
    qty = request.json.get('qty')
    side = request.json.get('side')
    type = request.json.get('type')
    time_in_force = request.json.get('time_in_force')

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()
    print(result)
    # Create the Alpaca REST API client
    api = REST(result[0], result[1], base_url='https://paper-api.alpaca.markets')
    print(symbol,qty,side,type,time_in_force)
    try:
        api.submit_order(
            symbol=symbol,
            qty=qty,
            side=side,
            type=type,
        )
        print('คำสั่งซื้อถูกส่งไปยัง Alpaca API แล้ว')
        return jsonify('success')
    except Exception as e:
        print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
        return jsonify(f'error: {str(e)}')
    

@app.route('/position', methods=['POST'])
def get_positions():
    username = request.json.get('username')
    print(username)
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()
    print(result)
    # Create the Alpaca REST API client
    api = REST(result[0], result[1], base_url='https://paper-api.alpaca.markets')
    portfolio = api.list_positions()

    print(portfolio)
    positions = []
    for position in portfolio:
        position_data = {
            'symbol': position.symbol,
            'market_value': "%.2f"%float(position.market_value),
            'avg_entry_price': "%.2f"%float(position.avg_entry_price),
            'quantity': position.qty_available,
            'unrealized_pl': position.unrealized_pl,
            'unrealized_plpc': position.unrealized_plpc
        }
        print(type(position.unrealized_pl))
        positions.append(position_data)
    
    return jsonify(positions)

"""@app.route('/streamPrice', methods=['POST'])
async def connect_to_alpaca():
    symbol = request.json.get('symbol')
    api = "PK8NXGV44WWTJA356CDG"
    secret = "nR9ySdpMSTKbnflGrJaBueH3EVCJ9fRV9gxOhnod"
    uri = "wss://stream.data.alpaca.markets/v2/iex"
    auth_message = {
        "action": "auth",
        "key": api,
        "secret": secret
    }
    subscribe_message = {
        "action": "subscribe",
        "quotes": [symbol]
    }

    async with websockets.connect(uri) as websocket:
        await websocket.send(json.dumps(auth_message))
        print("Authentication sent")

        auth_response = await websocket.recv()
        print("Authentication response:", auth_response)

        await websocket.send(json.dumps(subscribe_message))
        print("Subscription sent")

        while True:
            data = await websocket.recv()
            if data == "":
                print("Connection closed")
                break
            print("Received data:", data)
    asyncio.get_event_loop().run_until_complete(connect_to_alpaca())"""

@app.route('/autotradeRSI', methods=['POST'])
def autotradeRSI():
    username = request.json.get('username')
    lowerRSI = float(request.json.get('lowerRSI'))
    symbol = request.json.get('symbol')
    qty = float(request.json.get('qty')) #"0.0002"
    side = request.json.get('side')
    type = "market"
    time_in_force = "gtc"

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    print(result)
    # Create the Alpaca REST API client
    api = REST(result[0], result[1], base_url='https://paper-api.alpaca.markets')
    print(symbol,qty,side,type,time_in_force)
    insert_query = "INSERT INTO auto_order (username, symbol, techniques, quantity, side) VALUES (%s, %s, %s, %s, %s)"
    techniques = f"RSI<{lowerRSI}"
    data = (username, symbol, techniques, qty, side)
    print(symbol,qty,side,type,time_in_force)
    handler = TA_Handler(
        symbol=symbol,
        screener="Crypto",
        exchange="Binance",
        interval="1m"
    )
    cursor.execute(insert_query, data)
    print(cursor)
    conn.commit()
    while True:
        print(handler.get_analysis().indicators["RSI"])
        if handler.get_analysis().indicators["RSI"] <= lowerRSI:
            try:
                api.submit_order(
                symbol=symbol,
                qty=qty,
                side=side,
                type=type,
                time_in_force=time_in_force           
            )
               
                return jsonify('autotrade success')
            except Exception as e:
                return jsonify(f'error: {str(e)}')
            # เพิ่มโค้ดที่ต้องการเมื่อตรงเงื่อนไขการซื้อหุ้น

@app.route('/autotradeMACD', methods=['POST'])
def autotradeMACD():
    username = request.json.get('username')
    symbol = request.json.get('symbol')
    qty = float(request.json.get('qty')) #"0.0002"
    zone = float(request.json.get('zone')) #"0.00"
    cross = bool(request.json.get('cross_macd')) #True/False
    side = request.json.get('side')
    type = "market"
    time_in_force = "gtc"


    last_macd = 0
    last_signal = 0

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    print(result)
    # Create the Alpaca REST API client
    api = REST(result[0], result[1], base_url='https://paper-api.alpaca.markets')
    print(symbol,qty,side,type,time_in_force,zone,cross) 

    
    handler = TA_Handler(
        symbol=symbol,
        screener="Crypto",
        exchange="Binance",
        interval="1m"
    )

    if side == 'buy':
        if cross:
            while True:
                macd = handler.get_analysis().indicators["MACD.macd"]
                signal = handler.get_analysis().indicators["MACD.signal"]

                print("Last MACD: ", last_macd)
                print("Last Signal: ", last_signal)
                print("MACD: ", macd)
                print("Signal: ", signal)

                if (last_macd < last_signal and macd > signal) and (macd and signal < 0):
                    try:
                        api.submit_order(
                        symbol=symbol,
                        qty=qty,
                        side='buy',
                        type='market',
                        time_in_force='gtc'        
                    )
                        print(f'Buy at MACD: {macd},Signal: {signal},Qty: {qty}')
                        return jsonify('autotrade success')
                    except Exception as e:
                        print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
                        return jsonify(f'error: {str(e)}')

                last_macd = macd
                last_signal = signal
                print()
                time.sleep(5)
        else:
            while True:
                macd = handler.get_analysis().indicators["MACD.macd"]
                signal = handler.get_analysis().indicators["MACD.signal"]

                print("Last MACD: ", last_macd)
                print("Last Signal: ", last_signal)
                print("MACD: ", macd)
                print("Signal: ", signal)

                if macd and signal < zone:
                    try:
                        api.submit_order(
                        symbol=symbol,
                        qty=qty,
                        side='buy',
                        type='market',
                        time_in_force='gtc'        
                    )
                        return jsonify('autotrade success')
                    except Exception as e:
                        print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
                        return jsonify(f'error: {str(e)}')

                last_macd = macd
                last_signal = signal
                print()
                time.sleep(5)
            
    else:
        if cross:
            while True:
                macd = handler.get_analysis().indicators["MACD.macd"]
                signal = handler.get_analysis().indicators["MACD.signal"]

                print("Last MACD: ", last_macd)
                print("Last Signal: ", last_signal)
                print("MACD: ", macd)
                print("Signal: ", signal)
                if (last_macd > last_signal and macd < signal) and (macd and signal > 0):
                    try:
                        api.submit_order(
                        symbol=symbol,
                        qty=qty,
                        side='sell',
                        type=type,
                        time_in_force=time_in_force           
                    )
                        delete_query = f"DELETE FROM auto_order WHERE username = '{username}' AND symbol = '{symbol}'  AND techniques = '{techniques}' AND quantity = {qty} AND side = '{side}'"
                        print(delete_query)
                        cursor.execute(delete_query)
                        conn.commit()
                        cursor.close()
                        conn.close()
                        return jsonify('autotrade success')
                    except Exception as e:
                        return jsonify(f'error: {str(e)}') 
                    # เพิ่มโค้ดที่ต้องการเมื่อตรงเงื่อนไขการซื้อหุ้น 
        else:
            while True:
                macd = handler.get_analysis().indicators["MACD.macd"]
                signal = handler.get_analysis().indicators["MACD.signal"]

                print("Last MACD: ", last_macd)
                print("Last Signal: ", last_signal)
                print("MACD: ", macd)
                print("Signal: ", signal)

                if macd and signal > zone:
                    try:
                        api.submit_order(
                        symbol=symbol,
                        qty=qty,
                        side='sell',
                        type='market',
                        time_in_force='gtc'        
                    )
                        return jsonify('autotrade success')
                    except Exception as e:
                        return jsonify(f'error: {str(e)}')            
                                 
                last_macd = macd
                last_signal = signal
                print()
                time.sleep(5)

@app.route('/autotradeSTO', methods=['POST'])
def autotradeSTO():
    username = request.json.get('username')
    symbol = request.json.get('symbol')
    qty = float(request.json.get('qty')) #"0.0002"
    zone_sto = float(request.json.get('zone')) #"0.00"
    cross_sto = float(request.json.get('cross_sto')) 
    side = request.json.get('side')
    type = "market"
    time_in_force = "gtc"


    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    print(result)
    # Create the Alpaca REST API client
    api = REST(result[0], result[1], base_url='https://paper-api.alpaca.markets')
    print(symbol,qty,side,type,time_in_force,zone_sto,cross_sto)

    
    handler = TA_Handler(
        symbol="BTCUSD",
        screener="Crypto",
        exchange="Binance",
        interval="1m"
    )

    if side == 'buy':
        if cross_sto>0:
            print("cross buy")
            while True:
                sto_k = handler.get_analysis().indicators["Stoch.K"]
                sto_d = handler.get_analysis().indicators["Stoch.D"]
                last_sto_k = handler.get_analysis().indicators["Stoch.K[1]"]
                last_sto_d = handler.get_analysis().indicators["Stoch.D[1]"]
                print("Last K: ", last_sto_k)
                print("Last D: ", last_sto_d)
                print("K: ", sto_k)
                print("D: ", sto_d)
                if sto_k < cross_sto and sto_d < cross_sto and sto_k > sto_d and last_sto_k < last_sto_d:
                    try:
                        api.submit_order(
                        symbol=symbol,
                        qty=qty,
                        side='buy',
                        type='market',
                        time_in_force='gtc'        
                    )
                        print('คำสั่งซื้อถูกส่งไปยัง Alpaca API แล้ว')
                    except Exception as e:
                        print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
                    break
                time.sleep(5)
        else:
            print("zone buy")
            while True:
                sto_k = handler.get_analysis().indicators["Stoch.K"]
                sto_d = handler.get_analysis().indicators["Stoch.D"]
                last_sto_k = handler.get_analysis().indicators["Stoch.K[1]"]
                last_sto_d = handler.get_analysis().indicators["Stoch.D[1]"]

                print("Last K: ", last_sto_k)
                print("Last D: ", last_sto_d)
                print("K: ", sto_k)
                print("D: ", sto_d)

                if sto_k <= zone_sto and sto_d <= zone_sto:
                    try:
                        api.submit_order(
                        symbol=symbol,
                        qty=qty,
                        side='buy',
                        type='market',
                        time_in_force='gtc'        
                    )
                        print('คำสั่งซื้อถูกส่งไปยัง Alpaca API แล้ว')
                    except Exception as e:
                        print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
                    break
                time.sleep(5)
            
    else: #sell
        if cross_sto>0:
            print("cross sell")
            while True:
                sto_k = handler.get_analysis().indicators["Stoch.K"]
                sto_d = handler.get_analysis().indicators["Stoch.D"]
                last_sto_k = handler.get_analysis().indicators["Stoch.K[1]"]
                last_sto_d = handler.get_analysis().indicators["Stoch.D[1]"]
                print("Last K: ", last_sto_k)
                print("Last D: ", last_sto_d)
                print("K: ", sto_k)
                print("D: ", sto_d)
                if sto_k > cross_sto and sto_d > cross_sto and sto_k < sto_d and last_sto_k > last_sto_d:
                    try:
                        api.submit_order(
                        symbol=symbol,
                        qty=qty,
                        side='sell',
                        type='market',
                        time_in_force='gtc'        
                    )
                        print('คำสั่งซื้อถูกส่งไปยัง Alpaca API แล้ว')
                    except Exception as e:
                        print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
                    break
                time.sleep(5)
        else:
            print("zone sell")
            while True:
                sto_k = handler.get_analysis().indicators["Stoch.K"]
                sto_d = handler.get_analysis().indicators["Stoch.D"]
                last_sto_k = handler.get_analysis().indicators["Stoch.K[1]"]
                last_sto_d = handler.get_analysis().indicators["Stoch.D[1]"]

                print("Last K: ", last_sto_k)
                print("Last D: ", last_sto_d)
                print("K: ", sto_k)
                print("D: ", sto_d)

                if sto_k >= zone_sto and sto_d >= zone_sto:
                    try:
                        api.submit_order(
                        symbol=symbol,
                        qty=qty,
                        side='buy',
                        type='market',
                        time_in_force='gtc'        
                    )
                        print('คำสั่งซื้อถูกส่งไปยัง Alpaca API แล้ว')
                    except Exception as e:
                        print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
                    break
                time.sleep(5)
    return jsonify('autotrade success')

@app.route('/autotradeEMA', methods=['POST'])
def autotradeEMA():
    username = request.json.get('username')
    symbol = request.json.get('symbol')
    qty = float(request.json.get('qty')) #"0.0002"
    day = request.json.get('day') #"0.0002"
    side = request.json.get('side')
    type = "market"
    time_in_force = "gtc"

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    print(result)
    # Create the Alpaca REST API client
    api = REST(result[0], result[1], base_url='https://paper-api.alpaca.markets')
    print(symbol,qty,side,type,time_in_force)

    handler = TA_Handler(
        symbol="BTCUSD",
        screener="Crypto",
        exchange="Binance",
        interval="1m"
    )
    if side == 'buy':
        while True:
            ema = handler.get_analysis().indicators[f"EMA{day}"]
            close = handler.get_analysis().indicators["close"]
            if close <= ema and last_close > last_ema:
                try:
                    api.submit_order(
                    symbol=symbol,
                    qty=qty,
                    side='buy',
                    type='market',
                    time_in_force='gtc'        
                )
                    print('คำสั่งซื้อถูกส่งไปยัง Alpaca API แล้ว')           
                except Exception as e:
                    print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
                break
            last_ema = ema
            last_close = close
            time.sleep(5)
    else:
         while True:
            ema = handler.get_analysis().indicators[f"EMA{day}"]
            close = handler.get_analysis().indicators["close"]
            if close >= ema and last_close < last_ema:
                try:
                    api.submit_order(
                    symbol=symbol,
                    qty=qty,
                    side='sell',
                    type='market',
                    time_in_force='gtc'        
                )
                    print('คำสั่งขายถูกส่งไปยัง Alpaca API แล้ว')
                except Exception as e:
                    print(f'เกิดข้อผิดพลาดในการส่งคำสั่งขาย: {str(e)}')
                break
            last_ema = ema
            last_close = close
            time.sleep(5)
    return jsonify('autotrade success')

@app.route('/getStockPriceUS', methods=['POST'])
def getStockPriceUS():
    username = request.json.get('username')
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    cursor = conn.cursor()
    query = f"SELECT watchlist FROM users_info WHERE username = '{username}'"
    cursor.execute(query)
    result = cursor.fetchone()
    
    if result is not None:
        watchlist_json = result[0]
        stock_list = json.loads(watchlist_json) if watchlist_json else []
        prices = []
        if stock_list == []:
            return jsonify({'error': 'Empty'})
        else:
            for symbol in stock_list:
                try:
                    handler = TA_Handler(symbol=symbol, screener="america", exchange="NASDAQ", interval="1d")
                    analysis = handler.get_analysis()
                except Exception:
                    try:
                        handler = TA_Handler(symbol=symbol, screener="america", exchange="NYSE", interval="1d")
                        analysis = handler.get_analysis()
                    except Exception:
                        # เพิ่มการจัดการสำหรับ Exception อื่น ๆ ที่คุณต้องการ
                        handler = TA_Handler(symbol=symbol, screener="thailand", exchange="SET", interval="1d")
                        analysis = handler.get_analysis()

                close_price = round(analysis.indicators["close"], 2)
                percentage_change = round(analysis.indicators["change"], 2)

                prices.append({
                    'symbol': symbol,
                    'price': close_price,
                    'percentage': percentage_change
                })
                
            return jsonify(prices)


@app.route('/checkMarketStatus', methods=['POST'])
def checkMarketStatus():
    # กำหนดคีย์และตัวระบุสำหรับเข้าถึง Alpaca API
    API_KEY = 'PK8NXGV44WWTJA356CDG'
    API_SECRET = 'nR9ySdpMSTKbnflGrJaBueH3EVCJ9fRV9gxOhnod'
    APCA_API_BASE_URL = 'https://paper-api.alpaca.markets'

    # ส่งคำสั่งซื้อ
    api = tradeapi.REST(API_KEY, API_SECRET,
                        APCA_API_BASE_URL, api_version='v2')

    # Check if the market is open now.
    clock = api.get_clock()
    return jsonify('{}'.format('open' if clock.is_open else 'closed'))

@app.route('/news', methods=['GET'])
def news():
    url = 'https://data.alpaca.markets/v1beta1/news?limit=15&exclude_contentless=true'
    headers = {
        'Apca-Api-Key-Id': 'PK8NXGV44WWTJA356CDG',
        'Apca-Api-Secret-Key': 'nR9ySdpMSTKbnflGrJaBueH3EVCJ9fRV9gxOhnod'
    }

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        news_data = response.json()
        news_list = news_data.get('news', [])
        
        output_data = []
        
        for news_item in news_list:
            source = news_item.get('author')
            headline = news_item.get('headline')
            symbol = ', '.join(news_item.get('symbols', []))
            news_url = news_item.get('url')
            news_response = requests.get(news_url)
            soup = BeautifulSoup(news_response.content, 'html.parser')
            paragraphs = soup.find_all("p", class_="core-block")[:5]
            description_combined = '\n'.join(paragraph.get_text(strip=True) for paragraph in paragraphs)

            large_images = next((image.get('url') for image in news_item.get('images', []) if image.get('size') == 'large'), '')
            
            news_entry = {
                "Author": source,
                "Headline": headline,
                "Symbols": symbol,
                "URL": news_url,
                "Image": large_images,
                "Description": description_combined
            }
            output_data.append(news_entry)
        return jsonify(output_data)
        
    else:
        return jsonify({"message": "Failed to fetch news. Status code:", "status_code": response.status_code})
    
@app.route('/th_portfolio', methods= ['POST'])
def th_portfolio():
    
    username = request.json.get('username')

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT th_api_key, th_secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    app_id, app_secret = result

    investor = Investor(
        app_id=app_id,
        app_secret=app_secret,
        broker_id="SANDBOX",
        app_code="SANDBOX",
        is_auto_queue=False
    )

    equity = investor.Equity(account_no=f"{username}-E")

    account_info = equity.get_account_info()
    portfolio = equity.get_portfolios()

    cashBalance = account_info.get('cashBalance')
    portfolio_profit = portfolio['totalPortfolio']['profit']
    percentageChange = (portfolio_profit / cashBalance) * 100
        
    cash = CurrencyRates().get_rate('THB', 'USD')
    USDtoTHB = CurrencyRates().get_rate('USD', 'THB')
    print(type(USDtoTHB))
    balance = f"{cashBalance * cash:.2f}"
    balanceProfitChange = f"{portfolio_profit * cash:.2f}"
    lineAvailable = f"{account_info.get('lineAvailable') * cash:.2f}"
    marketValue = f"{portfolio['totalPortfolio']['marketValue'] * cash:.2f}"
    print(balance)
    portfolio_list = []
    for item in portfolio['portfolioList']:
        portfolio_list.append({
            'symbol': item['symbol'],
            'averagePrice': item['averagePrice'],
            'amount': item['amount'],
            'actualVolume': item['actualVolume'],
            'profit': item['profit'],
            'percentProfit': item['percentProfit'],
        })
    
    result = {
        'balance': balance,
        'percentageChange': percentageChange,
        'balanceProfitChange': balanceProfitChange,
        'lineAvailable': lineAvailable,
        'marketValue': marketValue,
        'portfolioList': portfolio_list,
        'USDtoTHB' : USDtoTHB
    }

    return jsonify(result)



@app.route('/place_order_th', methods=['POST'])
def place_order_th():
    username = request.json.get('username')
    symbol = request.json.get('symbol')
    qty = request.json.get('qty')
    side = request.json.get('side')
    limitPrice = request.json.get('limitPrice')

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT th_api_key, th_secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()
    print(result)
    investor = Investor(
                app_id=result[0],                                 
                app_secret=result[1], 
                broker_id="SANDBOX",
                app_code="SANDBOX",
                is_auto_queue = False)

    equity = investor.Equity(account_no="foczz123-E")     
    try:
        place_order = equity.place_order(
                                side= side,
                                symbol= symbol,
                                volume= qty,
                                price = limitPrice,
                                price_type= "Limit",
                                pin= "000000"
                                )
        print('คำสั่งซื้อขายถูกส่งไปยัง Settrade Sandbox แล้ว')
        return jsonify('success')
    except Exception as e:
        print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
        return jsonify(f'error: {str(e)}')


if __name__ == '__main__':
    app.run(host="0.0.0.0")