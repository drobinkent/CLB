TOTAL_TOR_SWITCHES=10000 # we want to

# Assuem a leaf spine topologu where each leaf switch has N upword ports. Hence between each pair of leaf switch
# there will be at least N distinct paths (totaly edge disjoint paths between a pair a leaf siwthc can be much more larger ).
# Now, for each of the destination
#
#
#
#
#     flow tuple to hash --> then destination IP as match field and hashcode as action. these actions will be must filled upto there limit.
#
# look at figure 3 of dash paper. that's how  the wcmp will work. add a picture of it in our paper.
#
# Now in our simulation the wcmp table size is a limiting factor.
# Assume for a single destination total upward ports availalbe is P. and we can assign traffic on these
#     P ports according to some distribution. then we will convert this distribution to feasible path-weight distribution.
# at time t0 , we have to keep record how many weight is assigned on a path. assume it is w0
# at time t1 if the weight assigned on this path is w1. then we have to modify w1-w0 entries.
#
# Now assume we have a table size T. with increase in T the number should obviously change.
#
#
# How to convert to a feasible distribution. Assume we have table sizze T and precision = K .
# Then simple asuem table size as T/K. then generate the values according to some distribution in the range 1 to T/K. then simply multiple by K each value.
# and we are done.


def wcmp(tableSize, totalPath, precision, C ):
    we have to fit total range of C using totalPath number of data with each one multiple of K.
    so we can say sum will be C/K (to handle precision) and total entry will be totalPath.

    now generate totalpath number of data with their sum = tablesize/k.

    http://sunny.today/generate-random-integers-with-fixed-sum/