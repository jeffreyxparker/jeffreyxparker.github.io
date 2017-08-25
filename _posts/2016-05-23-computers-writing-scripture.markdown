---
layout:     post
title:      "Computers can compose music… but can they write scripture?"
subtitle:   "Data science approaches to replicate a deeply human task"
date:       2016-05-23 12:00:00
author:     "Jeff Parker"
header-img: "img/newtestament_0.jpg"
---
<p><i><b>NOTE: Originally composed for <a href = "http://sites.northwestern.edu/msia/2017/05/23/computers-can-compose-music-but-can-they-write-scripture/">Northwestern's Master of Analytics (MSIA) Student Research Blog</a> and posted May 23rd, 2016. I was a student in the program at the time of posting.</b></i></p>
<p>I was so impressed to learn from a peer that computer programs have been written to compose music. Music is widely considered an art that takes innately human abilities to craft pleasing sounds. Computers are dull and inanimate while music is alive and human. I do not have a musical background, but after investigating this “artificial” music, I realized that the programs analyze sounds and patterns to piece together new compositions.</p>

<p>So if computers can compose music, something so deeply personal and human, I thought, what else deeply personal can they do? An idea sparked when I asked my wife late at night to tell me her favorite scripture verse in lieu of reading a chapter as is our nightly custom. My wife was too sleepy to read, in her drowsy voice gabbled what sounded like a random assortment of the most common biblical words, “For behold, thus sayeth the Lord, verily I say unto thee, that…” It was hilarious, but to the untrained ear, could have passed as a legitimate passage.</p>

<p>The English language, much like music, follows certain patterns – any English major would agree. There are subjects and predicates instead of tunes; nouns and verbs instead of notes. The language of the ancient Jewish, Greek and Roman authors as translated by English monks certainly follows a very distinct pattern. Many bible scholars and linguistic experts have written much on this. I thought I might try my hand at using a computer to “artificially” write scripture.</p>

<p>I should note that the Bible is something that is deeply personal and intimate for many people (as is music). For others, it is a very divisive subject. My humble attempts here are not to make a mockery of the Bible or to advocate it, but rather just to explore linguistic patterns using a scientific process. Wherever you fall on a religious spectrum, I think much can be learned from this type of text analysis. For instance, there are 5,975 unique words in 7,958 verses in the King James Version of the New Testament. I decided to focus solely on the New Testament, because 1) it is more recent, 2) it takes place over a shorter period of time than the Old Testament and 3) it is both shorter for computing purposes and easier to understand. All my R code can be found <a href = "https://github.com/jeffreyxparker/scripture_analysis/tree/master">here</a>. Below are the most common terms in the New Testament (“the”, “and”, and “that” are excluded):</p>

<a href="#">
    <img src="{{ site.baseurl }}/img/computers_writing_scripture_img1.png" alt="Post Sample Image">
</a>
 
<p>Just using the most common words, I can manually piece together something that sounds like a scripture verse:</p>

<p>“<font face = "Old English Text MT" size = "6">A</font>ND UNTO HIM THAT ARE MAN, THOU SHALL DOETH ALL THINGS THAT WERE FROM THE LORD GOD, FOR THEY THAT ARE WITH THEM ARE THEY WHICH HAVE NOT, SAID JESUS” </p>

<h2>Approach 1 – Subsequent Terms</h2>

<p>I decided on three approaches to craft my “artificial” scripture. The first is to pick a first word (a seed word) and calculate which word is most likely to follow that. Then the word most likely to follow that word. And so on till something makes sense.</p>

<a href="#">
    <img src="{{ site.baseurl }}/img/computers_writing_scripture_img2.png" alt="Post Sample Image">
</a>
 
<p>Using the second most common starting term “FOR” I started down a path till I got the following: “FOR THE LORD JESUS CHRIST…” At this point, the most common word following CHRIST is JESUS which would put the verse into an infinite loop. So I choose the second most common word following Jesus. I had to do this a few times. Here is my final verse:</p>

<p>“<font face = "Old English Text MT" size = "6">F</font>OR THE LORD JESUS CHRIST, AND HE THAT YE HAVE NOT BE NOT IN THE SAME. SHALL BE THE PEOPLE THAT THEY WERE COME TO THE SON.”</p>

<p>Not too bad. It is fun to see how the verse wanders down different paths. However, the biggest problem with this method is that the next word is solely dependent on the previous word. The subsequent words have no memory of previous words. If I was to add a bit of memory to my algorithm to account for phrases, our verse would have wandered down a different path. This memory could be added by using the preceding two words instead of just one. The word following “THAT THEY” is “SHOULD” and would have taken the verse in a different direction. It would be fun to write an algorithm to look at the two preceding words (the two nearest neighbors from K-NN techniques). I would also like to try a decaying weight on the preceding words (similar to kernel weighting regression).</p>

<h2>Approach 2 – Market Basket</h2>

<p>This idea is to use rule associations used in market basket analysis to find words that commonly appear in the same verse. Again after picking a seed word, I will find the word that is mostly likely to appear in the same verse. Then take the second word and find the word most likely to appear with that word. So on and so till I have a good collection of words. Then I will manually arrange them into something that looks like a verse.</p>

