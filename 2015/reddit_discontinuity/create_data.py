__author__ = "Anton Tarasenko <antontarasenko@gmail.com>"

import pandas as pd

with open('redditlist.com.txt') as fp:
    lines = fp.readlines()

items = list()
c = 0
for i in lines:
    if c % 3 == 2:
        k, v = i.strip().split(' ')
        v = int(v.replace(',', ''))
        items.append((k, v))
    c = c + 1

df = pd.DataFrame(items, columns=['subreddit','subscribers'])
df = df.set_index('subreddit', drop=False)

dump13 = pd.read_json('github.com_top.json')
dump13['subreddit'] = dump13['uri'].map(lambda x: x.split('/')[-2])
dump13['subscribers13'] = dump13['subscribers']
dump13.drop(['uri', 'name', 'subscribers'], axis=1, inplace=True)
dump13 = dump13.set_index('subreddit')

df = df.join(dump13, how='left')

reddit_horiz = pd.read_csv('reddit.com_horizontal.txt')['subreddit'].tolist()
reddit_dropdown = pd.read_csv('reddit.com_dropdown.txt')['subreddit'].tolist()

df['in_horiz_menu'] = df['subreddit'].isin(reddit_horiz)
df['in_dropdown_menu'] = df['subreddit'].isin(reddit_dropdown)

df.to_csv('top_100.csv', index_label=False)
