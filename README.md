# FantasySportsPro

Play fantasy sports using machine learning!

## Program Design

There are 4 main components to this program (designated in the diagram below):

1. **Downloader**: Downloads fantasy player data from a Fantasy Site (e.g. Yahoo) and other raw data from third-party sites
1. **Assimilator**: Assimilates the raw data into tabular format and outputs it to `data.csv`
1. **Machine Learning**: Inputs `data.csv` and uses machine learning to make fantasy point predictions for each player
1. **Lineup Generator**: Generates an optimal lineup based on the fantasy point predictions

Once you have the lineup, you're ready to play on your favorite fantasy site!

[[https://github.com/dandoozan/FantasySportsPro/blob/master/ProgramDesign.png|alt=program design]]
