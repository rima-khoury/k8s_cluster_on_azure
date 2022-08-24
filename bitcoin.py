import requests
import time


FILE_PATH = "/tmp/bitcoin_rate.txt"
LOG_FILE = "/tmp/bitcoin_rate.log"
URL = "https://blockchain.info/ticker"

avg = 0
counter = 0
total_time_range = 18
with open(FILE_PATH, 'a') as f, open(LOG_FILE, 'a') as log:
    for j in range(total_time_range):
        counter = 0
        avg = 0
        for i in range(10):
            try:
                data = requests.get(URL).json()
            except Exception as err:
                log.write("Error occurred during getting of URL with error {}\n".format(err))
            try:
                usd_rate = data["USD"]['buy']
                f.write("BITCOIN value in USD is : {}\n".format(usd_rate))
                time.sleep(60)
                avg += usd_rate
                counter += 1
            except Exception as err:
                log.write("wrong format gotten from URL. error: {}\n".format(err))

        if counter != 0:
            f.write("{} - Average BITCOIN value in USD in the last 10 minutes is : {}\n"
                    .format(time.strftime("%H:%M:%S", time.localtime()), avg / counter ))
        else:
            log.write("{} - Could not retrieve the bitcoin value in USD in the last 10 minutes!\n"
                      .format(time.strftime("%H:%M:%S", time.localtime())))
            f.write("{} - Could not retrieve the bitcoin value in USD in the last 10 minutes!\n"
                    .format(time.strftime("%H:%M:%S", time.localtime())))