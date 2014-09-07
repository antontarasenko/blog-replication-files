import pandas as pd
import matplotlib as plt

imdb = pd.read_csv("imdb250.csv")
tsp = pd.read_csv("tsp1000.csv")

rcParams['figure.figsize'] = 12, 8
plt.title("They Shoot Pictures: Top 1000"); plt.hist(tsp.Year, bins=range(1920, 2030, 10)); plt.savefig("tsp1000_year.png")
plt.title("IMDb: Top 250"); plt.hist(imdb.year, bins=range(1920, 2030, 10)); plt.savefig("imdb250_year.png")
