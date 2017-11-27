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
![Real life examples](https://witestlab.poly.edu/blog/content/images/2016/02/dd-july2015outages.svg)
###### Offline time due to network outages has a negative effect on companies because they are inefficient and costly. In the summer of 2015, there were several outages which deeply hurt companies and individuals. On July 6th, 2015, a broken fiber optic cable disconnected the North Mariana Islands from the internet. [Downtime lasted for approximately two days and affected approximately 50,000 people](https://arstechnica.com/information-technology/2015/07/broken-cable-reportedly-disconnected-us-island-territory-from-internet/). The second event happened on July 8th, 2015, when a failed router brought down the United Airlines reservation system. Although downtime only lasted for 90 minutes, the outage led to [60 cancelled flights and 800 delayed flights](http://www.latimes.com/business/technology/la-fi-tn-technical-problems-united-nyse-20150708-story.html). Lastly, on July 17th, 2015, vandals cut a fiber optic cable which took down the internet, phone and 911 services for thousands of AT&T and Verizon customers in three counties in California. [This incident has occurred 11 times in the past since July 2014 and downtime on this occasion lasted for approximately 22 hours](https://arstechnica.com/tech-policy/2015/07/vandals-keep-snipping-fiber-optic-cables-in-california-with-impunity/).
![](https://witestlab.poly.edu/blog/content/images/2016/02/dd-background.svg)
###### Another way to potentially increase network resiliency is by sharing links. There are many redundant links between ISP routers that belong to different ISPs. If one ISP is experiencing a failure due to a network outage, the other ISP might be willing to carry the ISP’s network traffic on its own links temporarily. Overall, this agreement provides a safety net to all ISPs in case of an outage bringing down any one ISPs’ links.
![](https://witestlab.poly.edu/blog/content/images/2016/02/dd-topology.svg)
###### To test the effects of sharing on two ISPs, we set up the network topology shown above. (Green represents ISP 1, purple represents ISP 2, lines represent links, and circles represent customers.) This topology consists of three nodes representing ISP routers, each connected to a neighbouring router by two separate links, belonging to two different ISPs. Each ISP router is then connected to two other nodes which represents a customer of each ISP. To create one, two, three, or four outages, we brought down the specific links shown above.
---
## Results
#### The results are summarized in the following image:
![](https://witestlab.poly.edu/blog/content/images/2016/02/dd-results.svg)
###### Green represents ISP 1 (A1/A2 nodes), purple represents ISP 2 (B1/B2 nodes), solid lines represent links carrying traffic belonging to the ISP who owns the link ("non-sharing"), and dotted lines represent "sharing" links.
###### Sharing allowed users to communicate with more outages. When there was no sharing among the two ISPs and there were three outages, two of the nodes were completely disconnected. However, when there was sharing between the two ISPs and there were four outages, all nodes were connected through backup sharing routes.
### No outages
###### When there are no outages, our traceroute results show that we can take the most direct route from a1 to a2: 
```bash
traceroute to a2 (10.1.2.2), 30 hops max, 60 byte packets  
 1  p1-link-1 (10.1.1.1)  0.613 ms  0.579 ms  0.587 ms
 2  p2-link-0 (10.1.12.2)  0.957 ms  1.008 ms  0.968 ms
 3  a2-link-7 (10.1.2.2)  1.488 ms  1.453 ms  1.413 ms
 ```
 ###### & similarly from b1 and b2
 ```bash
 traceroute to b2 (10.2.2.2), 30 hops max, 60 byte packets  
 1  p1-link-2 (10.2.1.1)  0.755 ms  0.679 ms  0.580 ms
 2  p2-link-3 (10.2.12.2)  1.167 ms  1.116 ms  1.055 ms
 3  b2-link-6 (10.2.2.2)  2.220 ms  2.179 ms  2.100 ms
 ```
 ### One outage, no sharing
 ###### When the "purple" link between b1 and b1 is brought down (one outage) and there is no sharing, a1 and a1 are still able to connect using direct routes: 
 ```bash
 traceroute to a2 (10.1.2.2), 30 hops max, 60 byte packets  
 1  p1-link-1 (10.1.1.1)  0.577 ms  0.568 ms  0.547 ms
 2  p2-link-0 (10.1.12.2)  0.986 ms  0.990 ms  0.963 ms
 3  a2-link-7 (10.1.2.2)  1.356 ms  1.313 ms  1.264 ms
 ```
 ###### & b1 and b2 are able to connect with more latency using back-up routes.
 ```bash
 traceroute to b2 (10.2.2.2), 30 hops max, 60 byte packets  
 1  p1-link-2 (10.2.1.1)  0.641 ms  0.573 ms  0.480 ms
 2  p3-link-5 (10.2.13.3)  1.378 ms  1.277 ms  1.102 ms
 3  * * *
 4  b2-link-6 (10.2.2.2)  2.296 ms  2.203 ms  2.125 ms
 ```
 ### Two outages, no sharing
 ###### Next, we create the two-outage condition by bringing down the "green" link connecting a1 and a2. When there is no sharing and two outages, we see that both a1 and a2 and b1 and b2 are able to connect with more latency using back-up routes.
 ```bash
 traceroute to a2 (10.1.2.2), 30 hops max, 60 byte packets  
 1  p1-link-1 (10.1.1.1)  0.674 ms  0.617 ms  0.556 ms
 2  p3-link-4 (10.1.13.3)  1.073 ms  1.024 ms  0.976 ms
 3  * * *
 4  a2-link-7 (10.1.2.2)  2.412 ms  2.373 ms  2.264 ms
 ```
 
 ```bash
 traceroute to b2 (10.2.2.2), 30 hops max, 60 byte packets  
 1  p1-link-2 (10.2.1.1)  0.677 ms  0.606 ms  0.547 ms
 2  p3-link-5 (10.2.13.3)  1.083 ms  1.205 ms  1.161 ms
 3  * * *
 4  b2-link-6 (10.2.2.2)  2.020 ms  1.979 ms  1.952 ms
 ```
 
 ### Three outages, no sharing
 ###### When there is no sharing and three outages, we see that both a1 and a2 are able to connect with more latency than before using back-up routes:
```bash
traceroute to a2 (10.1.2.2), 30 hops max, 60 byte packets  
 1  p1-link-1 (10.1.1.1)  0.673 ms  0.633 ms  0.574 ms
 2  p3-link-4 (10.1.13.3)  0.972 ms  1.026 ms  0.989 ms
 3  * * *
 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  * * *
 9  * * *
10  * * *  
11  * * *  
12  * * *  
13  * * *  
14  p3-link-4 (10.1.13.3)  2997.938 ms !H  2997.913 ms !H  2997.850 ms !H  
```
###### while b1 & b2 don't connect at all!
```bash
traceroute to b2 (10.2.2.2), 30 hops max, 60 byte packets  
 1  p1-link-2 (10.2.1.1)  0.716 ms  0.760 ms  0.704 ms
 2  p3-link-5 (10.2.13.3)  1.113 ms  1.061 ms  1.039 ms
 3  * * *
 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  * * *
 9  * * *
10  * * *  
11  * * *  
12  * * *  
13  * * *  
14  * * *  
15  * * *  
16  * * *  
17  *^C  
```
---
### One outage, with sharing
###### When there is sharing and one outage, we see that both a1 and a2 are able to connect with direct routes, and b1 and b2 are able to connect using direct sharing routes:
```bash
traceroute to a2 (10.1.2.2), 30 hops max, 60 byte packets  
 1  p1-link-1 (10.1.1.1)  0.738 ms  0.665 ms  0.600 ms
 2  p2-link-0 (10.1.12.2)  1.212 ms  1.170 ms  1.101 ms
 3  a2-link-7 (10.1.2.2)  1.576 ms  1.522 ms  1.464 ms
 ```
 ```bash
 traceroute to b2 (10.2.2.2), 30 hops max, 60 byte packets  
 1  p1-link-2 (10.2.1.1)  1.311 ms  1.258 ms  1.212 ms
 2  p2-link-0 (10.1.12.2)  1.666 ms  1.620 ms  1.552 ms
 3  b2-link-6 (10.2.2.2)  2.950 ms  2.912 ms  2.848 ms
 ```
 ###
