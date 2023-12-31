import time
import MySQLdb
from flask_mysqldb import MySQL
from flask import Flask, request, jsonify
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
from tradingview_ta import TA_Handler
from settrade_v2 import Investor
from bs4 import BeautifulSoup
import random



app = Flask(__name__)
app.config['MYSQL_HOST'] = 'localhost'  # หรือ hostname ของเซิร์ฟเวอร์ MySQL
app.config['MYSQL_USER'] = 'root'  # ชื่อผู้ใช้งานฐานข้อมูล
app.config['MYSQL_PASSWORD'] = ''  # รหัสผ่านของผู้ใช้งานฐานข้อมูล
app.config['MYSQL_DB'] = 'walltrade'  # ชื่อฐานข้อมูล
CORS(app)
mysql = MySQL(app)


@app.route('/predict', methods=['POST'])
def predict():
    dataList = request.get_json() 
    symbol_list = dataList.get('dataList', [],)  # แปลงข้อมูล JSON เป็น List
    
    list_dict = []
    prediction_day = 60

    for symbol in symbol_list:
        data = yf.download(symbol, period="3y")
        scaler = MinMaxScaler(feature_range=(0, 1))
        scaled_data = scaler.fit_transform(data['Close'].values.reshape(-1, 1))
        x_train = []
        y_train = []
        for x in range(prediction_day, len(scaled_data)):
            x_train.append(scaled_data[x-prediction_day:x, 0])
            y_train.append(scaled_data[x, 0])
    
        x_train, y_train = np.array(x_train), np.array(y_train)
        x_train = np.reshape(x_train, (x_train.shape[0], x_train.shape[1], 1))

        model = Sequential()
        model.add(LSTM(units=50, return_sequences=True,input_shape=(x_train.shape[1], 1)))
        model.add(Dropout(0.2))
        model.add(LSTM(units=50, return_sequences=True))
        model.add(Dropout(0.2))
        model.add(LSTM(units=50))
        model.add(Dropout(0.2))
        model.add(Dense(units=1))
        model.compile(optimizer='adam', loss='mean_squared_error')
        
        model.fit(x_train, y_train, epochs=25, batch_size=256)

        test_start = dt.datetime(2012, 1, 1)
        test_end = dt.datetime.now()
        test_data = yf.download(symbol, test_start, test_end)
        total_dataset = pd.concat((data['Close'], test_data['Close']), axis=0)
        model_inputs = total_dataset[len(
        total_dataset)-len(test_data) - prediction_day:].values
        model_inputs = model_inputs.reshape(-1, 1)
        model_inputs = scaler.transform(model_inputs)

        x_test = []
        for x in range(prediction_day, len(model_inputs)):
            x_test.append(model_inputs[x-prediction_day:x, 0])
        x_test = np.array(x_test)
        x_test = np.reshape(x_test, (x_test.shape[0], x_test.shape[1], 1))

        predicted_prices = model.predict(x_test)
        predicted_prices = scaler.inverse_transform(predicted_prices)

        # + 1 - predict Next day
        real_data = [
            model_inputs[len(model_inputs) + 1 - prediction_day:len(model_inputs+1), 0]]
        real_data = np.array(real_data)
        real_data = np.reshape(
            real_data, (real_data.shape[0], real_data.shape[1], 1))
        
        
        prediction = model.predict(real_data)
        prediction = scaler.inverse_transform(prediction)

        if symbol.endswith('.BK'):
            symbols = symbol.rstrip(".BK") 
            analysis = getSymbolHandler(symbols,"1D")
        else:
            analysis = getSymbolHandler(symbol,"1D")

        close = analysis.indicators['close']
        # หาค่าราคาที่ทำนายของ 10 วันสุดท้าย
        predicted_prices = predicted_prices[-180:]
        predicted_prices = predicted_prices.reshape(-1)
        real_prices = data['Close'][-180:]

        real_prices_list = real_prices.tolist()
        predicted_prices = np.append(predicted_prices, prediction[0][0])
        print(prediction[0][0])
        predicted_prices_list = predicted_prices.tolist()
        print("predict length",len(predicted_prices_list))
        print("real length",len(real_prices_list))

        result_dict = {
            'symbol': symbol,
            'prediction': float(prediction[0][0]),
            'close' : float(close),
            'real_prices_chart': real_prices_list,
            'predict_prices_chart': predicted_prices_list
        }

        #Append the dictionary to the list
        list_dict.append(result_dict)

    return jsonify(list_dict)


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
    
@app.route('/getUsernamefromEmail', methods=['POST'])
def getUsernamefromEmail():
    try:
        # Get data from request
        email = request.json.get('email')
        print(email)

        # Establish connection to MySQL database
        conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
        cursor = conn.cursor()

        # Check if username already exists
        query = "SELECT username FROM users_info WHERE email = %s"
        cursor.execute(query, (email,))
        
        # Fetch the result
        result = cursor.fetchone()

        # Close the database connection
        conn.close()

        if result:
            # If a result is found, return the username
            username = result[0]
            print(username)
            return jsonify({'username': username})
            
        else:
            return jsonify({'error': 'Email not found'})

    except Exception as e:
        return jsonify({'error': str(e)})