<p>The first step to this is to convert my data into transactions and look at some rules. This graph looks at the words that appear in 10% or more of the verses, or in market basket parlance, support greater than 10%.</p>

<a href="#">
    <img src="{{ site.baseurl }}/img/computers_writing_scripture_img3.png" alt="Post Sample Image">
</a>
 
<p>Market basket analysis looks at sets, so we if we expand the sets to several words, we get some great conglomerates of words that occur often together in a verse. I looked at sets of words with high support, here are few that stuck out to me:</p>

“<font face = "Old English Text MT" size = "6">A</font>ND JESUS CHRIST THE LORD, OUR GOD…” Support = 0.004146771<br>
“<font face = "Old English Text MT" size = "6">A</font>ND JESUS SAID UNTO HIM, THOU THAT THE…” Support = 0.003518472<br>
“<font face = "Old English Text MT" size = "6">F</font>ATHER FROM GRACE, JESUS THE LORD OF OUR PEACE…” Support = 0.001633576<br>

<p>My next step is to pick a seed topic and find words around that topic. Using the same seed word as in approach 1, I started with “FOR”. The word pair with the highest support with “FOR” is “THE”… No surprises there. I hit an infinite loop when I got to the word “THAT” so I skipped to the next highest support. In fact, {and,that,the} have very high support. Below you can see my chaining:</p>

<table>
  <tr>
    <th>Start Word</th>
    <th>Word Pair (Market Basket)</th>
    <th>Support</th>
  </tr>
  <tr>
    <td>FOR</td>
    <td>{for,the}</td>
    <td>0.1662478</td>
  </tr>
  <tr>
    <td>THE</td>
    <td>{the,and}</td>
    <td>0.4938427</td>
  </tr>
  <tr>
    <td>AND</td>
    <td>{and,that}</td>
    <td>0.2484293</td>
  </tr>
  <tr>
    <td>THAT</td>
    <td>{that,unto}</td>
    <td>0.102915</td>
  </tr>
  <tr>
    <td>UNTO</td>
    <td>{him,unto}</td>
    <td>0.090852</td>
  </tr>
  <tr>
    <td>HIM</td>
    <td>{him,they}</td>
    <td>0.057929128</td>
  </tr>
  <tr>
    <td>THEY</td>
    <td>{them,they}</td>
    <td>0.056798191</td>
  </tr>
  <tr>
    <td>THEM</td>
    <td>{said,them}</td>
    <td>0.040965067</td>
  </tr>
  <tr>
    <td>SAID</td>
    <td>{jesus,said}</td>
    <td>0.031917567</td>
  </tr>
  <tr>
    <td>JESUS</td>
    <td>{christ,jesus}</td>
    <td>0.032168887</td>
  </tr>
</table>

<p>Now manually putting my words together:</p>

<p>“<font face = "Old English Text MT" size = "6">J</font>ESUS CHRIST SAID UNTO THEM ‘AND THEY THAT THE’…”</p>

<p>Honestly, I was a little disappointed with this method. I tried this pattern using other seed words as well. A major drawback to the association rules is that sentences are sequenced while market baskets are not. The market basket calculates the most commonly used words in a sentence, whether the word came before or after, it does not discriminate. So this method does not capture the natural pattern of speech.</p>

<h2>Approach 3 – Deep Learning</h2>

<p>My last approach is to use deep learning techniques to generate the text. I have much to learn about deep learning, but fortunately, my professor, Dr. Ellick Chan, pointed me to some code on GitHub that students had used previously to generate song lyrics. I did not write any of the code, I just used it straight out of the box, but using the same New Testament as the corpus. Just for fun, I started run epochs before my wife and I went to church, and then I checked it when we got home. Here are some of the best results using the seed “not into the judgment hall, lest they s” which was randomly generated as part of the code:</p>

<p>“<font face = "Old English Text MT" size = "6">A</font>ND HE HAD SENT JOHN SAID UNTO THEM, YE HAVE DISOBEDIENT, THAT IT IS THE SON OF MAN AS HE THAT GIVEN THEM ALL THE LAW IN THE SAME IS FAITH AND OF THE WORLD OF MAN OF THE LORD AND EVERY ON.”</p>

<p>I am really excited to learn more about deep learning and start playing with the code. The code actually generates based on individual characters. It is pretty remarkable that it generates actual words. However, I would like to change it so it uses words instead.</p>

<h2>Conclusion</h2>

<p>My intuition going into this exercise was that my approaches would get progressively better. I thought Approach 3 (Deep Learning) would do better than Approach 2 (Market Basket) which would do better than Approach 1 (Subsequent Terms). As a human reader you can be the judge, but personally, I think Approach 1 did the best. This is because this method captured the sequenced patterns of sentences (a noun is followed by a connector which is followed by an adverb, etc.). It think with some tuning the Deep Learning approach could also return some more interesting results.</p>

<p>Ultimately, after this exercise, I learned a lot about text analytics and a little about the New Testament as well. It was very entertaining for me to read and generate the scriptures. I am excited to see what other deeply human concepts computers can mimic in addition to writing scripture and composing music.</p>