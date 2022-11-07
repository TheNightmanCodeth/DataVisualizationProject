# Data gathering

I'm creating a visualization of the most popular Mechanical Keyboard switches derived from the `r/MechanicalKeyboards` subreddit. I will use the reddit API to parse comments and posts from the subreddit and extract chunks of text relating to switches. I'll use Sentiment Analysis to deduce whether these comments are positive or negative comments regarding quality of the switch

# Results

I collected comments from the top 1000 posts on the MechanicalKeyboards subreddit. Using natural language processing and sentiment analysis, I gave each of the most popular switch brands a score based on upvotes/downvotes and comment sentiment. In short, upvotes on a positive comment added to the score, while downvotes on a positive comment subtracted. The opposite is true for negative comments, and neutral comment votes had no effect on score. I then weighed each score based on the number of comments/popularity. More positive comments got an extra boost to their score based on how many comments (out of the total 150 comments) Each comment was given a sentiment score from -1 (negative) to 1 (positive). Then, the sentiment scores were averaged for each brand. 

|         | Average Sentiment      | Score | Comments |
|---------|------------------------|-------|----------|
| Kailh   | -0.7181819 (Negative)  | 69.9  | 44       |
| Razer   | -0.80000013 (Negative) | 120.2 | 19       |
| Cherry  | 0.70434785 (Positive)  | 192.5 | 23       |
| Boba    | -0.06190476 (Negative) | 98.8  | 42       |
| Gecko   | 0.0 (Neutral)          | 6.2   | 19       |
| Gateron | 1.0 (Positive)         | 104.2 | 3        |

# Sidenotes
The app doesn't actually do anything. I simply couldn't figure out how to get combine publishers working on a swift command line package and didn't want to spend all afternoon figuring it out. When you run the app it simply logs the results to the console. Be warned there is a 2 second per request cool down, and that applies to each comment because I couldn't figure out how to work the Reddit API properly. It takes about an hour to run for 1000 posts on the MechanicalKeyboards sub, since it's not *that* active.
