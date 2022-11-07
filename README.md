# Data gathering

I'm creating a visualization of the most popular Mechanical Keyboard switches derived from the `r/MechanicalKeyboards` subreddit. I will use the reddit API to parse comments and posts from the subreddit and extract chunks of text relating to switches. I'll use Sentiment Analysis to deduce whether these comments are positive or negative comments regarding quality of the switch

# Results

I collected comments from the top 1000 posts on the MechanicalKeyboards subreddit. Using natural language processing and sentiment analysis, I gave each of the most popular switch brands a score based on upvotes/downvotes and comment sentiment. In short, upvotes on a positive comment added to the score, while downvotes on a positive comment subtracted. The opposite is true for negative comments, and neutral comment votes had no effect on score. I then weighed each score based on the number of comments/popularity. More positive comments got an extra boost to their score based on how many comments (out of the total 150 comments) Each comment was given a sentiment score from -1 (negative) to 1 (positive). Then, the sentiment scores were averaged for each brand. 

============= Kailh  =============
Average Sentiment: -0.7181819 (Negative)
Score: -33
Comments: 44

============= Razer  =============
Average Sentiment: -0.80000013 (Negative)
Score: 19
Comments: 19

============= Cherry  =============
Average Sentiment: 0.70434785 (Positive)
Score: 91
Comments: 23

============= Boba  =============
Average Sentiment: -0.06190476 (Negative)
Score: -4
Comments: 42

============= Gecko  =============
Average Sentiment: 0.0 (Neutral)
Score: -95
Comments: 19

============= Gateron  =============
Average Sentiment: 1.0 (Positive)
Score: 4
Comments: 3