import os.path
import signal
import sys
import time
import yaml

from twython import Twython
from secret import APP_KEY, ACCESS_TOKEN

#
# Config
#

# My Tweet =]
START_TWEET = '444926333370392576'

DATA = '_data/'
TWEETS_FILE = 'tweets.yml'
RAW_TWEETS_FILE = 'raw_tweets.yml'

# Time to sleep, 5 minutes
SLEEP_TIME = 60 * 5

# Wait for 3 seconds between requests
WAIT_TIME = 3

# Tweets to grab
TWEETS_COUNT = 2

# Search string
Q = '#SupportTwoFactorAuth'

# Type of result: mixed, recent, popular
RESULT_TYPE = 'recent'

# Basic dirs
PWD = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.abspath(os.path.join(PWD, '..'))

# Create base dirs
DATA_DIR = os.path.join(BASE, DATA)


def base_options():
    """
    Base options for searching.

    """

    options = {}

    options['q'] = Q
    options['result_type'] = RESULT_TYPE
    options['count'] = TWEETS_COUNT

    return options


class TFABot(object):
    def __init__(self, client):
        self.client = client
        self.since_id = START_TWEET

        self.tweets = self.load_existing()

    def load_existing(self):
        tweets_path = os.path.join(DATA_DIR, TWEETS_FILE)

        existing = []
        if os.path.exists(tweets_path):
            with open(tweets_path) as tweets_file:
                data = yaml.load(tweets_file)
                existing = data.get('tweets', [])

        sorted_tweets = sorted(existing, key=lambda k: k['id'])
        return sorted_tweets

    def sleeping(self):
        return False

    def finished(self):
        return False

    def sleep(self):
        time.sleep(SLEEP_TIME)

    def search(self):
        print 'Searching...'

        options = base_options()

        options['since_id'] = self.since_id
        data = self.client.search(**options)

        meta = data['search_metadata']
        print meta
        statuses = data['statuses']

        self.tweets.extend(statuses)

        # Assign for next time..
        self.since_id = meta['max_id_str']
        print 'MAx id:', self.since_id

    def wait(self):
        time.sleep(WAIT_TIME)

    def finish(self, signal, frame):
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

        sorted_tweets = sorted(self.tweets, key=lambda k: k['id'])

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
        while self.finished() is False:
            if self.sleeping():
                self.sleep()
            else:
                self.search()
                self.wait()


if __name__ == '__main__':
    client = Twython(APP_KEY, access_token=ACCESS_TOKEN)
    bot = TFABot(client)

    # Setup interrupts
    signal.signal(signal.SIGINT, lambda s, f: bot.finish(s, f))

    bot.loop()
