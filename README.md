# d3 + ggplot2 = minifolds alpha

It's often much easier to understand a chart than a table. So why is it still so hard to make a simple data graphic, and why am I still bombarded everyday by mind-numbing mishmashes of raw *numbers*?

(Yeah, I love [ggplot2](http://blog.echen.me/2012/01/17/quick-introduction-to-ggplot2/) to death. But sometimes I want something a little more interactive, and sometimes all I want is to drag-and-drop and be done.)

So I've been experimenting with [a small, ggplot2-inspired d3 app](http://minifolds.herokuapp.com/graphs/1?x=health&y=speed&size=intelligence&color=age&group=height).

Simply drop a file (along with optional information like a description, to better keep track of all your data), and bam! Instant scatterplot:

[![Swiss Roll B&W](http://dl.dropbox.com/u/10506/blog/minifolds/swiss-roll-bw.png)](http://minifolds.herokuapp.com/graphs/1?x=health&y=speed)

But wait -- that's only 2 dimensions. You can add some more through color, size, and groups:

[![Swiss Roll](http://dl.dropbox.com/u/10506/blog/minifolds/swiss-roll.png)](http://minifolds.herokuapp.com/graphs/1?x=health&y=speed&size=intelligence&color=age&group=height)

[![Swiss Roll Edit](http://dl.dropbox.com/u/10506/blog/minifolds/swiss-roll-edit-1.png)](http://minifolds.herokuapp.com/graphs/1?x=health&y=speed&size=intelligence&color=age&group=height)

And you can easily switch between what's getting plotted, and see all the information associated with each point.

[![Swiss Roll Pivot](http://dl.dropbox.com/u/10506/blog/minifolds/swiss-roll-pivot.png)](http://minifolds.herokuapp.com/graphs/1?x=health&y=speed&size=intelligence&color=age&group=height)

(Same dataset, but different aesthetic assignments.)

Next, I'm thinking of adding more kinds of charts, support for categorical variables (columns are assumed to be numeric right now), more interactivity (sliders to interact with other dimensions?!), and making the UI even easier (e.g., simplify column naming). In the meantime, the code is [here](https://github.com/echen/minifolds) on Github, and tips and suggestions are welcome!