@app.route('/checkEmailExist', methods=['POST'])
def checkEmailExist():
    email = request.json['email']
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    cursor = conn.cursor()
    
    # Check if email already exists
    query = "SELECT * FROM users_info WHERE Email = %s"
    cursor.execute(query, (email,))
    existing_user = cursor.fetchone()

    if existing_user:
        response = {
            'message': 'Email already exists'
        }
        return jsonify(response), 200
    else:
        response = {
            'message': 'Email does not exist',
            'email': email,
        }
        return jsonify(response), 400

    
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
        query = "SELECT * FROM users_info WHERE username = %s AND Email = %s"
        cursor.execute(query, (username,email))
        existing_user = cursor.fetchone()

        if existing_user:
            # Close cursor and connection
            cursor.close()
            conn.close()

            # Return error response as JSON
            response = {
                'message': 'Username & E-mail already exists'
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
    
@app.route('/updateAPI', methods=['POST'])
def updateAPI():
    api_key = request.form['api_key']
    secret_key = request.form['secret_key']
    th_api_key = request.form['th_api_key']
    th_secret_key = request.form['ath_secret_key']
    username = request.form['username'] 

    cur = mysql.connection.cursor()
    cur.execute("""
        UPDATE users_info SET api_key=%s, secret_key=%s, th_api_key=%s, th_secret_key=%s WHERE username = %s
    """, (api_key, secret_key, th_api_key, th_secret_key, username))
    mysql.connection.commit()
    cur.close()

    return jsonify({'message': 'Update Success'})

@app.route('/asset_list', methods=['GET'])
def get_asset_list():
    api = tradeapi.REST(
        key_id='PKPZNZ5UPZP41MZUUYXF',
        secret_key='fajFEMpQSTE31NaQOUX3USwkWkl67oAtDERjRmmK',
        base_url='https://paper-api.alpaca.markets'
    )

    # Get a list of all active assets.
    active_assets = api.list_assets(status='active',)

    # Filter the assets down to just those on NASDAQ.
    nasdaq_assets = [a for a in active_assets if (a.exchange == 'NASDAQ' or a.exchange == 'NYSE') and a.tradable and '.' not in a.symbol]

    # Create a list of dictionaries containing name and symbol of each NASDAQ asset.
    asset_list = [{'Name': a.name, 'Symbol': a.symbol} for a in nasdaq_assets]
    print(len(asset_list))
    # Return the asset list as JSON.
    return jsonify(assets=asset_list)

@app.route('/displayWatchlist', methods=['POST'])
def displayWatchlist():
    username = request.json.get('username')
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    cursor = conn.cursor()
    query = f"SELECT watchlist FROM users_info WHERE username = '{username}'"
    cursor.execute(query)
    result = cursor.fetchone()
    
    if result is not None:
        watchlist_json = result[0]
        stock_list = json.loads(watchlist_json) if watchlist_json else []      
    return jsonify(stock_list)



@app.route('/thStockList', methods=['GET'])
def thStockList():
    thai_stocks = {
    "ADVANC": "บริษัท แอดวานซ์ อินโฟร์ เซอร์วิส จำกัด (มหาชน)",
    "AOT": "บริษัท ท่าอากาศยานไทย จำกัด (มหาชน)",
    "BBL": "ธนาคารกรุงเทพ จำกัด (มหาชน)",
    "BCP": "บริษัท บางจาก คอร์ปอเรชั่น จำกัด (มหาชน)",
    "BDMS": "บริษัท กรุงเทพดุสิตเวชการ จำกัด (มหาชน)",
    "BEM": "บริษัท ทางด่วนและรถไฟฟ้ากรุงเทพ จำกัด (มหาชน)",
    "BGRIM": "บริษัท บี.กริม เพาเวอร์ จำกัด (มหาชน)",
    "BH": "บริษัท โรงพยาบาลบำรุงราษฎร์ จำกัด (มหาชน)",
    "BJC": "บริษัท เบอร์ลี่ ยุคเกอร์ จำกัด (มหาชน)",
    "BPP": "บริษัท บ้านปู เพาเวอร์ จำกัด (มหาชน)",
    "BTS": "บริษัท บีทีเอส กรุ๊ป โฮลดิ้งส์ จำกัด (มหาชน)",
    "CBG": "บริษัท คาราบาวกรุ๊ป จำกัด (มหาชน)",
    "CENTEL": "บริษัท โรงแรมเซ็นทรัลพลาซา จำกัด (มหาชน)",
    "CK": "บริษัท ช.การช่าง จำกัด (มหาชน)",
    "CPALL": "บริษัท ซีพี ออลล์ จำกัด (มหาชน)",
    "CPF": "บริษัท เจริญโภคภัณฑ์อาหาร จำกัด (มหาชน)",
    "CPN": "บริษัท เซ็นทรัลพัฒนา จำกัด (มหาชน)",
    "CRC": "บริษัท เซ็นทรัล รีเทล คอร์ปอเรชั่น จำกัด (มหาชน)",
    "DELTA": "บริษัทเดลต้า อีเลคโทรนิคส์ (ประเทศไทย) จำกัด (มหาชน)",
    "EA": "บริษัท พลังงานบริสุทธิ์ จำกัด (มหาชน)",
    "EGCO": "บริษัท ผลิตไฟฟ้า จำกัด (มหาชน)",
    "GGC": "บริษัท โกลบอลกรีนเคมิคอล จำกัด (มหาชน)",
    "GPSC": "บริษัท โกลบอล เพาเวอร์ ซินเนอร์ยี่ จำกัด (มหาชน)",
    "GULF": "บริษัท กัลฟ์ เอ็นเนอร์จี ดีเวลลอปเมนท์ จำกัด (มหาชน)",
    "HANA": "บริษัท ฮานา ไมโครอิเล็คโทรนิคส จำกัด (มหาชน)",
    "IRPC": "บริษัท ไออาร์พีซี จำกัด (มหาชน)",
    "IVL": "บริษัท อินโดรามา เวนเจอร์ส จำกัด (มหาชน)",
    "KBANK": "ธนาคารกสิกรไทย จำกัด (มหาชน)",
    "KCE": "บริษัท เคซีอี อีเลคโทรนิคส์ จำกัด (มหาชน)",
    "KKP": "ธนาคารเกียรตินาคินภัทร จำกัด (มหาชน)",
    "KTB": "ธนาคารกรุงไทย จำกัด (มหาชน)",
    "LH": "บริษัทแลนด์แอนด์เฮ้าส์ จำกัด (มหาชน)",
    "M": "บริษัท เอ็มเค เรสโตรองต์ กรุ๊ป จำกัด (มหาชน)",
    "MAJOR": "บริษัท เมเจอร์ ซีนีเพล็กซ์ กรุ้ป จำกัด (มหาชน)",
    "OR": "บริษัท ปตท. น้ำมันและการค้าปลีก จำกัด (มหาชน)",
    "PTT": "บริษัท ปตท. จำกัด (มหาชน)",
    "PTTEP": "บริษัท ปตท. สำรวจและผลิตปิโตรเลียม จำกัด (มหาชน)",
    "PTTGC": "บริษัท พีทีที โกลบอล เคมิคอล จำกัด (มหาชน)",
    "S": "บริษัท สิงห์ เอสเตท จำกัด (มหาชน)",
    "SAMART": "บริษัท สามารถคอร์ปอเรชั่น จำกัด (มหาชน)",
    "SAWAD": "บริษัท ศรีสวัสดิ์ คอร์ปอเรชั่น จำกัด (มหาชน)",
    "SCB": "บริษัท เอสซีบี เอกซ์ จำกัด (มหาชน)",
    "SCC": "บริษัท ปูนซิเมนต์ไทย จำกัด(มหาชน)",
    "SCP": "บริษัท ทักษิณคอนกรีต จำกัด (มหาชน)",
    "SCGP": "บริษัท เอสซีจี แพคเกจจิ้ง จำกัด (มหาชน)",
    "SIRI": "บริษัท แสนสิริ จำกัด (มหาชน)",
    "SPALI": "บริษัท ศุภาลัย จำกัด (มหาชน)",
    "SPRC": "บริษัท สตาร์ ปิโตรเลียม รีไฟน์นิ่ง จำกัด (มหาชน)",
    "STA": "บริษัท ศรีตรังแอโกรอินดัสทรี จำกัด (มหาชน)",
    "SUPER": "บริษัท ซุปเปอร์ เอนเนอร์ยี คอร์เปอเรชั่น จำกัด (มหาชน)",
    "TCAP": "บริษัท ทุนธนชาต จำกัด (มหาชน)",
    "THANI": "บริษัท ราชธานีลิสซิ่ง จำกัด (มหาชน)"
    }

    investor = Investor(
        app_id="jduRiuYHoFfCJ2Na",
        app_secret="UwyAQLrW5ic3ljn2bWzoC+9S0o9UlZvxGarfgZ0mTVk=",
        broker_id="SANDBOX",
        app_code="SANDBOX",
        is_auto_queue=False)
          
    mkt_data = investor.MarketData()
    stocks_list = []

    for symbol, full_name in thai_stocks.items():
        res = mkt_data.get_quote_symbol(symbol)
        stock_data = {'Symbol': res['symbol'], 'Fullname': full_name, 'Last': res['last']}
        stocks_list.append(stock_data)


    # ส่งข้อมูลในรูปแบบของ JSON
    return jsonify(stocks_list)


@app.route('/updateUSalpacaAPI', methods=['POST'])
def updateUSalpacaAPI():
    api_key = request.form['api_key']
    secret_key = request.form['secret_key']
    username = request.form['username'] # ชื่อผู้ใช้งานที่ต้องการแทรก

    cur = mysql.connection.cursor()
    cur.execute("""
        UPDATE users_info SET api_key=%s, secret_key=%s WHERE username = %s
    """, (api_key, secret_key, username))
    mysql.connection.commit()
    cur.close()

    return jsonify({'message': 'Update Success'})

@app.route('/updateTHsettradeAPI', methods=['POST'])
def updateTHsettradeAPI():
    th_api_key = request.form['th_api_key']
    th_secret_key = request.form['th_secret_key']
    username = request.form['username'] # ชื่อผู้ใช้งานที่ต้องการแทรก

    cur = mysql.connection.cursor()
    cur.execute("""
        UPDATE users_info SET th_api_key=%s, th_secret_key=%s WHERE username = %s
    """, (th_api_key, th_secret_key, username))
    mysql.connection.commit()
    cur.close()

    return jsonify({'message': 'Update Success'})
   

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
    limit_price = request.json.get('limit_price')
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
        if type == 'limit' and limit_price >0:
            api.submit_order(
                symbol=symbol,
                qty=qty,
                side=side,
                type=type,
                limit_price=limit_price,
                time_in_force=time_in_force
            )
            print('คำสั่งซื้อถูกส่งไปยัง Alpaca API แล้ว')
            return jsonify('success')
        else:
            api.submit_order(
                symbol=symbol,
                qty=qty,
                side=side,
                type=type,
                time_in_force=time_in_force
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
        positions.append(position_data)
    
    return jsonify(positions)

@app.route('/autotradeRSI', methods=['POST'])
def autotradeRSI():
    username = request.json.get('username') #foczz123
    lowerRSI = float(request.json.get('lowerRSI')) #36.5
    symbol = request.json.get('symbol') #META
    qty = float(request.json.get('qty')) #0.5
    side = request.json.get('side') #buy
    type = "market"
    interval = request.json.get('interval') #1D
    time_in_force = "gtc"

    if interval == '1h':
        wait = 3600
    elif interval == '4h':
        wait = 14400
    elif interval == '1D':
        wait = 86400
    else:
        wait = 604800

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    while True:
        order_number = random.randrange(1, 100000)
        sql_check_duplicate = "SELECT COUNT(*) FROM auto_order WHERE OrderID = %s" 
        cursor.execute(sql_check_duplicate, (order_number,))
        count = cursor.fetchone()[0]
        if count == 0:
            order_number=order_number
            break

    print(result)
    # Create the Alpaca REST API client
    api = REST(result[0], result[1], base_url='https://paper-api.alpaca.markets')
    print(symbol,qty,side,type,time_in_force)
    insert_query = f"INSERT INTO auto_order (OrderID , username, symbol, techniques, quantity, side, timeframe, status) VALUES ({order_number},%s, %s, %s, %s, %s, %s,'pending')"
    if side == "buy":
        techniques = f"RSI < {lowerRSI}"
    else:
        techniques = f"RSI > {lowerRSI}"
    data = (username, symbol, techniques, qty, side, interval)
    print(symbol,qty,side,type,time_in_force)   
    cursor.execute(insert_query, data)
    print(cursor)
    conn.commit()

    analysis = getSymbolHandler(symbol,interval)
    
    if side == 'buy':
        while True:
            print(analysis.indicators["RSI"])
            checkStatus = checkStatusOrder(username=username,order_number=order_number)
            print(checkStatus)
            if checkStatus == 'cancelled':
                return jsonify('autotrade buy rsi cancelled')
            
            elif analysis.indicators["RSI"] <= lowerRSI:
                try:
                    api.submit_order(
                    symbol=symbol,
                    qty=qty,
                    side=side,
                    type=type,
                    time_in_force=time_in_force           
                )                
                    completeOrder(username=username,orderID=order_number)
                    return jsonify('autotrade buy success')
                except Exception as e:
                    return jsonify(f'error: {str(e)}')
            time.sleep(wait)
                
    else:
        while True:
             # Check the status in localhost and break the loop if it's 'completed'
            print("เข้าเงื่อนไขขาย RSI")
            checkStatus = checkStatusOrder(username=username,order_number=order_number)
            print(checkStatus)
            print(analysis.indicators["RSI"])
            if checkStatus == 'cancelled':
                return jsonify('autotrade sell rsi cancelled')
            
            elif analysis.indicators["RSI"] >= lowerRSI:
                try:
                    api.submit_order(
                    symbol=symbol,
                    qty=qty,
                    side=side,
                    type=type,
                    time_in_force=time_in_force           
                )
                    completeOrder(username=username,orderID=order_number)
                    return jsonify('autotrade sell success')
                except Exception as e:
                    return jsonify(f'error: {str(e)}')
            time.sleep(wait)

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
    interval = request.json.get('interval')

    if interval == '1h':
        wait = 3600
    elif interval == '4h':
        wait = 14400
    elif interval == '1D':
        wait = 86400
    else:
        wait = 604800


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

    analysis = getSymbolHandler(symbol=symbol,interval=interval)

    while True:
        order_number = random.randrange(1, 100000)
        sql_check_duplicate = "SELECT COUNT(*) FROM auto_order WHERE OrderID = %s" 
        cursor.execute(sql_check_duplicate, (order_number,))
        count = cursor.fetchone()[0]
        if count == 0:
            order_number=order_number
            break

    insert_query = f"INSERT INTO auto_order (OrderID , username, symbol, techniques, quantity, side, timeframe, status) VALUES ({order_number},%s, %s, %s, %s, %s, %s,'pending')"
    if side == "buy":
        if cross:
            techniques = f"MACD ตัดขึ้น Signal และ < 0"
        else:
            techniques = f"MACD & Signal < {zone}"
    else:
        if cross:
            techniques = f"MACD ตัดลง Signal และ > 0"
        else:
            techniques = f"MACD & Signal > {zone}"
    data = (username, symbol, techniques, qty, side,interval)
    print(symbol,qty,side,type,time_in_force)   
    cursor.execute(insert_query, data)
    print(cursor)
    conn.commit()

    if side == 'buy':
        if cross:
            while True:
                macd = analysis.indicators["MACD.macd"]
                signal = analysis.indicators["MACD.signal"]

                print("Last MACD: ", last_macd)
                print("Last Signal: ", last_signal)
                print("MACD: ", macd)
                print("Signal: ", signal)
                    
                checkStatus = checkStatusOrder(username=username,order_number=order_number)
                print(checkStatus)
                if checkStatus == 'cancelled':
                    return jsonify('autotrade buy macd cancelled')
                
                elif (last_macd < last_signal and macd > signal) and (macd and signal < 0):
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
                time.sleep(wait)
        else:
            while True:
                macd = analysis.indicators["MACD.macd"]
                signal = analysis.indicators["MACD.signal"]

                print("Last MACD: ", last_macd)
                print("Last Signal: ", last_signal)
                print("MACD: ", macd)
                print("Signal: ", signal)

                checkStatus = checkStatusOrder(username=username,order_number=order_number)
                print(checkStatus)
                if checkStatus == 'cancelled':
                    return jsonify('autotrade buy macd cancelled')
                
                elif macd and signal < zone:
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
                time.sleep(wait)
            
    else:
        if cross:
            while True:
                macd = analysis.indicators["MACD.macd"]
                signal = analysis.indicators["MACD.signal"]

                print("Last MACD: ", last_macd)
                print("Last Signal: ", last_signal)
                print("MACD: ", macd)
                print("Signal: ", signal)

                checkStatus = checkStatusOrder(username=username,order_number=order_number)
                print(checkStatus)
                if checkStatus == 'cancelled':
                    return jsonify('autotrade sell macd cancelled')
                
                elif (last_macd > last_signal and macd < signal) and (macd and signal > 0):
                    try:
                        api.submit_order(
                        symbol=symbol,
                        qty=qty,
                        side='sell',
                        type=type,
                        time_in_force=time_in_force           
                    )                      

                        return jsonify('autotrade success')
                    except Exception as e:
                        return jsonify(f'error: {str(e)}') 
                    # เพิ่มโค้ดที่ต้องการเมื่อตรงเงื่อนไขการซื้อหุ้น 
        else:
            while True:
                macd = analysis.indicators["MACD.macd"]
                signal = analysis.indicators["MACD.signal"]

                print("Last MACD: ", last_macd)
                print("Last Signal: ", last_signal)
                print("MACD: ", macd)
                print("Signal: ", signal)

                checkStatus = checkStatusOrder(username=username,order_number=order_number)
                print(checkStatus)
                if checkStatus == 'cancelled':
                    return jsonify('autotrade sell macd cancelled')
                
                elif macd and signal > zone:
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
                time.sleep(wait)

@app.route('/autotradeSTO', methods=['POST'])
def autotradeSTO():
    username = request.json.get('username') #foczz123
    symbol = request.json.get('symbol') #META
    qty = float(request.json.get('qty')) #"0.5"
    zone_sto = float(request.json.get('zone')) #"0.00"
    cross_sto = float(request.json.get('cross_sto')) 
    side = request.json.get('side')
    type = "market"
    time_in_force = "gtc"
    interval = request.json.get('interval')


    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    if interval == '1h':
        wait = 3600
    elif interval == '4h':
        wait = 14400
    elif interval == '1D':
        wait = 86400
    else:
        wait = 604800

    while True:
        order_number = random.randrange(1, 100000)
        sql_check_duplicate = "SELECT COUNT(*) FROM auto_order WHERE OrderID = %s" 
        cursor.execute(sql_check_duplicate, (order_number,))
        count = cursor.fetchone()[0]
        if count == 0:
            order_number=order_number
            break

    print(result)
    # Create the Alpaca REST API client
    api = REST(result[0], result[1], base_url='https://paper-api.alpaca.markets')
    print(symbol,qty,side,type,time_in_force,zone_sto,cross_sto)

    analysis = getSymbolHandler(symbol=symbol,interval=interval)

    insert_query = f"INSERT INTO auto_order (OrderID , username, symbol, techniques, quantity, side, timeframe, status) VALUES ({order_number},%s, %s, %s, %s, %s, %s,'pending')"
    if side == "buy":
        if cross_sto > 0:
            techniques = f"%K ตัดขึ้น %D และ < {cross_sto}"
        else:
            techniques = f"%K และ %D < {zone_sto}"
    else:
        if cross_sto > 0:
            techniques = f"%K ตัดลง %D และ > {cross_sto}"
        else:
            techniques = f"%K และ %D > {zone_sto}"
    data = (username, symbol, techniques, qty, side,interval)
    print(symbol,qty,side,type,time_in_force)   
    cursor.execute(insert_query, data)
    conn.commit()

    if side == 'buy':
        if cross_sto>0:
            print("cross buy")
            while True:
                sto_k = analysis.indicators["Stoch.K"]
                sto_d = analysis.indicators["Stoch.D"]
                last_sto_k = analysis.indicators["Stoch.K[1]"]
                last_sto_d = analysis.indicators["Stoch.D[1]"]
                print("Last K: ", last_sto_k)
                print("Last D: ", last_sto_d)
                print("K: ", sto_k)
                print("D: ", sto_d)

                checkStatus = checkStatusOrder(username=username,order_number=order_number)
                print(checkStatus)
                if checkStatus == 'cancelled':
                    return jsonify('autotrade sell sto cancelled')
                
                elif sto_k < cross_sto and sto_d < cross_sto and sto_k > sto_d and last_sto_k < last_sto_d:
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
                time.sleep(wait)
        else:
            print("zone buy")
            while True:
                sto_k = analysis.indicators["Stoch.K"]
                sto_d = analysis.indicators["Stoch.D"]
                last_sto_k = analysis.indicators["Stoch.K[1]"]
                last_sto_d = analysis.indicators["Stoch.D[1]"]

                print("Last K: ", last_sto_k)
                print("Last D: ", last_sto_d)
                print("K: ", sto_k)
                print("D: ", sto_d)

                checkStatus = checkStatusOrder(username=username,order_number=order_number)
                print(checkStatus)
                if checkStatus == 'cancelled':
                    return jsonify('autotrade sell sto cancelled')
                
                elif sto_k <= zone_sto and sto_d <= zone_sto:
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
                time.sleep(wait)
            
    else: #sell
        if cross_sto>0:
            print("cross sell")
            while True:
                sto_k = analysis.indicators["Stoch.K"]
                sto_d = analysis.indicators["Stoch.D"]
                last_sto_k = analysis.indicators["Stoch.K[1]"]
                last_sto_d = analysis.indicators["Stoch.D[1]"]
                print("Last K: ", last_sto_k)
                print("Last D: ", last_sto_d)
                print("K: ", sto_k)
                print("D: ", sto_d)

                checkStatus = checkStatusOrder(username=username,order_number=order_number)
                print(checkStatus)
                if checkStatus == 'cancelled':
                    return jsonify('autotrade sell sto cancelled')
                
                elif sto_k > cross_sto and sto_d > cross_sto and sto_k < sto_d and last_sto_k > last_sto_d:
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
                time.sleep(wait)
        else:
            print("zone sell")
            while True:
                sto_k = analysis.indicators["Stoch.K"]
                sto_d = analysis.indicators["Stoch.D"]
                last_sto_k = analysis.indicators["Stoch.K[1]"]
                last_sto_d = analysis.indicators["Stoch.D[1]"]

                print("Last K: ", last_sto_k)
                print("Last D: ", last_sto_d)
                print("K: ", sto_k)
                print("D: ", sto_d)

                checkStatus = checkStatusOrder(username=username,order_number=order_number)
                print(checkStatus)
                if checkStatus == 'cancelled':
                    return jsonify('autotrade sell sto cancelled')
                
                elif sto_k >= zone_sto and sto_d >= zone_sto:
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
                time.sleep(wait)
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
    interval = request.json.get('interval')

    if interval == '1h':
        wait = 3600
    elif interval == '4h':
        wait = 14400
    elif interval == '1D':
        wait = 86400
    else:
        wait = 604800

    print("DAY:",day)

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()
  
    print(result)
    # Create the Alpaca REST API client
    api = REST(result[0], result[1], base_url='https://paper-api.alpaca.markets')
    print(symbol,qty,side,type,time_in_force)

    while True:
        order_number = random.randrange(1, 100000)
        sql_check_duplicate = "SELECT COUNT(*) FROM auto_order WHERE OrderID = %s" 
        cursor.execute(sql_check_duplicate, (order_number,))
        count = cursor.fetchone()[0]
        if count == 0:
            order_number=order_number
            break
    anaylsis = getSymbolHandler(symbol=symbol,interval=interval)

    insert_query = f"INSERT INTO auto_order (OrderID , username, symbol, techniques, quantity, side, timeframe, status) VALUES ({order_number},%s, %s, %s, %s, %s, %s,'pending')"

    if side == "buy":
        techniques = f"ซื้อเมื่อราคา <= EMA{day}"
    else:
        techniques = f"ขายเมื่อราคา >= EMA{day}"

    data = (username, symbol, techniques, qty, side,interval)
    print(symbol,qty,side,type,time_in_force)   
    cursor.execute(insert_query, data)
    print("cursor:",cursor)
    conn.commit()

    last_ema=0
    last_close=0

    if side == 'buy':
        while True:
            ema = anaylsis.indicators[f"EMA{day}"]
            close = anaylsis.indicators["close"]
            checkStatus = checkStatusOrder(username=username,order_number=order_number)
            print(checkStatus)
            if checkStatus == 'cancelled':
                return jsonify('autotrade buy ema cancelled')
                
            elif close <= ema and last_close > last_ema:
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
            time.sleep(wait)
    else:
         while True:
            ema = anaylsis.indicators[f"EMA{day}"]
            close = anaylsis.indicators["close"]
            checkStatus = checkStatusOrder(username=username,order_number=order_number)
            print(checkStatus)
            if checkStatus == 'cancelled':
                return jsonify('autotrade sell ema cancelled')
                
            elif close >= ema and last_close < last_ema:
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
            time.sleep(wait)
    return jsonify('autotrade success')

@app.route('/getOneSymbolPrice', methods=['POST'])
def getOneSymbolPrice():
    symbol = request.json.get('symbol') 
    interval = request.json.get('interval') 
    prices = []
    analysis = getSymbolHandler(symbol,interval)
    close_price = float(round(analysis.indicators["close"], 2))
    percentage_change = float(round(analysis.indicators["change"], 2))
     
    prices.append({
        'symbol': symbol,
        'price': close_price,
        'percentage': percentage_change
    })
              
    return jsonify(prices)

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
                analysis = getSymbolHandler(symbol,"1D")
                thai_stocks = ["ADVANC", "AOT", "BBL",  "BCP","BDMS","BEM", "BGRIM", "BH","BJC","BPP", "BTS","CBG","CENTEL", "CK",  "CPALL", "CPF", "CPN", "CRC","DELTA", "EA","EGCO","GGC","GPSC", "GULF", "HANA", "IRPC", "IVL","KBANK","KCE","KKP", "KTB", "LH","M", "MAJOR","OR","PTT","PTTEP","PTTGC","S","SAMART",
    "SAWAD", "SCB", "SCC","SCP","SCGP","SIRI","SPALI", "SPRC","STA" ,"SUPER", "TCAP","THANI"]

                close_price = round(analysis.indicators["close"], 2)
                percentage_change = round(analysis.indicators["change"], 2)

                if symbol in thai_stocks:
                    tags = "TH"
                else:
                    tags = "US"
                
                prices.append({
                    'symbol': symbol,
                    'price': close_price,
                    'percentage': percentage_change,
                    'tags' : tags
                })

            return jsonify(prices)
        
@app.route('/getPricePredictList', methods=['POST'])
def getPricePredictList():
    dataList = request.get_json()  # รับข้อมูล JSON จาก Flutter
    symbol_list = dataList.get('symbolPredictList', [])  # แปลงข้อมูล JSON เป็น List
    listPredict = []

    for symbol in symbol_list:
        analysis = getSymbolHandler(symbol,"1D")
        close_price = round(analysis.indicators["close"], 2)         
        listPredict.append({
                'symbol': symbol,
                'price': close_price,
        })
           
    return jsonify(listPredict)        


@app.route('/checkMarketStatus', methods=['POST'])
def checkMarketStatus():
    # กำหนดคีย์และตัวระบุสำหรับเข้าถึง Alpaca API
    API_KEY = 'PKPZNZ5UPZP41MZUUYXF'
    API_SECRET = 'fajFEMpQSTE31NaQOUX3USwkWkl67oAtDERjRmmK'
    APCA_API_BASE_URL = 'https://paper-api.alpaca.markets'

    # ส่งคำสั่งซื้อ
    api = tradeapi.REST(API_KEY, API_SECRET,
                        APCA_API_BASE_URL, api_version='v2')

    # Check if the market is open now.
    clock = api.get_clock()
    return jsonify('{}'.format('open' if clock.is_open else 'closed'))

@app.route('/news', methods=['POST'])
def news():
    username = request.json.get('username')

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    cur = conn.cursor()

    cur.execute(f"SELECT watchlist FROM users_info WHERE username = '{username}'")
    stock_list=[]
    result2 = cur.fetchone()
    if result2 is not None:
        watchlist_json = result2[0]
        stock_list = json.loads(watchlist_json) if watchlist_json else []
        stock_string = ','.join(stock_list)
    print(stock_string)
    if stock_string != '':
        url = f"https://data.alpaca.markets/v1beta1/news?limit=20&exclude_contentless=true&symbols={stock_string}"
    else:
        url = f"https://data.alpaca.markets/v1beta1/news?limit=20&exclude_contentless=true"

    cur.execute("SELECT api_key, secret_key FROM users_info WHERE username = %s", (username,))
    
    result = cur.fetchone()

    if result and result != ('', ''):
        api_key, secret_key = result
    else:
        api_key, secret_key = "PKPZNZ5UPZP41MZUUYXF", "fajFEMpQSTE31NaQOUX3USwkWkl67oAtDERjRmmK"

    headers = {
        'Apca-Api-Key-Id': api_key,
        'Apca-Api-Secret-Key': secret_key
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
        return jsonify({"message": "Failed to fetch news."})
    
@app.route('/th_portfolio', methods= ['POST'])
def th_portfolio():
    
    username = request.json.get('username')

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT th_api_key, th_secret_key,broker_id, app_code FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()

    app_id, app_secret, broker_id, app_code = result

    investor = Investor(
        app_id=app_id,
        app_secret=app_secret,
        broker_id=broker_id,
        app_code=app_code,
        is_auto_queue=False
    )

    equity = investor.Equity(account_no=f"foczz123-E")

    account_info = equity.get_account_info()
    portfolio = equity.get_portfolios()
    cashBalance = account_info.get('cashBalance')
    print(account_info)
    print(cashBalance)
    portfolio_profit = portfolio['totalPortfolio']['profit']
    percentageChange = (portfolio_profit / cashBalance) * 100
        
    cash = getSymbolHandler("THBUSD","1D").indicators['close']
    USDtoTHB = getSymbolHandler("USDTHB","1D").indicators['close']
    balance = f"{cashBalance * cash:.2f}"
    print(type(USDtoTHB))
    print(USDtoTHB)

    balanceProfitChange = f"{portfolio_profit}"
    lineAvailable = f"{account_info.get('lineAvailable')}"
    marketValue = f"{portfolio['totalPortfolio']['marketValue'] }"
    portfolio_list = []

    for item in portfolio['portfolioList']:
        portfolio_list.append({
            'symbol': item['symbol'],
            'averagePrice': item['averagePrice'],
            'amount': item['marketValue'],
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
        'USDtoTHB' : float(USDtoTHB)
    }

    return jsonify(result)



@app.route('/place_order_th', methods=['POST'])
def place_order_th():
    username = request.json.get('username')
    symbol = request.json.get('symbol')
    qty = request.json.get('qty')
    side = request.json.get('side')
    validate = request.json.get('validate')
    limitPrice = request.json.get('limitPrice')
    type = request.json.get('type')

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT th_api_key, th_secret_key, broker_id, app_code, pin FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()
    print(result)
    investor = Investor(
                app_id=result[0],                                 
                app_secret=result[1], 
                broker_id=result[2],
                app_code=result[3],
                is_auto_queue = False)
    print(username,symbol,qty,side,validate,limitPrice,type)
    equity = investor.Equity(account_no=f"{username}-E")     
    try:
        if type =='Limit' and limitPrice > 0:
            if validate == 'GTC':
                place_order = equity.place_order(
                                        side= side,
                                        symbol= symbol,
                                        volume= qty,
                                        price = limitPrice,
                                        price_type= "Limit",
                                        pin= result[4],
                                        validity_type='Cancel'
                                        )
                print('คำสั่งซื้อขายถูกส่งไปยัง Settrade Sandbox แล้ว')
                return jsonify('success')
            elif validate == 'Day':
                place_order = equity.place_order(
                                        side= side,
                                        symbol= symbol,
                                        volume= qty,
                                        price = limitPrice,
                                        price_type= "Limit",
                                        pin= result[4],
                                        validity_type='Day'
                                        )
                print('คำสั่งซื้อขายถูกส่งไปยัง Settrade Sandbox แล้ว')
                return jsonify('success')
            elif validate == 'FOK':
                place_order = equity.place_order(
                                        side= side,
                                        symbol= symbol,
                                        volume= qty,
                                        price = limitPrice,
                                        price_type= "Limit",
                                        pin= result[4],
                                        validity_type='FOK'
                                        )
                print('คำสั่งซื้อขายถูกส่งไปยัง Settrade Sandbox แล้ว')
                return jsonify('success')
            else:
                place_order = equity.place_order(
                                        side= side,
                                        symbol= symbol,
                                        volume= qty,
                                        price = limitPrice,
                                        price_type= "Limit",
                                        pin= result[4],
                                        validity_type='IOC'
                                        )
                print('คำสั่งซื้อขายถูกส่งไปยัง Settrade Sandbox แล้ว')
                return jsonify('success')
        else:
            if validate == 'FOK':
                place_order = equity.place_order(
                    side= side,
                    symbol= symbol,
                    volume= qty,
                    price = limitPrice,
                    price_type= "MP-MKT",
                    pin= result[4],
                    validity_type='FOK'
                    )
                print('คำสั่งซื้อขายถูกส่งไปยัง Settrade Sandbox แล้ว')
                return jsonify('success')
            else:
                place_order = equity.place_order(
                    side= side,
                    symbol= symbol,
                    volume= qty,
                    price_type= "MP-MKT",
                    pin= result[4],
                    validity_type='IOC'
                )
                print('คำสั่งซื้อขายถูกส่งไปยัง Settrade Sandbox แล้ว')
                return jsonify('success')
    except Exception as e:
        print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
        return jsonify(f'error: {str(e)}')


@app.route('/cancelOrder', methods=['POST'])
def cancelOrder():
    username = request.json.get('username')
    orderID = request.json.get('orderID')
    isCancel = bool(request.json.get('isCancel'))

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT status FROM auto_order WHERE username = '{username}' AND OrderID ='{orderID}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()
    print(orderID,username,result)
    if(result[0]=='pending' and isCancel):
        print("cancel")
        cancel = f"UPDATE auto_order SET status = 'cancelled' WHERE username = '{username}' AND OrderID ='{orderID}'"
        cursor = conn.cursor()
        cursor.execute(cancel)
        conn.commit()  # ต้องมีการ commit เพื่อบันทึกการเปลี่ยนแปลงในฐานข้อมูล
        return jsonify('deleted success')
    else:
        cancel = f"UPDATE auto_order SET status = 'pending' WHERE username = '{username}' AND OrderID ='{orderID}'"
        cursor = conn.cursor()
        cursor.execute(cancel)
        conn.commit()  # ต้องมีการ commit เพื่อบันทึกการเปลี่ยนแปลงในฐานข้อมูล
        return jsonify('add for undo success')
    
def completeOrder(username,orderID):
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT status FROM auto_order WHERE username = '{username}' AND OrderID ='{orderID}'"
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()
    if(result[0]=='pending'):
        print("completed")
        complete = f"UPDATE auto_order SET status = 'completed' WHERE username = '{username}' AND OrderID ='{orderID}'"
        cursor = conn.cursor()
        cursor.execute(complete)
        conn.commit()  
        return jsonify('completed')

@app.route('/multiAutotrade', methods=['POST'])
def multiAutotrade():
    username = request.json.get('username')
    isRSI = bool(request.json.get('isRSI'))
    isSTO = bool(request.json.get('isSTO'))
    isMACD = bool(request.json.get('isMACD'))
    isEMA = bool(request.json.get('isEMA'))
    print("isRSI = ",isRSI)
    print("isSTO = ",isSTO)
    print("isMACD = ",isMACD)
    print("isEMA = ",isEMA)
    symbol = request.json.get('symbol')
    qty = float(request.json.get('qty')) #"0.0002"
    side = request.json.get('side')
    type = "market"
    time_in_force = "gtc"
    interval = request.json.get('interval')
    print(interval)

    techniques = []

    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    cursor = conn.cursor()
    print(symbol,qty,side,type,time_in_force)

    while True:
        order_number = random.randrange(1, 100000)
        sql_check_duplicate = "SELECT COUNT(*) FROM auto_order WHERE OrderID = %s" 
        cursor.execute(sql_check_duplicate, (order_number,))
        count = cursor.fetchone()[0]
        if count == 0:
            order_number=order_number
            break

    insert_query = "INSERT INTO auto_order (OrderID, username, symbol, techniques, quantity, side, timeframe, status) VALUES (%s, %s, %s, %s, %s, %s, %s, 'pending')"


    if side == "buy":
        if isRSI:
            rsi_value = float(request.json.get('rsi'))
            techniques.append(f"RSI < {rsi_value}")
        if isSTO:
            cross_sto = float(request.json.get('cross_sto')) 
            zone_sto = float(request.json.get('zone_sto')) 
            if cross_sto > 0:
                techniques.append(f"%K ตัดขึ้น %D และ < {cross_sto}")
            else:
                techniques.append(f"%K และ %D < {zone_sto}")
        if isMACD:
            cross = bool(request.json.get('cross_macd')) 
            zone = float(request.json.get('zone_macd')) 
            if cross:
                techniques.append(f"MACD ตัดขึ้น Signal และ < 0")
            else:
                techniques.append(f"MACD & Signal < {zone}")
        if isEMA:
            day = int(request.json.get('day'))
            techniques.append(f"ซื้อเมื่อราคา <= EMA{day}")
    else:
        if isRSI:
            rsi_value = float(request.json.get('rsi'))
            techniques.append(f"RSI > {rsi_value}")
        if isSTO:
            cross_sto = float(request.json.get('cross_sto')) 
            zone_sto = float(request.json.get('zone_sto')) 
            if cross_sto > 0:
                techniques.append(f"%K ตัดลง %D และ > {cross_sto}")
            else:
                techniques.append(f"%K และ %D > {zone_sto}")
        if isMACD:
            cross = bool(request.json.get('cross_macd')) 
            zone = float(request.json.get('zone_macd')) 
            if cross:
                techniques.append(f"MACD ตัดลง Signal และ > 0")
            else:
                techniques.append(f"MACD & Signal > {zone}")
        if isEMA:
            day = int(request.json.get('day'))
            techniques.append(f"ขายเมื่อราคา >= EMA{day}")
    print(techniques)

    data_to_insert = (order_number, username, symbol, ','.join(techniques), qty, side, interval)
    cursor.execute(insert_query, data_to_insert)
    conn.commit()
    
    try:
        if isRSI and isSTO and not isMACD and not isEMA:
            rsi_value = float(request.json.get('rsi'))
            zone_sto = float(request.json.get('zone_sto')) #"0.00"
            cross_sto = float(request.json.get('cross_sto')) 
            if side == "buy":
                if cross_sto > 0:
                    print("เข้าเงื่อนไขซื้อ cross RSI STO")
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)
                            rsi = analysis.indicators["RSI"]
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]
                            if rsi < rsi_value and stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD:
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify(f"ซื้อ cross RSI STO สำเร็จ")
                else:
                    print("เข้าเงื่อนไขซื้อ zone RSI STO")
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi zone sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)
                            rsi = analysis.indicators["RSI"]
                            stoK = analysis.indicators["Stoch.K"]
                            stoD =  analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]
                            if rsi < rsi_value and stoK <= zone_sto and stoD <= zone_sto:
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify(f"ซื้อ zone RSI STO สำเร็จ")
            else:
                if cross_sto > 0:
                    print("เข้าเงื่อนไขขาย cross RSI STO")
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval = interval)
                            rsi = analysis.indicators["RSI"]
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]
                            if rsi > rsi_value and stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD:
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify(f"ขาย cross RSI STO สำเร็จ")
                else:
                    print("เข้าเงื่อนไขขาย zone RSI STO")
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)
                            rsi = analysis.indicators["RSI"]
                            stoK = analysis.indicators["Stoch.K"]
                            stoD =  analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]
                            if rsi > rsi_value and stoK >= zone_sto and stoD >= zone_sto:
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify(f"ขาย zone RSI STO สำเร็จ")
                

        elif isRSI and isMACD and not isSTO and not isEMA:
            rsi_value = float(request.json.get('rsi'))
            zone = float(request.json.get('zone_macd')) #"0.00"
            cross = bool(request.json.get('cross_macd')) 
            last_macd = 0
            last_signal = 0
            if side == "buy":
                if cross:
                    print("เข้าเงื่อนไขซื้อ cross RSI MACD")
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)
                            rsi = analysis.indicators["RSI"]
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]
                            if rsi < rsi_value and (last_macd < last_signal and macd > signal) and (macd and signal < 0):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify(f"ซื้อ cross RSI MACD สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                else:
                    print("เข้าเงื่อนไขซื้อ zone RSI MACD")
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)
                            rsi = analysis.indicators["RSI"]
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]
                            if rsi < rsi_value and (macd and signal < zone):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify(f"ซื้อ zone RSI MACD สำเร็จ")
                            last_macd = macd
                            last_signal = signal
            else:
                if cross:
                    print("เข้าเงื่อนไขขาย cross RSI MACD")
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)
                            rsi = analysis.indicators["RSI"]
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]
                            if rsi > rsi_value and (last_macd > last_signal and macd < signal) and (macd and signal > 0):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify(f"ขาย cross RSI MACD สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                else:
                    print("เข้าเงื่อนไขขาย zone RSI MACD")
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)
                            rsi = analysis.indicators["RSI"]
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]
                            if rsi < rsi_value and (macd and signal > zone):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify(f"ขาย zone RSI MACD สำเร็จ")
                            last_macd = macd
                            last_signal = signal

        elif isRSI and isEMA and not isSTO and not isMACD:
            rsi_value = float(request.json.get('rsi'))
            day = request.json.get('day')
            last_ema = 0
            last_close = 0
            if side == "buy":
                print("เข้าเงื่อนไขซื้อ RSI EMA")
                while True:      
                    checkStatus = checkStatusOrder(username=username,order_number=order_number)
                    if checkStatus == 'cancelled':
                        return jsonify('autotrade buy rsi cross sto cancelled')
                    else:
                        analysis = getSymbolHandler(symbol=symbol,interval=interval)     
                        rsi = analysis.indicators["RSI"]               
                        ema = analysis.indicators[f"EMA{day}"]
                        close = analysis.indicators["close"]
                        print("RSI:",rsi)
                        print("EMA:",ema)
                        print("Close:",close)
                        if rsi < rsi_value and close <= ema and last_close > last_ema:
                            placeOrderAutoTrade(symbol=symbol,username=username,qty=qty,side=side)
                            completeOrder(username=username,orderID=order_number)
                            return jsonify("ซื้อ RSI EMA สำเร็จ")
                        last_ema = ema
                        last_close = close
                    
            else:
                print("เข้าเงื่อนไขขาย RSI EMA")
                while True:      
                    checkStatus = checkStatusOrder(username=username,order_number=order_number)
                    if checkStatus == 'cancelled':
                        return jsonify('autotrade buy rsi cross sto cancelled')
                    else:
                        analysis = getSymbolHandler(symbol=symbol,interval=interval)     
                        rsi = analysis.indicators["RSI"]               
                        ema = analysis.indicators[f"EMA{day}"]
                        close = analysis.indicators["close"]
                        if rsi > rsi_value and close >= ema and last_close < last_ema:
                            placeOrderAutoTrade(symbol=symbol,username=username,qty=qty,side=side)
                            completeOrder(username=username,orderID=order_number)
                            return jsonify("ขาย RSI EMA สำเร็จ")
                        last_ema = ema
                        last_close = close

        elif isSTO and isMACD and not isRSI and not isEMA:
            zone_sto = float(request.json.get('zone_sto')) #"0.00"
            cross_sto = float(request.json.get('cross_sto')) 
            zone = float(request.json.get('zone_macd')) #"0.00"
            cross = bool(request.json.get('cross_macd')) 

            if side == "buy":
                if cross_sto>0:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD) and (last_macd < last_signal and macd > signal) and (macd and signal < 0):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ cross STO cross 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD) and (macd and signal < zone):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ cross STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                else:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (stoK <= zone_sto and stoD <= zone_sto) and (last_macd < last_signal and macd > signal) and (macd and signal < 0):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ zone STO cross 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (stoK <= zone_sto and stoD <= zone_sto) and (macd and signal < zone):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ zone STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal

            #sell
            else:
                if cross_sto>0:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD) and (last_macd > last_signal and macd < signal) and (macd and signal > 0):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย cross STO cross > 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD) and  (macd and signal > zone):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย cross STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                else:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (stoK >= zone_sto and stoD >= zone_sto) and (last_macd > last_signal and macd < signal) and (macd and signal > 0):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย zone STO cross > 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (stoK >= zone_sto and stoD >= zone_sto) and  (macd and signal > zone):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย zone STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal

        elif isSTO and isEMA and not isRSI and not isMACD:
            zone_sto = float(request.json.get('zone_sto')) #"0.00"
            cross_sto = float(request.json.get('cross_sto')) 
            day = request.json.get('day')

            if side == "buy":
                if cross_sto>0:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]    
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD) and (close <= ema and last_close > last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ซื้อ cross STO EMA สำเร็จ")
                            last_ema = ema
                            last_close = last_close
                else:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]    
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (stoK <= zone_sto and stoD <= zone_sto) and (close <= ema and last_close > last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ซื้อ zone STO EMA สำเร็จ")
                            last_ema = ema
                            last_close = last_close

            else:
                if cross_sto>0:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]    
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD) and (close >= ema and last_close < last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ขาย cross STO EMA สำเร็จ")
                            last_ema = ema
                            last_close = last_close
                else:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]    
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (stoK >= zone_sto and stoD >= zone_sto) and (close >= ema and last_close < last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ขาย zone STO EMA สำเร็จ")
                            last_ema = ema
                            last_close = last_close

        elif isMACD and isEMA and not isRSI and not isSTO:
            zone = float(request.json.get('zone_macd')) #"0.00"
            cross = bool(request.json.get('cross_macd')) 
            day = request.json.get('day')

            if side == "buy":
                if cross:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]   
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if ((last_macd < last_signal and macd > signal) and (macd and signal < 0)) and (close <= ema and last_close > last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ซื้อ cross < 0 MACD EMA สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                            last_ema = ema
                            last_close = last_close
                else:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]   
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (macd and signal < zone) and (close <= ema and last_close > last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ซื้อ zone MACD EMA สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                            last_ema = ema
                            last_close = last_close
            #sell
            else:
                if cross:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]   
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if ((last_macd > last_signal and macd < signal) and (macd and signal > 0)) and (close >= ema and last_close < last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ขาย cross > 0 MACD EMA สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                            last_ema = ema
                            last_close = last_close
                else:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]   
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (macd and signal > zone) and (close >= ema and last_close < last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ขาย zone MACD EMA สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                            last_ema = ema
                            last_close = last_close

        elif isRSI and isSTO and isMACD and not isEMA:
            rsi_value = float(request.json.get('rsi'))
            zone_sto = float(request.json.get('zone_sto')) #"0.00"
            cross_sto = float(request.json.get('cross_sto')) 
            zone = float(request.json.get('zone_macd')) #"0.00"
            cross = bool(request.json.get('cross_macd')) 

            if side == "buy":
                if cross_sto>0:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                rsi = analysis.indicators["RSI"]
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (rsi < rsi_value) and (stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD) and (last_macd < last_signal and macd > signal) and (macd and signal < 0):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ RSI cross STO cross 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                            
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                rsi = analysis.indicators["RSI"]
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (rsi < rsi_value) and (stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD) and (macd and signal < zone):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ RSI cross STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                else:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)  
                                rsi = analysis.indicators["RSI"]  
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (rsi < rsi_value) and (stoK <= zone_sto and stoD <= zone_sto) and (last_macd < last_signal and macd > signal) and (macd and signal < 0):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ RSI zone STO cross 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)  
                                rsi = analysis.indicators["RSI"]   
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (rsi < rsi_value) and (stoK <= zone_sto and stoD <= zone_sto) and (macd and signal < zone):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ RSI zone STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal

            #sell
            else:
                if cross_sto>0:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval) 
                                rsi = analysis.indicators["RSI"]   
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (rsi > rsi_value) and (stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD) and (last_macd > last_signal and macd < signal) and (macd and signal > 0):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย RSI cross STO cross > 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval) 
                                rsi = analysis.indicators["RSI"]   
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (rsi > rsi_value) and (stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD) and  (macd and signal > zone):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย RSI cross STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                else:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                rsi = analysis.indicators["RSI"]
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (rsi > rsi_value) and (stoK >= zone_sto and stoD >= zone_sto) and (last_macd > last_signal and macd < signal) and (macd and signal > 0):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย RSI zone STO cross > 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                rsi = analysis.indicators["RSI"]
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                if (rsi > rsi_value) and (stoK >= zone_sto and stoD >= zone_sto) and  (macd and signal > zone):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย RSI zone STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal

        elif isRSI and isSTO and isEMA and not isMACD:
            rsi_value = float(request.json.get('rsi'))
            zone_sto = float(request.json.get('zone_sto')) #"0.00"
            cross_sto = float(request.json.get('cross_sto')) 
            day = int(request.json.get('day'))

            if side == "buy":
                if cross_sto>0:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)   
                            rsi = analysis.indicators["RSI"] 
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]    
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (rsi < rsi_value) and (stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD) and (close <= ema and last_close > last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ซื้อ cross STO EMA สำเร็จ")
                            last_ema = ema
                            last_close = last_close
                else:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)  
                            rsi = analysis.indicators["RSI"]  
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]    
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (rsi < rsi_value) and (stoK <= zone_sto and stoD <= zone_sto) and (close <= ema and last_close > last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ซื้อ zone STO EMA สำเร็จ")
                            last_ema = ema
                            last_close = last_close

            else:
                if cross_sto>0:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)  
                            rsi = analysis.indicators["RSI"]  
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]    
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (rsi > rsi_value) and (stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD) and (close >= ema and last_close < last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ขาย cross STO EMA สำเร็จ")
                            last_ema = ema
                            last_close = last_close
                else:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval) 
                            rsi = analysis.indicators["RSI"]   
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]    
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (rsi > rsi_value) and (stoK >= zone_sto and stoD >= zone_sto) and (close >= ema and last_close < last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ขาย zone STO EMA สำเร็จ")
                            last_ema = ema
                            last_close = last_close

        elif isRSI and isMACD and isEMA and not isSTO:
            rsi_value = float(request.json.get('rsi'))
            zone = float(request.json.get('zone_macd')) #"0.00"
            cross = bool(request.json.get('cross_macd')) 
            day = request.json.get('day')

            if side == "buy":
                if cross:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            rsi = analysis.indicators["RSI"]
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]   
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (rsi < rsi_value) and ((last_macd < last_signal and macd > signal) and (macd and signal < 0)) and (close <= ema and last_close > last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ซื้อ cross < 0 MACD EMA สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                            last_ema = ema
                            last_close = last_close
                else:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval) 
                            rsi = analysis.indicators["RSI"]   
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]   
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (rsi < rsi_value) and (macd and signal < zone) and (close <= ema and last_close > last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ซื้อ zone MACD EMA สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                            last_ema = ema
                            last_close = last_close
            #sell
            else:
                if cross:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            rsi = analysis.indicators["RSI"]
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]   
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (rsi > rsi_value) and ((last_macd > last_signal and macd < signal) and (macd and signal > 0)) and (close >= ema and last_close < last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ขาย RSI cross > 0 MACD EMA สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                            last_ema = ema
                            last_close = last_close
                else:
                    while True:
                        checkStatus = checkStatusOrder(username=username,order_number=order_number)
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)
                            rsi = analysis.indicators["RSI"]    
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]   
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (rsi > rsi_value) and (macd and signal > zone) and (close >= ema and last_close < last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ขาย RSI zone MACD EMA สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                            last_ema = ema
                            last_close = last_close
            
        elif isSTO and isMACD and isEMA and not isRSI:
            zone_sto = float(request.json.get('zone_sto')) #"0.00"
            cross_sto = float(request.json.get('cross_sto')) 
            zone = float(request.json.get('zone_macd')) #"0.00"
            cross = bool(request.json.get('cross_macd')) 
            day = request.json.get('day')

            if side == "buy":
                if cross_sto>0:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD) and (last_macd < last_signal and macd > signal) and (macd and signal < 0) and (close <= ema and last_close > last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ cross STO cross 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD) and (macd and signal < zone) and (close <= ema and last_close > last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ cross STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                else:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (stoK <= zone_sto and stoD <= zone_sto) and (last_macd < last_signal and macd > signal) and (macd and signal < 0) and (close <= ema and last_close > last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ zone STO cross 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (stoK <= zone_sto and stoD <= zone_sto) and (macd and signal < zone) and (close <= ema and last_close > last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ zone STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close

            #sell
            else:
                if cross_sto>0:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD) and (last_macd > last_signal and macd < signal) and (macd and signal > 0) and (close >= ema and last_close < last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย cross STO cross > 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD) and  (macd and signal > zone) and (close >= ema and last_close < last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย cross STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                            
                else:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (stoK >= zone_sto and stoD >= zone_sto) and (last_macd > last_signal and macd < signal) and (macd and signal > 0) and (close >= ema and last_close < last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย zone STO cross > 0 MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (stoK >= zone_sto and stoD >= zone_sto) and  (macd and signal > zone) and (close >= ema and last_close < last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย zone STO zone MACD สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close

        elif isRSI and isSTO and isMACD and isEMA:
            rsi_value = float(request.json.get('rsi'))
            zone_sto = float(request.json.get('zone_sto')) #"0.00"
            cross_sto = float(request.json.get('cross_sto')) 
            zone = float(request.json.get('zone_macd')) #"0.00"
            cross = bool(request.json.get('cross_macd')) 
            day = request.json.get('day')

            if side == "buy":
                if cross_sto > 0:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                rsi = analysis.indicators["RSI"]
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (rsi < rsi_value) and (stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD) and (last_macd < last_signal and macd > signal) and (macd and signal < 0) and (close <= ema and last_close > last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ RSI cross STO cross MACD EMA สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                rsi = analysis.indicators["RSI"]
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (rsi < rsi_value) and (stoK < cross_sto and stoD < cross_sto and stoK > stoD and last_stoK < last_stoD) and (macd and signal > zone) and (close <= ema and last_close > last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ RSI cross STO zone MACD EMA สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                else:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade all true cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                rsi = analysis.indicators["RSI"]
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (rsi < rsi_value) and (stoK <= zone_sto and stoD <= zone_sto) and (last_macd < last_signal and macd > signal) and (macd and signal < 0) and (close <= ema and last_close > last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ซื้อ RSI zone STO cross MACD EMA สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                    else:
                        if checkStatus == 'cancelled':
                            return jsonify('autotrade buy rsi cross sto cancelled')
                        else:
                            analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                            rsi = analysis.indicators["RSI"]
                            stoK = analysis.indicators["Stoch.K"]
                            stoD = analysis.indicators["Stoch.D"] 
                            last_stoK = analysis.indicators["Stoch.K[1]"]
                            last_stoD = analysis.indicators["Stoch.D[1]"]
                            macd = analysis.indicators["MACD.macd"]
                            signal = analysis.indicators["MACD.signal"]
                            ema = analysis.indicators[f"EMA{day}"]
                            close = analysis.indicators["close"]
                            if (rsi < rsi_value) and (stoK <= zone_sto and stoD <= zone_sto) and (macd and signal > zone) and (close <= ema and last_close > last_ema):
                                placeOrderAutoTrade(symbol,username,qty,side)
                                completeOrder(username=username,orderID=order_number)
                                return jsonify("ซื้อ RSI zone STO zone MACD EMA สำเร็จ")
                            last_macd = macd
                            last_signal = signal
                            last_ema = ema
                            last_close = close
            #sell
            else:
                if cross_sto>0:
                    if cross:
                        while True:
                            print("เข้าเงื่อไข autotrade")
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                rsi = analysis.indicators["RSI"]
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (rsi > rsi_value) and (stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD) and (last_macd > last_signal and macd < signal) and (macd and signal > 0) and (close >= ema and last_close < last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย RSI cross STO cross MACD EMA สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)  
                                rsi = analysis.indicators["RSI"]  
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (rsi > rsi_value) and (stoK > cross_sto and stoD > cross_sto and stoK < stoD and last_stoK > last_stoD) and  (macd and signal > zone) and (close >= ema and last_close < last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย RSI cross STO zone MACD EMA สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                            
                else:
                    if cross:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)   
                                rsi = analysis.indicators["RSI"] 
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (rsi > rsi_value) and (stoK >= zone_sto and stoD >= zone_sto) and (last_macd > last_signal and macd < signal) and (macd and signal > 0) and (close >= ema and last_close < last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย RSI zone STO cross MACD EMA สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                    else:
                        while True:
                            checkStatus = checkStatusOrder(username=username,order_number=order_number)
                            if checkStatus == 'cancelled':
                                return jsonify('autotrade buy rsi cross sto cancelled')
                            else:
                                analysis = getSymbolHandler(symbol=symbol,interval=interval)    
                                rsi = analysis.indicators["RSI"]
                                stoK = analysis.indicators["Stoch.K"]
                                stoD = analysis.indicators["Stoch.D"] 
                                last_stoK = analysis.indicators["Stoch.K[1]"]
                                last_stoD = analysis.indicators["Stoch.D[1]"]
                                macd = analysis.indicators["MACD.macd"]
                                signal = analysis.indicators["MACD.signal"]
                                ema = analysis.indicators[f"EMA{day}"]
                                close = analysis.indicators["close"]
                                if (rsi > rsi_value) and (stoK >= zone_sto and stoD >= zone_sto) and  (macd and signal > zone) and (close >= ema and last_close < last_ema):
                                    placeOrderAutoTrade(symbol,username,qty,side)
                                    completeOrder(username=username,orderID=order_number)
                                    return jsonify("ขาย RSI zone STO cross zone EMA สำเร็จ")
                                last_macd = macd
                                last_signal = signal
                                last_ema = ema
                                last_close = close
                        
    except Exception as e:
        print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
        return jsonify(f'error: {str(e)}')

        
def getSymbolHandler(symbol,interval):
    exchanges_to_try = [
        {"screener": "america", "exchange": "NASDAQ"},
        {"screener": "america", "exchange": "NYSE"},
        {"screener": "thailand", "exchange": "SET"},
        {"screener": "Crypto", "exchange": "Binance"},
        {"screener": "forex", "exchange": "FX_IDC"}
    ]

    for exchange_info in exchanges_to_try:
        try:
            handler = TA_Handler(
                symbol=symbol,
                screener=exchange_info["screener"],
                exchange=exchange_info["exchange"],
                interval=interval
            )
            analysis = handler.get_analysis()
            return analysis
        except Exception:
            continue

    return None


def placeOrderAutoTrade(symbol,username,qty,side):
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    queryUS = f"SELECT api_key, secret_key FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(queryUS)
    resultUS = cursor.fetchone()
    
    queryTH = f"SELECT th_api_key, th_secret_key, broker_id, app_code, pin FROM users_info WHERE username = '{username}'"
    cursor = conn.cursor()
    cursor.execute(queryTH)
    resultTH = cursor.fetchone()
    

    try:
        api = REST(resultUS[0], resultUS[1], base_url='https://paper-api.alpaca.markets')
    except Exception as e:
        try:
            api = REST(resultUS[0], resultUS[1], base_url='https://api.alpaca.markets')
        except Exception as e:
            api = Investor(
                app_id=resultTH[0],                                 
                app_secret=resultTH[1], 
                broker_id=resultTH[2],
                app_code=resultTH[3],
                is_auto_queue = False)
            
    try:
        api.submit_order(
                    symbol=symbol,
                    qty=qty,
                    side=side,
                    type='market',
                    time_in_force='gtc'        
                )
        print('คำสั่งซื้อขายถูกส่งไปยัง Alpaca แล้ว')
        return "passed"
    except Exception as e:
        try:
            equity = api.Equity(account_no=f"{username}-E")  
            place_order = equity.place_order(
                                    side= side,
                                    symbol= symbol,
                                    volume= qty,
                                    price_type= "MP-MKT",
                                    pin=resultTH[4]
                                    )
            print('คำสั่งซื้อขายถูกส่งไปยัง Settrade Sandbox แล้ว')
            return "passed"
        except Exception as e:
            print(f'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: {str(e)}')
            return "failed"
        
def checkStatusOrder(username,order_number):
    conn = MySQLdb.connect(host="localhost", user="root", passwd="", db="walltrade")
    query = f"SELECT status FROM auto_order WHERE username = '{username}' AND OrderID = '{order_number}' "
    cursor = conn.cursor()
    cursor.execute("RESET QUERY CACHE;")
    cursor.execute(query)
    result = cursor.fetchone()
    return result[0]

@app.route('/technicalVauleOfSymbol', methods=['POST'])
def technicalVauleOfSymbol():
    symbol = request.json.get('symbol')
    interval = request.json.get('interval')
    print(interval)
    analysis = getSymbolHandler(symbol=symbol,interval=interval)
    rsi = analysis.indicators['RSI']
    stoK = analysis.indicators['Stoch.K']
    stoD = analysis.indicators['Stoch.D']
    macd = analysis.indicators['MACD.macd']
    signal = analysis.indicators['MACD.signal']
    ema5 = analysis.indicators[f'EMA5']
    ema10 = analysis.indicators[f'EMA10']
    ema20 = analysis.indicators[f'EMA20']
    ema50 = analysis.indicators[f'EMA50']
    ema100 = analysis.indicators[f'EMA100']
    ema200 = analysis.indicators[f'EMA200']
    close = analysis.indicators['close']

    data = {
        'rsi': rsi,
        'stoK': stoK,
        'stoD': stoD,
        'macd': macd,
        'signal': signal,
        'ema5': ema5,
        'ema10': ema10,
        'ema20': ema20,
        'ema50': ema50,
        'ema100': ema100,
        'ema200': ema200,
        'close': close
    }
    return jsonify(data)


if __name__ == '__main__':
    app.run(host="0.0.0.0")