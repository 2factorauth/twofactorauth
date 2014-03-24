import os
import os.path
import yaml

from slugify import slugify
from string import Template

#
# Config
#

PAGES = 'tweets/'
TRASH = '_trash/'
DATA = '_data/'
TEMPLATE = 'templates/'
TWEETS_TEMPLATE_FILE = 'tweets.template'
SLUGS_FILE = 'slugs.yml'

# Basic dirs
PWD = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.abspath(os.path.join(PWD, '..'))

# Bot dirs
TEMPLATE_DIR = os.path.join(PWD, TEMPLATE)
TWEETS_TEMPLATE = os.path.join(TEMPLATE_DIR, TWEETS_TEMPLATE_FILE)

# Create base dirs
PAGES_DIR = os.path.join(BASE, PAGES)
TRASH_DIR = os.path.join(BASE, TRASH)
DATA_DIR = os.path.join(BASE, DATA)

# Various state objects
SITES = []
SLUGS = {}


def iterate_sections(data):
    """
    Main execution for the script.

    Looks into the main.yml data file and handles each section.

    """

    for section in data.get('sections', []):
        parse_section(section)


def parse_section(section):
    """
    Iterates over all the websites in the section and creates its own page for
    Jekyll if it doesn't have 2FA support.

    It uses the templates/tweets.template file for simplicity.

    """

    section_path = os.path.join(DATA_DIR, '{}.yml'.format(section['id']))
    section_file = file(section_path)

    section_data = yaml.load(section_file)
    for site in section_data.get('websites', []):
        slug = slugify(site['name'])
        create_new_section(slug, site)


def create_new_section(slug, info):
    print 'Creating section:', slug

    if not info.get('twitter', ''):
        return

    if info.get('tfa', True) is True:
        return

    with open(TWEETS_TEMPLATE) as template_file:
        template_str = template_file.read()
        template = Template(template_str)

        template_output = template.safe_substitute(info)

        tweets_page = os.path.join(PAGES_DIR, '{}.md'.format(slug))

        print '\tNo TFA, creating Tweets page.'
        with open(tweets_page, 'w') as tweets_file:
            tweets_file.write(template_output)

        # Add the new page to the SITES
        SITES.append(slug)

        # Add to tweets.yml
        SLUGS[info['name']] = slug


def touch_dirs():
    """
    Never actually delete anything, just move it to the trash/ directory.

    """

    if not os.path.exists(TRASH_DIR):
        os.mkdir(TRASH_DIR)

    if not os.path.exists(PAGES_DIR):
        os.mkdir(PAGES_DIR)


def cleanup_unused(path):
    for filename in os.listdir(path):
        name, ext = os.path.splitext(filename)

        if name in SITES:
            continue

        old_name = os.path.join(path, filename)
        new_name = os.path.join(TRASH_DIR, filename)
        os.rename(old_name, new_name)


def output_tweet_data():
    slugs_path = os.path.join(DATA_DIR, SLUGS_FILE)

    with open(slugs_path, 'w') as slugs:
        slugs.write(yaml.dump(SLUGS, default_flow_style=False))

if __name__ == '__main__':
    main_path = os.path.join(DATA_DIR, 'main.yml')
    main_file = file(main_path)

    main_data = yaml.load(main_file)

    touch_dirs()
    iterate_sections(main_data)
    cleanup_unused(PAGES_DIR)
    output_tweet_data()
