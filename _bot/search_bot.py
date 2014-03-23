import os.path
import signal
import sys
import time
import threading
import yaml

from twython import Twython, TwythonStreamer,TwythonError
from secret import APP_KEY, APP_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET, ACCESS_TOKEN

#
# Config
#

# My Tweet =]
START_TWEET = 444926333370392576

DATA = '_data/'
TWEETS_FILE = 'tweets.yml'
RAW_TWEETS_FILE = 'raw_tweets.yml'

# Time to sleep, 5 minutes
SLEEP_TIME = 60 * 5

# Wait for 3 seconds between requests
WAIT_TIME = 3

# Tweets to grab
TWEETS_COUNT = 100

# Search string
Q = '#SupportTwoFactorAuth'

# Type of result: mixed, recent, popular
RESULT_TYPE = 'recent'

# Basic dirs
PWD = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.abspath(os.path.join(PWD, '..'))

# Create base dirs
DATA_DIR = os.path.join(BASE, DATA)

# Easy lookup for IDs
TWEETS = set()


def base_options():
    """
    Base options for searching.

    """

    options = {}

    options['q'] = Q
    options['result_type'] = RESULT_TYPE
    options['count'] = TWEETS_COUNT

    return options


class TFAStreamer(TwythonStreamer):
    def __init__(self, *args, **kwargs):
        super(TFAStreamer, self).__init__(*args, **kwargs)
        self.tweets = []

    def on_success(self, data):
        print 'Success'
        print 'Data:', data

    def on_error(self, status_code, data):
        print 'Error', 'Status code:', status_code
        print 'Data:', data


class TFABot(object):
    def __init__(self, client):
        self.client = client
        self.next_id = None
        self.repeating_tweets = False

        self.api_calls = 0
        self.rate = self.get_rate()

        self.tweets = self.load_existing()
        self.stream = TFAStreamer(APP_KEY, APP_SECRET,
                                  OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

    def load_existing(self):
        tweets_path = os.path.join(DATA_DIR, RAW_TWEETS_FILE)

        existing = []
        if os.path.exists(tweets_path):
            with open(tweets_path) as tweets_file:
                data = yaml.load(tweets_file)
                existing = data.get('tweets', [])

        sorted_tweets = sorted(existing, key=lambda k: k['id'])

        # Start where we left off
        if len(sorted_tweets):
            self.next_id = sorted_tweets[0]['id']
            print 'Re-starting at', self.next_id

        for tweet in sorted_tweets:
            TWEETS.add(tweet['id'])

        return sorted_tweets

    def get_rate(self):
        try:
            data = self.client.get_application_rate_limit_status()
            return data['resources']['search']['/search/tweets']['remaining']
        except TwythonError:
            return 0

    def sleeping(self):
        print 'Rate:', self.rate

        if self.api_calls >= 10:
            self.rate = self.get_rate()
            self.api_calls = 0
        elif self.rate > 0:
            self.rate -= 1
            self.api_calls += 1

        if self.rate == 0:
            return True
        else:
            return False

    def finished(self):
        # We're done! I don't know if this actually will work...
        if self.next_id == START_TWEET:
            return True
        elif self.repeating_tweets is True:
            return True
        else:
            return False

    def sleep(self):
        time.sleep(SLEEP_TIME)

    def search(self):
        print 'Searching...'

        options = base_options()

        if self.next_id:
            options['max_id'] = self.next_id

        try:
            data = self.client.search(**options)
        except TwythonError as e:
            print 'Error:', e
            return

        statuses = data['statuses']
        sorted_tweets = sorted(statuses, key=lambda k: k['id'])

        for tweet in sorted_tweets:
            if tweet['id'] in TWEETS:
                continue
            self.tweets.append(tweet)

        # Assign for next time..
        if len(sorted_tweets):
            self.previous_id = self.next_id
            self.next_id = sorted_tweets[0]['id']

            if self.previous_id == self.next_id:
                self.repeating_tweets = True
                print 'We\'ve reached the end.'

            print 'Next ID:', self.next_id

    def wait(self):
        time.sleep(WAIT_TIME)

    def finish(self, signal=None, frame=None):
        print 'Writing tweets...'
        self.write_tweets()
        print 'Cleaning up...'
        sys.exit(0)

    def simplify_tweet(self, tweet):
        result = {}

        result['id'] = tweet['id']
        result['created'] = tweet['user']['created_at']
        result['name'] = tweet['user']['name']
        result['user'] = tweet['user']['screen_name']
        result['image'] = tweet['user']['profile_image_url']
        result['text'] = tweet['text']

        result['sites'] = []
        for user in tweet['entities']['user_mentions']:
            result['sites'].append(user['screen_name'])

        return result

    def write_tweets(self):
        tweets_path = os.path.join(DATA_DIR, TWEETS_FILE)
        raw_tweets_path = os.path.join(DATA_DIR, RAW_TWEETS_FILE)

        all_tweets = self.tweets + self.stream.tweets
        sorted_tweets = sorted(all_tweets, key=lambda k: k['id'])

        # Write raw first
        with open(raw_tweets_path, 'w') as tweets_file:
            data = {}
            data['tweets'] = sorted_tweets
            data['count'] = len(sorted_tweets)

            tweets_file.write(yaml.safe_dump(data, default_flow_style=False))

        simple_tweets = map(lambda d: self.simplify_tweet(d), sorted_tweets)

        # Write simplified next
        with open(tweets_path, 'w') as tweets_file:
            data = {}
            data['tweets'] = simple_tweets
            data['count'] = len(simple_tweets)

            tweets_file.write(yaml.safe_dump(data, default_flow_style=False))

    def loop(self):
        # First start our stream for future tweets
        self.thread = threading.Thread(target=self.start_stream)

        # Stop after exit
        self.thread.daemon = True

        # Start the thread
        #self.thread.start()

        while self.finished() is False:
            if self.sleeping():
                self.sleep()
            else:
                self.search()
                self.wait()

        self.finish()

    def start_stream(self):
        self.stream.statuses.filter(track=Q)


if __name__ == '__main__':
    client = Twython(APP_KEY, access_token=ACCESS_TOKEN)
    bot = TFABot(client)

    # Setup interrupts
    signal.signal(signal.SIGINT, bot.finish)

    bot.loop()
