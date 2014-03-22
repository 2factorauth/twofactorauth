from twython import TwythonStreamer

from secret import APP_KEY, APP_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET


class TFAStreamer(TwythonStreamer):
    def on_success(self, data):
        print 'Success'
        print 'Data:', data

    def on_error(self, status_code, data):
        print 'Error', 'Status code:', status_code
        print 'Data:', data

stream = TFAStreamer(APP_KEY, APP_SECRET,
                     OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

stream.statuses.filter(track='#SupportTwoFactorAuth')
