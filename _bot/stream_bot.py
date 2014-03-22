from twython import TwythonStreamer

class TFAStreamer(TwythonStreamer):
    def on_success(self, data):
        print 'Success'

    def on_error(self, status_code, data):
        print 'Error'

stream = TFAStreamer(APP_KEY, APP_SECRET,
                    OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

stream.statuses.filter(track='twitter')
