import dracula.draw

# Load existing settings made via :set
config.load_autoconfig()

c.url.default_page = '~/.config/qutebrowser/newpage.html'
c.url.start_pages = '~/.config/qutebrowser/newpage.html'

c.url.searchengines = {
    'DEFAULT':  'https://google.com/search?hl=en&q={}',
    '!dd':      'https://thefreedictionary.com/{}',
    '!gh':      'https://github.com/search?o=desc&q={}&s=stars',
    '!gist':    'https://gist.github.com/search?q={}',
    '!gi':      'https://www.google.com/search?tbm=isch&q={}&tbs=imgo:1',
    '!m':       'https://www.google.com/maps/search/{}',
    '!p':       'https://pry.sh/{}',
    '!r':       'https://www.reddit.com/search?q={}',
    '!t':       'https://www.thesaurus.com/browse/{}',
    '!w':       'https://en.wikipedia.org/wiki/{}',
    '!yt':      'https://www.youtube.com/results?search_query={}'
}

dracula.draw.blood(c, {
    'spacing': {
        'vertical': 6,
        'horizontal': 8
    }
})
