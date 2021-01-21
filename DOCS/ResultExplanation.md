commit ee0f8f2d8a6ecc94943bd3af5db161245032aa0c (HEAD -> master, origin/master, origin/HEAD)



This commit have the best result that we  will use for our paper. 

Here in the result folder there are 3 variation for large flows only.
In the experiment of those results set hsows that, whenever we are running only one type of flow if we give high rate for 
that traffic class we get better peroformance for that class. So assume if we find a a specific pod  where we want to 
deploy mainly traffic of that class, we can accelerate better the performance. 
WE have to write this result in our paper. 

More tests required for paper 
a) make a test where we only run large flow inside a single pod.  If this gives better result we can say we can 
run special policy for a specific pod to achieve good performance for a special kind of traffic. 

b) Need to run same kind of test for small flows only. 

c) we need to do more test case where we will run even more number of test cases. 