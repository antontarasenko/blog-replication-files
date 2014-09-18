import pandas as pd

__author__ = "Anton Tarasenko <antontarasenko@gmail.com>"


# US Congress data
# N-grams created from
# https://app.enigma.io/table/us.gov.congress.thomas.<xx>.titles
# where "<xx>" is the number of Congress

congress = pd.read_csv('congress_terrorism_mentions.csv')
congress.index = 1789 + 2 * congress['congress']

congress_mean = congress[['terrorism', 'terrorist']].T.mean()
congress_mean.name = 'mentions of "terrorism" or "terrorist" in bills'


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
    df = attacks[[c]].join(congress_mean, how='outer')
    plot = df[df.index >= 1970].plot(secondary_y=[c], figsize=(12, 8), linewidth=2, marker='o')
    plot.set_title('Terrorism and US Congress mentions: %s' % c)
    plot.set_ylabel('Average number of mentions')
    plot.set_xlabel('Year')
    plot.get_figure().savefig("congress_comparison_%s" % c)
