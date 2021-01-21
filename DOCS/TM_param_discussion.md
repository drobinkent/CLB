## Delay:
Leaf, spine and super spine-- 3 types of switch. They work in 3 different level granularity. As an example: leaf switch's 
downstream connectivity is with hosts. So it can directly map delay for a host from itself. But it can not measure the delay between a 
host in some other subnet. If we want to track that,, we can do that, but that will be  not scalable.

So we will tag each packet with the timestamp after it reaches to a leaf switch from the host. 

So leaf switch works in 112 bit prefix length, spine switches works on 96 bit super spine works on 80 bit. 