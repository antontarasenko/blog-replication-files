import json
import os
import pandas as pd

__author__ = "Anton Tarasenko <antontarasenko@gmail.com>"


# NYT Chronicles data
# http://chronicle.nytlabs.com/?keyword=prohibition

chronicle = pd.DataFrame()
for file in os.listdir():
    if file.startswith("c-"):
        with open(file) as f:
            data = json.load(f)
            i = data['graph_data'][0]['term']
            word = pd.DataFrame(data['graph_data'][0]['data'])
            word[i] = word['article_matches'] / word['total_articles_published']
            word = word.set_index('year')
            chronicle = chronicle.join(word[i], how='outer')

chronicle_mean = chronicle[['terrorism', 'terrorist']].T.mean()
chronicle_mean.name = 'mentions of "terrorism" or "terrorist"'


# Terrorist attacks and casualties
# "globalterrorismdb_0814dist.xlsx" comes from:
# http://www.start.umd.edu/gtd/contact/

# And reading the file takes a couple of minutes
ta = pd.read_excel("globalterrorismdb_0814dist_us.xlsx").fillna(0)
ta['attacks'] = 1
attacks = ta[['iyear', 'attacks', 'nkill', 'nkillus']].groupby('iyear').agg('sum').reset_index()
attacks = attacks.rename(columns={'iyear': 'year', 'attacks': 'terrorist attacks', 'nkill': 'casualties', 'nkillus': 'US casualties'})
attacks = attacks.set_index('year')


# Plotting
compare = ['terrorist attacks', 'casualties', 'US casualties']
for c in compare:
    df = attacks[[c]].join(chronicle_mean, how='outer')
    plot = df[df.index >= 1970].plot(secondary_y=[c], figsize=(12, 8), linewidth=2)
    plot.set_title('Terrorism and The New York Times mentions: %s' % c)
    plot.set_ylabel('Average fraction of all publications')
    plot.set_xlabel('Year')
    plot
    plot.get_figure().savefig("comparison_%s" % c)
