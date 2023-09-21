## Main Features
- NoSQL
- non-relational
- open-source
- leaderless replication
- linearly scalable
    - To double the capacity or double the throughput, double the number of nodes.
- Atomic snapshot

## Partitioning
- Uses a hash function on key to determine the partition
- leaderless replication
    - each replica can accept mutations to every key it owns
    - LWW technique used to reconcile concurrent updates to a key.
- Partitioned data across nodes using Consistent Hashing
    - Vs naive hashing technique => when a node is added/deleted, consistent hashing only has to move a small fraction of the keys

## No support for
- Cross partition transactions
- Distributed joins
- Foreign keys or referential integrity.


## Terminologies
- Node => Single instance of Cassandra
- Gossip => Protocol used by Cassandra nodes to communicate with each other
    - Decides which node will be coordinator
    - Which node is responsible for what ranges
- CQL => Cassandra Query Language
- LWW - Last-Write-Wins