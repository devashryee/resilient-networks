# resilient-networks
#### This experiment shows how redundant links can help aid recovery in the event of a network outage.
###### This was written with the help of [Fraida Fund](https://github.com/ffund), my mentor for the [ARISE Summer Research Program](http://engineering.nyu.edu/k12stem/arise/).
###### It should take about 60-120 minutes to run this experiment, from start (reserving resources) to finish.
###### To reproduce this experiment on GENI, you will need an account on the [GENI Portal](http://groups.geni.net/geni/wiki/SignMeUp), and you will need to have [joined a project](http://groups.geni.net/geni/wiki/JoinAProject). You should have already [uploaded your SSH keys to the portal and know how to log in to a node with those keys](http://groups.geni.net/geni/wiki/HowTo/LoginToNodes).
---
## Background
###### Today's networks lack the ability to respond gracefully to failure. The loss of network service impacts people deeply because of how reliant they are on technology. In this experiment, we tried designing network recovery paths for internet service providers using sharing links in the event of a network outage.
###### Network resiliency is defined as a network's ability to restore and recover services after facing issues, ranging from hackers, to natural disasters, to hardware malfunctions. Since network outages occur often, networks need improvements.
###### General ways of improving network resiliency include [adding redundant paths between nodes so that these nodes are still able to communicate even when main paths are down](https://calhoun.nps.edu/bitstream/handle/10945/37231/Sterbenz-Cetinkaya-Hameed-Jabbar-Qian-Rohrer-2011.pdf), and [improving network security so that hackers have a harder time accessing valuable data](https://calhoun.nps.edu/bitstream/handle/10945/37231/Sterbenz-Cetinkaya-Hameed-Jabbar-Qian-Rohrer-2011.pdf).
