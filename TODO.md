- Figure out using environments with shared Tweet lib
- Figure out a way to load shared lib (aka Tweet) that doesn't require loading from outside a module's directory tree.
- Port tweetagent over as module.
- Port the whole view so it looks ok.
- Nicer translation mouse-overs
- Factor out translation
- Move img/tweet url construction into domain model
- Factor out getting follower counts
- Make follower count differences visually more prominent
- I want to see which links have reached the most followers
- I want to see which links have had the most retweets
- For any link, I want to see what people have said about it
- Factor out link lookup
- Factor out filtering

Later, maybe:
- EC2 deployment w/ puppet, mcollective
- Live updates with Faye

# done
- Make generator script to make modules
- Rake task to start app
- Manage gems with bundler.
