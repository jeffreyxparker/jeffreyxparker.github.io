---
layout:     post
title:      "Round Peg for a Square Hole"
subtitle:   "City Blocks vs. Hexagons"
date:       2016-03-29 12:00:00
author:     "Jeff Parker"
header-img: "img/city_blocks_master.jpg"
---
***NOTE: Originally composed for [Northwestern's Master of Analytics (MSIA) Student Research Blog](http://sites.northwestern.edu/msia/2017/05/23/computers-can-compose-music-but-can-they-write-scripture/) and posted March 29, 2016. I was a student in the program at the time of posting.***

Driving to the O’Hare airport in Chicago takes a whopping 1 hour and 15 minutes to travel a mere 8 miles from my wife’s work. The fastest route zig-zags through the suburbs on streets of various sizes and directions. We travel west and south inevitably hitting every traffic light at every intersection.

Chicago, despite a few cross-cut and diagonal streets, follows a loose grid system. My hometown of Salt Lake City, like most modern cities, follows a pattern of square blocks. The simple design was originally conceived by the city founders as the “Platte of Zion.” Square blocks and grid systems have since become the standard for urban design.

<a href="#">
    <img src="{{ site.baseurl }}/img/city_blocks_img1.jpg" alt="Post Sample Image">
</a>

But what we are wrong using square blocks? Squares and rectangles are very efficient shapes for humans. We put things in square boxes, read square books, live in square rooms and build square houses. However, nothing in nature is square. Rivers wind, hills rolls and mountains come to peaks. As it relates to urban-planning, human expansion is not square and therefore neither should cities. Cities are circular. Square boxes are great if filling up a square closet, but are square blocks really great for filling a circular city? To compare, I packed a circle with unit squares (Note this is not the optimal way to pack a circle). I found the optimal radius for this circle is 2.12 and I packed the same circle with hexagons. The square blocks wasted ~5 units of space, while the hexagons wasted only ~3. 
 
<a href="#">
    <img src="{{ site.baseurl }}/img/city_blocks_img2.png" alt="Post Sample Image">
</a>

This gave me a thought: what if city blocks were not squares, but rather hexagons? From above, the city would look like the board from Settlers of Catan. Streets would follow a honeycomb pattern - bees are very efficient creatures.

<a href="#">
    <img src="{{ site.baseurl }}/img/city_blocks_img3.png" alt="Post Sample Image">
</a>

To test the efficiency of hexagon blocks versus square blocks, I need to make a few assumptions. In my test, each city block will have the same amount of departure and arrival points (called nodes). There are no nodes on the corners or intersections. (There may be a store on the corner, but people depart from the edge of the store). Both shapes have the same number of nodes: blocks have three nodes on each side (3 nodes X 4 sides) while hexagons have 2 nodes on each side (2 nodes X 6 sides). Lastly, the area of both hexagons and blocks are the same, exactly 1. 

<a href="#">
    <img src="{{ site.baseurl }}/img/city_blocks_img4.png" alt="Post Sample Image">
</a>

Total Nodes: 108; Total Blocks 9; Block Size: 1; Total Area: 9
Running a simulation with 10 samples on my small 9 block city, it appears that Blocks have the advantage. While this was surprising to me, I does make sense. Despite the same area, my hexagon city is both taller and wider than my block city. I would be curious to run this on a larger scale with more city blocks packed into a circle in a different pattern. Perhaps, I would get different results if I included every node within a certain radius of my city’s center.

| Sample | Start | End     | Blocks | Hex   |
|--------|-------|---------|--------|-------|
| 1      | 12    | 37      | 1.5    | 1.56  |
| 2      | 43    | 97      | 2      | 2.86  |
| 3      | 42    | 76      | 1.5    | 3.12  |
| 4      | 12    | 61      | 2.5    | 2.34  |
| 5      | 98    | 38      | 3.25   | 4.42  |
| 6      | 91    | 16      | 4      | 5.46  |
| 7      | 51    | 61      | 1.5    | 1.04  |
| 8      | 2     | 42      | 2.25   | 3.12  |
| 9      | 62    | 71      | 0.75   | 1.04  |
| 10     | 27    | 30      | 2.5    | 3.12  |
|        |       | Average | 2.175  | 2.808 |

There are a couple other advantages to hexagon blocks to consider. Three-way intersections are quite a bit faster than 4-way intersections. Vehicles turning right would not need to stop and could have the right of way. Vehicles turning left would have to yield to cars turning right. This would mean a decrease in time waiting at lights.

In addition to longer distances, another obvious disadvantage to the hexagon blocks is that turning right and left all the time would make going in a straight line annoying. However, hexagon blocks lend themselves well to the addition of major thorough-fares or highways. On-ramps and off-ramps are already built in.
 
<a href="#">
    <img src="{{ site.baseurl }}/img/city_blocks_img5.png" alt="Post Sample Image">
</a>
 
It looks like a few forward thinking city planners have already been experimenting with this pattern. I am excited to see urban designs in the future.
