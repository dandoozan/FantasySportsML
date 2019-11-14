# Alley-oop

Play fantasy sports using machine learning!

## Program Design

There are 4 main components to this program (designated in the diagram below):

1. **Downloader**: Downloads fantasy data and historical data/extra features from third-party sites
1. **Assimilator**: Assimilates the raw data into tabular format and outputs it to `data.csv`
1. **Machine Learning**: Builds model based on historical data, then predicts each player's fantasy points
1. **Lineup Generator**: Generates an optimal lineup based on the fantasy point predictions

Once you have the lineup, you're ready to play on your favorite fantasy site!

![Design flow diagram](/README_files/ProgramDesign.png)
