import json
import os
import urllib.request
import nltk
from nltk.util import ngrams
import pandas as pd
import matplotlib.pyplot as plt

__author__ = "Anton Tarasenko <antontarasenko@gmail.com>"

# Conf

CONG_NUM = range(93, 113)
GRAM_SIZE = [1, 2]
SAMPLE_SIZE = 0

SRC_FNAME = "titles-%d.csv"
SRC_DIR = "data/"
FIG_DIR = "plots/"

KWORDS = [['security', 'freedom'],
          ['communism', 'terrorism'],
          ['budget', 'deficit', 'spending'],
          ['unemployment', 'inflation'],
          ['education', 'health care', 'defense', 'science', 'technology', 'transportation'],
          ['soviet union', 'european union', 'china'],
          # technical plots
          ['healthcare', 'health care'],
          ['employment', 'unemployment'],
          ['soviet', 'communism'],
          ]


# Create the environment
for p in [SRC_DIR, FIG_DIR]:
    if not os.path.exists(p):
        os.makedirs(p)

def import_files(nrows=1000):
    ngrams_panel = dict()

    for nsize in GRAM_SIZE:
        ngrams_panel[nsize] = pd.DataFrame()

        for cong in CONG_NUM:
            titles = pd.read_csv(SRC_DIR + SRC_FNAME % cong, nrows=nrows if nrows > 0 else None)

            ngrams_list = list()
            tokenizer = nltk.tokenize.RegexpTokenizer(r'\w+')

            for title in [i.lower() for i in titles['official_title'].values]:
                tokens = tokenizer.tokenize(title)
                ngrams_list += [' '.join(i) for i in list(ngrams(tokens, nsize))]

            s = pd.Series(ngrams_list).value_counts()
            s.name = cong
            ngrams_panel[nsize] = ngrams_panel[nsize].join(s, how='outer')
            print("%dth Congress included" % cong)

        print("All %d-grams built" % nsize)

    return ngrams_panel


def main():
    ngrams_panel = import_files(SAMPLE_SIZE)

    # General stats
    grams = pd.DataFrame()
    for nsize in ngrams_panel.keys():
        grams = grams.append(ngrams_panel[nsize])

    # Plot keywords
    for words in KWORDS:
        kdf = grams[grams.index.isin(words)].T.fillna(0)
        kdf.index = 1789 + 2 * kdf.index
        kplot = kdf.plot()
        kplot.set_xlabel('US Congress Year')
        kplot.set_ylabel('Mentions')
        kplot.get_figure().savefig(FIG_DIR + "keywords_%s.png" % "-".join(words))

if __name__ == '__main__':
    main()