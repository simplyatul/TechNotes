# Designing Data Intensive Applications
Book by Martin Kleppmann

## Chapter 1. Reliable, Scalable and Maintainable  Application

- DBs Vs Msg Qs
    - Both store data for some time
    - diff access patterns
    - The boundaries bet them becoming blurred.
    - Redis => Datastore also used as message Qs
    - Kafka => Msg Qs with DB like durable guarantees

- Many applications now a days have demanding and wide ranging requirements
- So no single tool (DBs, Msg Qs, Caches, etc) can meet all storage and data processing needs
- Generally, its application code responsibility to keep caches in sync w/ main DB.

<img src="/resources/images/ddia/Fig-1-1.png" title="Figure 1-1" style="height: 400px; width:800px;"/>

Figure 1-1. One possible architecture for a data system that combines several components.

- Many factors influence design of data systems
    - resource skill and experience (in house and in market at that movement)
    - legacy system dependencies
    - time scale for delivery
    - regulatory constraints
    - Orgs tolerance to risks

### Reliability
- System working as expected even when things go wrong or faults occur.
- can tolerate
    - user making mistakes
    - user using s/w in unexpected way
- system prevents unauthorized access and miss-use
- fault => system deviating from its spec
- failure => system stops providing required service
- Chaos Engineering => Deliberately injecting faults

- Why Reliability matters?
    - outages on e-commerce website
        - lost revenue
        - damages reputation
- So Reliability => Tolerate H/w, S/w and Human Errors
#### H/w faults
- Hard Drive's MTTF (Mean time to failure) => 10-50 years
- So in 10K disk cluster => expect one disk failure per day
- In AWS
    - it is common for a VM to become unavailable
    - bec AWS is designed for flexibility and elasticity over single VM reliability
- It is seldom that large no of h/w components will fail at the same time

#### S/w faults
- Systematic Error
    - harder to anticipate
    - correlated across nodes => causes many systems to fail
    - Cascading failures

#### Human Errors
- Study => config errors by human operators were leading cause of outages than h/w failures
- So design a system such that
    - makes it easy to do right things and discourage the wrong thing
    - provide fully featured non-production env so people can play it
    - Test thoroughly
    - Effective automated testing
    - setup monitoring, telemetry

### Scalability
- Strategies for keeping performance good, even when load increases
- Handle/cope with increased load
    - Concurrent uses 10K ---> 100K
    - data volume increased
- Describe Load in terms of..
    - req/sec to Web App
    - ratio of read/writes to DB
    - hit/miss rate on a cache

#### Twritter's Scaling Challenge
- Post Tweet
    - Avg => 4.6k req/sec
    - Peak => 12k req/sec
- View Home timeline
    - user views tweets by people s/he follows
    - 300k req/sec

- Twitter faces main challenge due to Fanout (fetching user's home timeline)
    - each user follows many people
    - each user is followed by many people
    - Two Approaches to address
##### Approach I
- Make join query on following tables
- This fails on high load. So Twitter switched to [Approach II](Approach II)

<img src="/resources/images/ddia/Fig-1-2.png" title="Figure 1-2" style="height: 400px; width:800px;"/>
Figure 1-2. Simple relational schema for implementing a Twitter home timeline.

##### Approach II
- maintain a cache for user's home timeline
- Insert followee tweet as soon as s/he make a tweet
- Disadv
    - Single tweet => many writes to caches
    - 4.6k tweets/sec * 75 (avg number of followers) = 345K tweets/sec to home timelines caches
    - Celebrity problem
        - some user > 30M followers
        - So single tweets => 30M writes to home caches
    - Not satisfying SLA => deliver tweets withing 5 secs

<img src="/resources/images/ddia/Fig-1-3.png" title="Figure 1-3" style="height: 400px; width:800px;"/>
Figure 1-3. Twitter’s data pipeline for delivering tweets to followers, with load parameters as of November 2012

##### Approach III - Hybrid of both
- for users having much more followers => Approach I
- for rest of the uses with less/avg followers => Approach II
- This provides good performance

#### Describing Performance

<img src="/resources/images/ddia/Fig-1-4.png" title="Figure 1-4" style="height: 400px; width:800px;"/>

Figure 1-4. Illustrating mean and percentiles: response times for a sample of 100 requests to a service.

- Look at it using Two ways
    - increase load, keep system resources (cpu, mem, hdd) unchanged => How system performance is affected
    - increase load and how much resources need to increase to keep performance unchanged.

- Batch processing => cares about throughput
    - e.g. Hadoop
    - number of records processed / sec
- Online systems => cares about response time/Latency
    - time bet client sending req and receiving response

- Mean/Average time is not really good measure
    - it suppresses  outliers

- Think response time not as single number but as a distributive value.
- You get variations in response time bec of
    - context switch of processes
    - network drops
    - TCP retransmissions
    - garbage collection pause
    - page faults resulting in disk seek/read
    - mechanical vibrations in server racks

- median response time = 200 ms => half of request returns in < 200 ms and
half requests take longer than that
- median => 50th percentile => P50
- tail latencies => Higher percentile of response time => how bad your outliers are
    - 95th percentile => p95
    - 99th percentile => p99
    - 99.9th percentile => p999
- p95 response time is 1.5 sec =>
    - 95/100 requests took < 1.5 sec
    - 5/100 requests took > 1.5 sec or more
- p999 => affects 1 in 1000 requests.
- Amazon uses 99.9th percentile for their internal services
    - bec cust w/ slow requests often contains more data on their acct
    - means they made many purchases
    - means they are most valuable
- Amazon study
    - 100 ms increase in response time reduces sales by 1%
    - 1 sec slowdown reduces cust satisfaction metric by 16%
- However, optimizing 99.9th percentile is too expensive.
- E.g SLA
    - median response time < 200 ms
    - 99th percentile under 1 sec
    - service uptime is 99.9% => Downtime allowed 1.44 min/day max Or ~8 Hrs/Year
- It is also required to measure response time at client side

<img src="/resources/images/ddia/Fig-1-5.png" title="Figure 1-5" style="height: 400px; width:800px;"/>
Figure 1-5. When several backend calls are needed to serve a request, it takes just a single slow backend request to slow down the entire end-user request.

- When several backend calls are needed to serve a request (Fanout), it takes just a single slow backend request to slow down the entire end-user request.

#### Coping with Load
- Shared-nothing architecture => distributing load across many machines
- Good architecture involves good mix of pragmatic approaches
    - using many fairly power full machines can still be simpler and cheaper that large number of small VMs
- distributing stateless services is easy than stateful services
- Common wisdom
    - keep your DB on single node (scale up) until scaling cost or high availability requirements forced you to make it distributed.

- However there is no single solution fits all
- Following two systems w/ **same data throughput** are very different
    - System designed to handle 100,000 req/sec each of size 1 kB
        - 10^5 * 10^3 = 10^8 B/sec
    - System designed to handle 3 req/min each of size 2 GB
        - (3 * 2 * 10^9) / 60 = 10^8 B/sec

### Maintainability
- Majority cost of s/w is it's ongoing maintenance and not the initial development cost
- Three design principles
    - Operability
        - makes routine tasks easy
        - Good operations can often work around the limitations of bad (or incomplete) software,
        - But good software cannot run reliably with bad operations
    - Simplicity
        - Easy to understand and modify
        - reducing complexity improves Maintainability
    - Evolvability/Extensibility/Modifiability/Plasticity
        - easy to make changes in future
        - adapt unanticipated uses cases/requirements

## Chapter 2. Data Models and Query Languages
- Relational Model => data is organized into relations (called tables in SQL), where each relation is an unordered collection of tuples (rows in SQL).
- Alternatives to Relational Model were
    - Network/CODASYL Model
        - CODASYL => Conference on Data Systems Languages => was a committee
    - Hierarchical model
        - e.g IBM's IMS DB
- NoSQL => Not only SQL
- NoSQL driving forces
    - greater scalability than Relational Model can easily achieve including very large datasets or very high write throughput
    - OSS s/w over commercial DBs
    - Specialized query operations that are not well supported by relational model
    - more dynamic and expressive data model

<img src="/resources/images/ddia/Fig-2-1.png" title="Figure 2-1" style="height: 400px; width:800px;"/>
Figure 2-1. Representing a LinkedIn profile using a relational schema. Photo of Bill Gates courtesy of Wikimedia Commons, Ricardo Stuckert, Agência Brasil.

- In one-to-many relationships (user-positions or user-education), can represent in three ways
    1. Put positions, education info in separate table in connect using foreign key references
    2. Some Relation DBs (Oracle, IBM DB2, MS SQL Server) support multi-valued data (structured data types or XML data) and support for querying and indexing inside those documents.
    3. Encode jobs, education, and contact info as a JSON or XML document, store in text column in DB, and let apps interpret its structure and content.
        - here you cannot use the DB to query for values inside the encoded column

- data structure like a resume/cv, which is mostly a self-contained document, a JSON representation can be quite appropriate
- Document-oriented DBs
    - MongoDB
    - RethinkDB
    - CouchDB
    - Espresso


- Representing a LinkedIn profile as a JSON document
```json
{
  "user_id":     251,
  "first_name":  "Bill",
  "last_name":   "Gates",
  "summary":     "Co-chair of the Bill & Melinda Gates... Active blogger.",
  "region_id":   "us:91",
  "industry_id": 131,
  "photo_url":   "/p/7/000/253/05b/308dd6e.jpg",
  "positions": [
    {"job_title": "Co-chair", "organization": "Bill & Melinda Gates Foundation"},
    {"job_title": "Co-founder, Chairman", "organization": "Microsoft"}
  ],
  "education": [
    {"school_name": "Harvard University",       "start": 1973, "end": 1975},
    {"school_name": "Lakeside School, Seattle", "start": null, "end": null}
  ],
  "contact_info": {
    "blog":    "https://www.gatesnotes.com/",
    "twitter": "https://twitter.com/BillGates"
  }
}
```

- JSON lacks schema however the lack of a schema is often cited as an advantage
- JSON model has better locality then multi-table schema
    - In JSON, one query is sufficient to fetch
    - In multi-table, need to query multiple tables or make complex join queries

- Normalization in Relational Model/DBs
    - removing duplicate data
    - As a rule of thumb, if you’re duplicating values that could be stored in just one place, the schema is not normalized.

- In Document DBs/Model
    - many-to-one relationship don't fit nicely
        - many people live in one particular region Or
        - many people work in one particular industry
    - joins are not needed for one-to-many tree structure
    - and support for joins is often weak (but RethinkDB and CouchDB supports them to some extend)

- Data has a tendency of becoming more interconnected as features are added to applications.

- In case of many-to-one and many-to-many relationships
    - relational and document databases are not fundamentally different
    - related item is referenced by unique identifier called as
        - foreign key in the relational model
        - document reference in the document model

- Relational Vs Document Databases
    - fault-tolerance properties (Chapter 5)
    - handling of concurrency (Chapter 7)

- Document Databases
    - Advs
        - schema flexibility
        - better locality
        - more closer to applications data structure
        - useful in case of one-to-many relationships or no relationships.
    - Dis-Adv
        - can not refer nested items directly
        - poor support for joins
        - In many-to-many, denormalize helps, but application need to ensure denormalize data remain consistent.
- Relational DBs
    - Advs
        - better support for joins, and many-to-one and many-to-many relationships.
    - Dis-Adv
        - Schema changes need migration and downtime, making it slow to deploy

- For highly interconnected data
    - document model is awkward
    - relational model is acceptable
    - Graph models (see “Graph-Like Data Models”) are the most natural.

- It seems that relational and document databases are becoming more similar over time, and that is a good thing. The data models complement each other

- SQL is declarative query language, whereas IMS and CODASYL queried the database using imperative code

### Graph like data models
- Graph DBs => targeting use cases where anything is potentially related to everything.
- Possible Use Cases
    - Social graphs
        - Vertices are people, and edges indicate which people know each other.
    - The web graph
        - Vertices are web pages, and edges indicate HTML links to other pages.
    - Road or rail networks
        - Vertices are junctions, and edges represent the roads or railway lines between them.

- Diff ways of structuring and querying data in graphs
    - Property graph model
        - implemented by Neo4j, Titan, and InfiniteGraph
    - The triple-store model
        - implemented by Datomic, AllegroGraph, and others

- Declarative query languages for graphs
    - Cypher (Property graph model)
    - SPARQL (triple-store model)
    - Datalog - oldest one
- Imperative query languages for graphs
    - Gremlin
    - Pregel - is a graph processing frameworks

## Chapter 3. Storage and Retrieval
- As a application developer, you need to have a rough idea of what the storage engine is doing under the hood.
- big difference between storage engines optimized for
    - transactional workloads (OLTP)
    - optimized for analytics (OLAP)
- Two families of Storage engine
    - log-structured
        - append only data file
    - page-oriented => B-trees

- To search the same data in several different ways, you may need several different indexes on different parts of the data.
- Add/remove indexes
    - do not affect contents
    - affect performance of queries
    - => affect write throughput
- Adding new index speeds up read queries, but slows down write.

### Hash Indexes
<img src="/resources/images/ddia/Fig-3-1.png" title="Figure 3-1" style="height: 400px; width:800px;"/>
Figure 3-1. Storing a log of key-value pairs in a CSV-like format, indexed with an in-memory hash map.

- Above approach used in Bitcask (the default storage engine in Riak)
- Bitcask offers high-performance reads and writes, subject to the requirement that all the keys fit in the available RAM
    - uses case => value of each key updated frequently

- How to avoid running out of disk space when using single append-only log file
    - on a threshold, break the log into certain size segment file
    - make subsequent writes to a new segment file
    - perform compaction on these segments
    - can also perform merge of segments together along with compaction
    - Segments are never modified after they have been written, so the merged segment is written to a new file.
- Compaction => Throwing away duplicate keys in the log, and keeping only the most recent update for each key.

<img src="/resources/images/ddia/Fig-3-2.png" title="Figure 3-2" style="height: 400px; width:800px;"/>
Figure 3-2. Compaction of a key-value update log (counting the number of times each cat video was played), retaining only the most recent value for each key.


<img src="/resources/images/ddia/Fig-3-3.png" title="Figure 3-3" style="height: 400px; width:800px;"/>
Figure 3-3. Performing compaction and segment merging simultaneously.

- Each segment now has its own in-memory hash table, mapping keys to file offsets.

- Issues to handle with above
    - File format => use binary format instead CSV
    - Deleting records
        - To delete a key, append special deletion record (called as tombstone)
        - During merging, tombstone tells to discard any previous values for the deleted key.
    - Crash recovery
        - On DB restart, in-mem hash map are lost.
        - rebuilding them by reading all segments  may take long time
        - Bitcask speeds up recovery by storing a snapshot of each segment’s hash map on disk, which can be loaded into memory more quickly.
    - Partially written records
        - Bitcask uses checksums to detect and ignored corrupted parts
    - Concurrency control
        - writes should be in append-only strictly sequential order, common choice is to use only one writer
        - as segments are append-only and immutable, read can happen concurrently by multiple threads.
- Why append-only ? Why not update file in place?
    - append-only sequential write operations are much faster than random writes
    - random write causes fragmentation over time
    - Concurrency and crash recovery are much simpler if segment files are append-only or immutable

- Limitations of Hash table index
    - The hash table must fit in memory
    - you could maintain a hash map on disk, but it has performance issues.
        - requires lot of random access
        - expensive to grow when it becomes full
        - hash collisions require fiddly logic
    - Range queries are not efficient
        - It is diff to scan over all keys between kitty00000 and kitty99999
        - Have to lookup each key in hash map

### SSTable and LSM-Trees
- Solution to above limitations with hash map

- Makes two requirements to the format of our segment files
    1. key-value pairs should be sorted by key
        - called this format as Sorted String Table (SSTable)
    2. Each key only appears once withing merged segment file
        - compaction process ensures this
<img src="/resources/images/ddia/Fig-3-4.png" title="Figure 3-4" style="height: 400px; width:800px;"/>
Figure 3-4. Merging several SSTable segments, retaining only the most recent value for each key.


- SSTables have several big advantages over log segments with hash indexes
    - Merging segments is simple and efficient, even if the files are bigger than the available memory. Bec segments contains keys in sorted order already
    - When multiple segments contain the same key, we can keep the value from the most recent segment and discard the values in older segments.
    - No need to keep an index for all keys in the memory
    - You still need an in-memory index to tell you the offsets for some of the keys, but it can be sparse
    - range queries are possible
    - compression reduces disk space + reduces I/O b/w use.

<img src="/resources/images/ddia/Fig-3-5.png" title="Figure 3-5" style="height: 400px; width:800px;"/>
Figure 3-5. An SSTable with an in-memory index.


- How do you get your data to be sorted by key in the first place?
    - When a write comes in, add it to an in-memory balanced tree data structure (AVL or red-black trees)
        - in-memory tree called as memtable
    - On threshold, write memtable into SSTable
    - While the SSTable is being written out to disk, writes can continue to a new memtable instance.
    - To serve read request, first find in memtable. Then in most recent on-disk segment, then in the next-older segment, etc.
    - Run merging and compaction periodically to combine segments, and discard overwritten or deleted values.
- How to handle server crashes
    - keep separate append-only log on disk where every write is immediately appended
    - It's purpose is to restore memtable after crash
    - On memtable written out to an SSTable, discard the corresponding log

### LSM-Tree (Log Structured Merged Tree)
- LevelDB and RocksDB uses above Storage engine algo
- LevelDB can be used in Riak as an alternative to Bitcask (Storage Engine).
- Similar Storage engine algo used in Cassandra and HBase DBs

- Originally above indexing structure was described by Patrick O’Neil et al. under the name Log-Structured Merge-Tree (or LSM-Tree)
 - Storage engines that are based on this principle of merging and compacting sorted files are often called LSM storage engines.
- Lucene, an indexing engine for full-text search used by Elasticsearch and Solr, uses a similar method for storing its term dictionary
- A full-text index is much more complex than a key-value index but is based on a similar idea.

### Performance Optimization
- LSM alog can be slow when searching non existing keys.
- Solution - Bloom filters
    - memory-efficient data structure
    - approximates the contents of a set
    - can tell if a key does not appear in DB
    - saves many unnecessary disk reads for nonexistent keys.

- Diff strategies to determine the order and timing of how SSTables are compacted and merged.
    - size-tiered compaction
        - used by Cassandra
    - leveled compaction
        - used by LevelDB, RocksDB, Cassandra

- Because the disk writes are sequential, the LSM-tree can support remarkably high write throughput.

### B-Trees
- is a standard index implementation used by almost all Relational DBs

- B-tree Storage mechanism
    - B-trees break the DB down into fixed-size blocks or pages
    - Generally, page size is 4 KB (sometimes bigger)
    - read or write one page at a time
    - This design corresponds more closely to the underlying hardware, as disks are also arranged in fixed-size blocks.

<img src="/resources/images/ddia/Fig-3-6.png" title="Figure 3-6" style="height: 400px; width:800px;"/>
Figure 3-6. Looking up a key using a B-tree index.


- leaf page
    - either contains the value for each key inline Or
    - contains references to the pages where the values can be found.
- branching factor
    - The number of references to child pages in one page of the B-tree

- To updating a Key
    - find a page containing key
    - update the value and write complete page back to disk
        - **This is major diff Vs LSM-Trees**
    - any references to that page remain valid
- To add new key
    - first find the page whose range encompasses the new key
    - then add the key
    - If page is full
        - split page into two half-full pages
        - update parent page to account for the new subdivision of key ranges

<img src="/resources/images/ddia/Fig-3-7.png" title="Figure 3-7" style="height: 400px; width:800px;"/>
Figure 3-7. Growing a B-tree by splitting a page.


- Above algo ensures tree remains balanced
- B-tree with n keys always has a depth of O(log n).
- A four-level tree of 4 KB pages with a branching factor of 500 can store up to 250 TB

- How to handle DB Crashes
    - crash when updating parent page may end up DB in corrupted state
        - orphan pages that won't have parent page
    - Solution - write-ahead log (WAL) or redo log
        - Append only file
        - any modification first need to append in log file
        - used while recovering indexes after crash

- Concurrency Control
    - updating pages in place requires careful Concurrency Control
    - o/w a thread may see tree in inconsistent state
    - Solution
        - protect tree data structure using latches (lightweight locks)
    - Log-structured/LSM-Tree approach are simpler in this regard, because they do all the merging in the background without interfering with incoming queries and atomically swap old segments for new segments from time to time.

#### B-Tree Optimizations
- Many optimizations have been developed over the years.
- Instead of overwriting pages and maintaining a WAL for crash recovery, some databases (like LMDB) use a copy-on-write scheme
    - A modified page is written to a different location
    - New version of the parent pages in the tree is created, pointing at the new location
    - See “Snapshot Isolation and Repeatable Read” p237
- save space in pages by not storing entire key, but abbreviating it
    - Especially in pages on the interior of the tree
    - keys only need to provide boundaries between key ranges
    - This allows packing more keys into a page
        - means higher branching factor
        - thus fewer levels
        - used in B+ trees
- lay out the tree such that leaf pages appear in sequential order on disk.
    - But diff to maintain this as tree grows
    - This is little easy to do in LSM-Trees
    - As LSM-trees rewrite large segments of the storage in one go during merging, it’s easier for them to keep sequential keys close to each other on disk
- Each leaf page may have references to its sibling pages to the left and right,
    - allows scanning keys in order without jumping back to parent pages.
- B-tree variants such as fractal trees [22] borrow some log-structured ideas to reduce disk seeks

### B-Trees Vs LSM-Trees
- LSM-Trees
    - faster for writes
    - reads are slow bec
        - need to check diff memtable/SSTables at different stages of compaction.
- B-Trees
    - faster for reads

- **However**, *benchmarks are often inconclusive and sensitive to details of the workload. You need to test systems with your particular workload in order to make a valid comparison*


- Things to consider when measuring the performance of a storage engine.

- Both types suffers from write amplification
    - one write to the DB results in multiple writes to the disk over the course of the database’s lifetime
    - B-tree
        - writes every piece of data at least twice
            1. in WAL
            2. in tree page itself
        - writes entire page even if few bytes in the page are modified
        - Some storage engines even overwrite the same page twice in order to avoid ending up with a partially updated page in the event of a power failure
    - LSM-Trees
        - rewrite data multiple times due to repeated compaction and merging of SSTables

- write amplification is of concern with SSDs
    - bec SSDs can only overwrite blocks a limited number of times before wearing out.

- LSM-Trees
    - Adv
        - have lower write amplification => higher write throughput than B-trees
        - can be compressed better, and thus often produce smaller files on disk than B-trees.
        - have lower storage overheads bec
            - they are not page oriented
            - remove fragmentation by rewrite SSTables
    - DisAdv
        - compaction process can sometimes interfere with the performance of ongoing reads and writes
        - at higher percentiles, response time of queries to log-structured storage engines can sometimes be quite high, and B-trees can be more predictable
        - Disk’s finite write b/w needs to be shared between the initial write (logging and flushing a memtable to disk) and the compaction threads running in the background.
        - Bigger the DB, more disk b/w required for compaction
        - It may happen compaction may not keep up with rate of incoming writes. So unmerged segments on disk keeps growing until disk full.
            - reads slows down as well bec it need to search more segments
        - Generally STable-based storage engines do not throttle the rate of incoming writes, even if compaction cannot keep up
            - So you need to monitor to detect this situation
- B-Trees
    - Adv
        - key is located at exactly one place. In Log-structured engine, key may have multiple copies in diff segments
        - This makes B-Trees more attractive in DBs that want to offer strong transactional semantics

- There is no quick and easy rule for determining which type of storage engine is better for your use case, so it is worth testing empirically

### Other indexing structure
- It is also very common to have secondary indexes.
- In relational databases, you can create several secondary indexes on the same table using the CREATE INDEX command.
- secondary indexes helps to perform joins effectively.
- In secondary indexes, indexed values are not necessarily unique. This can be solved in two ways
    1. making each value in the index a list of matching row identifiers
    2. by making each entry unique by appending a row identifier to it
- Either way, both B-trees and log-structured indexes can be used as secondary indexes.

### Storing values with indexes
- heap file
    - the place where rows are stored in DB
    - stores data in no particular order
    - The heap file approach is common because it avoids duplicating data when multiple secondary indexes are present: each index just references a location in the heap file, and the actual data is kept in one place.

- Sometimes extra hop from index to heap file can reduce performance
- So it can be desirable to store the indexed row directly within an index.
    - aka clustered index
- In MySQL’s InnoDB storage engine
    - primary key of a table is always a clustered index
    - secondary indexes refer to the primary key (rather than a heap file location)
- Covering index
    - compromise bet heap approach (storing only references to the data within the index) and clustered index
    - stores some of a table’s columns within the index
    - This allows some queries to index alone

- Covering and clustered indexes speed up reads but
    - they require additional storage
    - can add overhead on writes
    - bec some data is duplicated
    - DB need to do additional efforts to enforce transactional guarantees bec applications should not see inconsistencies due to the duplication.

### Multi-column indexes
- The indexes discussed so far only map a single key to a value.
- That is not sufficient if we need to query multiple columns of a table (or multiple fields in a document) simultaneously.
- most common type of multi-column index is called a concatenated index
    - combines several fields into one key by appending one column to another
    - This like old fashioned paper phone book which provides index as (lastname, firstname)
    - So useful to search people with lastname-firstname combination
    - However index can not be used to find people with firstname only

### Transaction Processing or Analytics?
- OLAP and OLTP have very different access patterns
- The difference between OLTP and OLAP is not always clear-cut, but some typical characteristics are listed below

| Property | Transaction processing systems (OLTP) | Analytic systems (OLAP)|
| ---------|---------------------------------------|------------------------|
|Main read pattern|Small number of records per query, fetched by key|Aggregate over large number of records|
|Main write pattern|Random-access, low-latency writes from user input|Bulk import (ETL) or event stream|
|Primarily used by|End user/customer, via web application|Internal analyst, for decision support|
|What data represents|Latest state of data (current point in time)|History of events that happened over time|
|Dataset size|Gigabytes to terabytes|Terabytes to petabytes|

- OLAP DBs are called data warehouse
- OLTP systems expected to
    - be highly available
    - process transactions with low latency
    - bec they are critical to business operations
- DB Admins are reluctant to run analytics queries bec
    - those queries are often expensive
    - scanning large parts of the dataset
    - can harm performance of concurrently executing transactions.

<img src="/resources/images/ddia/Fig-3-8.png" title="Figure 3-8" style="height: 400px; width:800px;"/>
Figure 3-8. Simplified outline of ETL into a data warehouse.


- Indexing algorithms discussed earlier work well for OLTP systems but not for OLAP systems

#### Indexing for OLAP systems

- OLAP DBs are generally Relation, bec SQL is good fit for analytics queries
- They helps analyst to explore data through operations such as drill-down and slicing and dicing
- Many database vendors now focus on supporting either transaction processing or analytics workloads, but not both
- Data warehouse commercial vendors
    - Teradata
    - Vertica
    - SAP HANA
    - ParAccel
    - Amazon RedShift => hosted version of ParAccel
- Data warehouse Open source SQL-on-Hadoop projects
    - Apache Hive, Spark SQL, Cloudera Impala, Facebook Presto, Apache Tajo, and Apache Drill
    - Some of above based on ideas from Google’s Dremel

#### Stars and Snowflakes: Schemas for Analytics
- most common schema => star schema aka dimensional modeling
    - At the center of the schema is a so-called fact table
    - Each row of the fact table represents an event that occurred at a particular time

<img src="/resources/images/ddia/Fig-3-9.png" title="Figure 3-9" style="height: 400px; width:800px;"/>
Figure 3-9. Example of a star schema for use in a data warehouse.


- Usually, facts are captured as individual events, because this allows maximum flexibility of analysis later.
- Some of the cols in fact tables are attributes. Helps to calculate profit margins for example.
- Other columns in the fact table are foreign key references to other tables, called dimension tables
- As each row in the fact table represents an event, the dimensions represent the who, what, where, when, how, and why of the event.
- Notice, date and time are often represented using dimension tables, because this allows additional information about dates (such as public holidays) to be encoded, allowing queries to differentiate between sales on holidays and non-holidays.
- snowflake schema
    - variation of star schema
    - dimensions are further broken down into subdimensions
    - more normalized than star schemas
- star schemas are often preferred because they are simpler for analysts to work with
- In a typical data warehouse, tables are often very wide: fact tables often have over 100 columns, sometimes several hundred
- Dimension tables can also be very wide

#### Column-Oriented Storage
- Although fact tables are often over 100 columns wide, a typical data warehouse query only accesses 4 or 5 of them at one time
- But row-oriented storage engine still needs to load all of those rows (each consisting of over 100 attributes) from disk into memory, parse them, and filter out those that don’t meet the required conditions. That can take a long time.
- The idea behind column-oriented storage is simple:
    - don’t store all the values from one row together
    - but store all the values from each column together instead

- Column storage is easiest to understand in a relational data model, but it applies equally to nonrelational data
    - Parquet is a columnar storage format that supports a document data model, based on Google’s Dremel

<img src="/resources/images/ddia/Fig-3-10.png" title="Figure 3-10" style="height: 400px; width:800px;"/>
Figure 3-10. Storing relational data by column, rather than by row.


- The column-oriented storage layout relies on each column file containing the rows in the same order
- Thus, if you need to reassemble an entire row, you can take the 23rd entry from each of the individual column files and put them together to form the 23rd row of the table.

#### Column Compression
- column-oriented storage often lends itself very well to compression.
- Check values for each column in Figure 3-10. They often look quite repetitive, 
which is a good sign for compression.
- Diff compression techniques can be used depending on data
    - bitmap encoding

#### Summary
- Storage engines fall into two broad categories
    - optimized for OLTP
    - optimized for OLAP
- OLTP System
    - used by end users
    - applications usually only touch a small number of records in each query
    - applications asks for data using key, storage engine uses an index to find key-value
    - Disk seek time is often the bottleneck here.
- OLAP System
    - used by business analysts
    - handle a much lower volume of queries than OLTP
    - but each query is more demanding, requires millions records to scan in short time
    - Disk bandwidth (not seek time) is often the bottleneck here
    - column-oriented storage is an increasingly popular solution for this kind of workload.

- OLTP side, storage engines from two main schools of thought
    1. The log-structured.
        - Bitcask, SSTables, LSM-trees, LevelDB, Cassandra, HBase, Lucene, and others belong to this group
    2. update-in-place school
        - treats the disk as a set of fixed-size pages that can be overwritten
        - B-trees used by almost all relation DBs

- Log-structured storage engine's key idea
    - they systematically turn random-access writes into sequential writes on disk,
    - which enables higher write throughput due to the performance characteristics of hard drives and SSDs.

- In OLAP, access pattern is diff than OLTP
    - queries require sequentially scanning across a large number of rows
    - This makes indexes less relevant.
    - Instead it becomes important to encode data very compactly.
    - This minimize the amount of data that the query needs to read from disk.
    - column-oriented storage helps achieve this goal

## Chapter 4. Encoding and Evolution
- In most cases, a change to an application’s features => change to data that it stores
- Relation DBs
    - exactly one schema exists
- Document DBs (schema-on-read / schemaless) DBs
    - don't enforce schema
    - DBs contains data with old and new schema at the same time
- Backward compatibility
    - Newer code can read data that was written by older code.
    - Not hard to achieve
- Forward compatibility
    - Older code can read data that was written by newer code.
    - bit tricky 

- Encoding/Marshalling/Serialization
    - In memory to Byte Stream
- Decoding/Un-marshalling/De-serialization
    - Byte Stream to memory

- Many programming languages comes with in-built support for Encoding and Decoding
    - Java 
        - Native - java.io.Serializable
        - Third-Party - Kyro
    - Ruby => Marshal
    - Python => pickle
    - Such languages have few problems
        - reading the data in another language is very difficult
        - decoding process need to instantiate arbitrary classes
            - security risk
            - remotely executing arbitrary code
        - Versioning data is often an afterthought in these libraries
        - Efficiency issues
            - Java’s built-in serialization is notorious for its bad performance and bloated encoding

- JSON, XML, CVS and popular encoding format, but they have few issues
    - JSON distinguishes strings and numbers, 
    - but it doesn’t distinguish integers and floating-point numbers, and it doesn’t specify a precision
    - Twitter used 64-bit number to identify each tweet
        - numbers > 2^53 cannot be exactly represented in an IEEE 754 double-precision floating-point number
        - So these numbers are incorrectly parsed in languages which uses IEEE 754 (JavaScript)
        - Workaround Solution
            - Twitter puts Tweet id twice.
            - once as a JSON number and once as a decimal string
    - JSON and XML have good support for Unicode character strings (i.e., human-readable text),
    but they don’t support binary strings (seq of bytes w/o char encoding)
        - One solution => Encode in Base64
        - But it increases the data size by 33%.
    - Optional schema supported by JSON/XML is quite complex to learn

- Despite above limitations, JSON, XML, CVS are used especially as data interchange formats
    - i.e., for sending data from one organization to another
    - as long as people agree on what the format is, it often doesn’t matter 
    how pretty or efficient the format is. 

### Binary Encoding
- mainly used internally within your organization.
- more compact and faster to parse
- for a large dataset in terabytes, choice of data format can have a big impact
- MessagePack is binary encoding format for JSON
    - but this does not provide sizable space reduction


### Thrift and Protocol Buffers
- Both libraries require schema
- Let's take a record to be encoded
    ```json
    {
        "userName": "Martin",
        "favoriteNumber": 1337,
        "interests": ["daydreaming", "hacking"]
    }
    ```
- Protocol Buffers
    - developed at Google
    - schema for above record looks like
        ```
        message Person {
        required string user_name       = 1;
        optional int64  favorite_number = 2;
        repeated string interests       = 3;
        }
        ```
- Thrift
    - developed at meta/facebook
    - schema language => Thrift interface definition language (IDL)
    - IDL for above record looks like
        ```
        struct Person {
        1: required string       userName,
        2: optional i64          favoriteNumber,
        3: optional list<string> interests
        }
        ```
    - has two binary encoding format
        - BinaryProtocol
        - CompactProtocol
        - DenseProtocol
            - supported in C++ only
            - So not counted as cross-language

- Both come with a code generation tool
    - takes a schema definition and produces classes that implement the schema
        - useful in statically typed languages (C++, Java, golang)
        - allows efficient in memory structure
        - But not so useful in dynamically typed languages (Python, Ruby)
            - there is no compilation step
    - supports in various programming languages 

It is reasonable to assume that all the servers will be updated first, and all the clients second.
    - Thus, you only need backward compatibility on requests
    - and forward compatibility on responses.


### ApacheAvro
- another binary encoding format
- started in 2009 as a subproject of Hadoop
    - as result of Thrift not being a good fit for Hadoop’s use cases
- has two schema languages
    - Avro IDL
        - intended for human editing
    - based on JSON 
        - more easily machine-readable
- This is more compact than Thrift or Protocol Buffers
- Avro supports schema evolution by having 
    - Writers schema
        - used by application wants to encode some data (write to file or send over n/w)
    - Readers schema
        - to decode the encoded data

- The key idea with Avro => writer’s and reader’s schema don’t have to be the same



# Part II:  
## Distributed Data

Why to distribute a DB?
- Scalability
    - if data volume, read load or write load grows.
- Fault tolerance / High Availability 
    - Application on m/c fails r n/w went down or entire DC goes down
- Latency
    - Keep the DB closer to user location for min latency

### Scaling to High Load
- Vertical Scaling / Scaling Up
    - Add more CPUs, RAM, Storage
    - aka shared-memory architecture
    - DisAdv
        - Cost grows faster than linearly
        - m/c twice the size may not necessarily handle high load
        - limited fault tolerance
        - limited single geo location
- Horizontal Scaling / / Scaling Out
    - aka shared-nothing architecture
    - Adv
        - No special h/w required

## Chapter 5. Replication
Why replicate data?
- keep data closer to user geographically => reduce latency
- allow system to work even if some of its parts fail => high availability
- helps to scale out => handle more load (read/write queries or more data volume)

In this Chapter, will assume our dataset is small enough to accommodate in single machine.
In Chapter 6, we will relax this assumption and discuss partitioning/sharding

Three Popular Replication Alogs
- Single-leader aka
    - leader based replication
    - master-slave
    - active/passive (hot standby)
- Multi-leader
- leaderless

Many trade-offs to consider in Replication
- sync Vs async replicate
- handle failed replica

### Leaders and Followers (Single-leader Replication)

<img src="/resources/images/ddia/Fig-5-1.png" title="Figure 5-1" style="height: 400px; width:800px;"/>
Figure 5-1. Leader-based (master–slave) replication.

- Leader sends data change to all of it's followers as part of replication log or change stream
- Followers applies all write in the same order
- clients can query either leader or follower, but writes are only accepted on leader
- This mode of replication is built in most relational DBs
    - PostgreSQL - (since version 9.0)
    - MySQL
    - Oracle Data Guard
    - SQL Server's AlwaysOn Availability Group
- Also used in some NoSQL DBs too
    - MongoDB, RethinkDB, Espresso
- Distributed Message brokers used this well
    - Kafka
    - RabbitMQ

#### Sync Vs Async Replication

<img src="/resources/images/ddia/Fig-5-2.png" title="Figure 5-2" style="height: 400px; width:800px;"/>
Figure 5-2. Leader-based replication with one synchronous and one asynchronous follower.

- replication to follower 1 is synchronous 
- replication to follower 2 is asynchronous
- Often configurable option in DBs
- Normally replication is quite fast, but it may lag behind in case
    - follower recovering from failure
    - system operating near maximum capacity
    - n/w problems bet nodes

- Adv of Sync Replication
    - follower is guaranteed to have up-to-date copy
- DisAdv of Sync Replication    
    - If follower doesn't respond then all writes are blocked till that time
    - So it is impractical for all follower to be synchronous
    - Sol => semi-synchronous
        - at least one follower to be synchronous
- Leader based replication can be configured to be completely async
    - Adv
        - leader can accept writes even if all followers have fallen behind
        - increase availability
    - DisAdv
        - weakening durability 

#### Setting up New Followers
Why?
- handle high read traffic => scaling out
- replace failed replica

Setting up follower is done w/o downtime
- Take a consistent snapshot of the leader’s database at some point in time
    - Most DB supports this
    - Required for backup
    - third-party tools (innobackupex for MySQL) are used as well
- Copy snapshot to follower
- Follower connects to leader and asks for all changes post snapshot
    - This requires snapshot to point exact position in replication log
    - This position has various names
        - PostgreSQL => log sequence number
        - MySQL => binlog coordinates
- Once follower catches up with Leader, it can start processing reads

#### Handling Node Outages
How to achieve high availability with leader-based replication?

- Follower failure: Catch-up recovery
    - follower keeps a log of the data changes it has received from the leader
    - post crash recovery, follower can recover easily from it's log

- Leader failure: Failover
    - Trickier handling
        - one of the follower to be promoted as leader 
        - clients to route all write requests to new leader
        - other followers to start following new leader => consuming data from this new leader

- Automatic leader failover process
    - Determining that the leader has failed
        - multiple reasons
            - crashes, power outages, n/w issues
        - so most systems simply use a timeout
    - Choosing a new leader
        - through an election process
        - best candidate is replica with most up-to-date data changes
        - This is consensus problem => Discussed in Chapter 9
    - Reconfiguring the system to use the new leader
        - clients to send write requests to new leader
        - System to ensure old leader to become follower (if it comes back) and recognizes the new leader.

- Issues in Leader Failover
    - In async replication, new leader may not have received all writes
    - What happens to those writes if old leader comes back
    - Common Sol - old leader's write to be discarded => may violates durability
    - Discarding writes is dangerous if other storage systems outside DBs need to be 
     coordinated with the database contents
        - e.g. in once GitHub incident, 
        - an out of date MySQL follower was promoted to leader
        - DB was using auto incrementing counter to assign primary keys
        - but leader’s counter lagged behind the old leader’s,
        it reused some primary keys that were previously assigned by the old leader. 
        - These primary keys were also used in a Redis store
        - This introduces inconsistency bet MySQL and Redis
        - Causes some private data to be disclosed to the wrong users
    - Split brain situation can occur. Two nodes believe they are leader
        - data may be lost or corrupted
    - Right timeout before leader declared dead?
        - longer timeout => longer time to recovery
        - short timeout => leads to unnecessary failover. 
            - If system already structuring with high load or network problems, 
            an unnecessary failover makes situation worse, not better.

- There are no easy solutions to above issues
- So some ops teams prefer to perform failover manually even if s/w supports automatic failover

- These issues—node failures; unreliable networks; and trade-offs around replica consistency,
durability, availability, and latency—are in fact fundamental problems in distributed systems. In
Chapter 8 and Chapter 9 we will discuss them in greater depth.

#### Implementation of Replication Logs
- Statement-based replication
    - used in MySQL before version 5.1.
    - leaders sends every write SQL request to follower
    - follower parses and execute that SQL request
    - DisAdv
        - If SQL query uses nondeterministic function (NOW() or RAND()), 
        it is likely to generate different values in replicas
        - If autoincrementing used or it depends on existing data (UPDATE … WHERE <some condition>)
        they must execute in exactly same order
        - Statements that have side effects (triggers, stored procedures, user-defined functions)
        may result diff values in diff replicas
    - Work around possible, but since there are many edge cases, 
    other replication methods are preferred.
    - VoltDB uses statement-based replication, and makes it safe by requiring transactions to be deterministic

- Write-ahead log (WAL) shipping
    - WAL used in both  log-structured and B-tree storage engines for crash recovery purpose
    - Same can be send to follower
    - used in PostgreSQL and Oracle
    - DisAdv
        - log describes the data on a very low level
        - This makes replication closely coupled to the storage engine
        - So if DB changes it's storage format, this could not be used
        - Also, leader and follower can not use diff storage formats at the same time
        - This has operational impact

- Logical (row-based) log replication
    - uses diff log formats for WAL and storage engine => decoupling
    - aka logical log
    - Relational DBs
        - logical log means sequence of records describing writes to DB 
        tables at the granularity of a row
        - MySQL uses this approach, called as binlog 
    - Adv
        - decoupling helps to ensure backward compatibility
        - easier for external applications to parse
            - e.g. DB warehouse for offline analysis
            - building custom indexes and caches
        - This technique is called as change data capture (CDC)

- Trigger-based replication
    - performed by application code and not by DB
    - can be achieved using triggers and stored procedures in relational DBs
    - used if requires some flexibility
        - e.g want to replicate only subset of DB
    - Oracle GoldenGate can make CDC changes available to application
    - DisAdv
        - greater overheads than other replication methods
        - more prone to bugs

#### Problems with Replication Lag
- In Leader-based replication
    - all writes go through leader
    - all reads go through any replicas
- This is an attractive option for workloads requiring many reads and 
small % of writes (a common pattern on the web)
    - aka read-scaling architecture
    - can serve more reads by adding more nodes 
- But client can see old data if reading from follower which is not up-to-date w/ leader
- This section highlights issues w/ replication lag and some sol to solve them

##### Reading Your Own Writes

<img src="/resources/images/ddia/Fig-5-3.png" title="Figure 5-3" style="height: 400px; width:800px;"/>
Figure 5-3. A user makes a write, followed by a read from a stale replica. To prevent this anomaly, we need
read-after-write consistency.

- User can not see it's own write made just a movement before
- So we need read-after-write consistency Or read-your-write consistency guarantee
- This is a guarantee that if the user reloads the page, 
they will always see any updates they submitted themselves.
- It makes no promises about other users 

- How to implement read-after-write consistency
    - When reading something that the user may have modified, read it from 
    the leader; otherwise, read it from a follower.
    - e.g. user profile on social n/w
        - always read from leader bec generally owner only modifies it
    - Do not read from followers having large replication lag (say > 1 min)
    - If replicas are in multiple DCs, there is additional complexity
    - Another complication 
        - if user accessing service from diff devices
        - additionally if those devices are on diff n/ws (desktop and mobile)
        - so need to support cross-device read-after-write consistency
        - So need to route all read requests from same user to same leader


##### Monotonic Reads
<img src="/resources/images/ddia/Fig-5-4.png" title="Figure 5-4" style="height: 400px; width:800px;"/>
Figure 5-4. A user first reads from a fresh replica, then from a stale replica. Time appears to go backward. To prevent this
anomaly, we need monotonic reads.

- means users see things moving backward in time.
- Above, user 2345 sees user 1234's comment, but does not see it again second time
- Sols
    - each user reads is served from same replica
    - replica can be selected using hash of used id rather randomly

##### Consistent Prefix Reads
<img src="/resources/images/ddia/Fig-5-5.png" title="Figure 5-5" style="height: 400px; width:800px;"/>
Figure 5-5. If some partitions are replicated slower than others, an observer may see the answer before they see the
question.


- Concerns violation of causality (the relationship between cause and effect)
- There is a causal dependency between those two sentences: Mrs. Cake heard Mr. Poons’s question
and answered it.
- Observer sees Mrs Cakes answer first
- So guarantee requires => if a sequence of writes happens in a certain order, 
then anyone reading those writes will see them appear in the same order.
- Will discuss this in “The “happens-before” relationship and concurrency” section

#### Solutions for Replication Lag
- There are ways an application can provide a stronger guarantee than the 
underlying database
    - e.g. by performing certain kinds of reads on the leader.
- However, dealing with these issues in application code is complex and easy to get wrong.
- It would be better to keep application away from handling such issues
- This is why transactions exist
    - They are the DB way of providing stronger guarantees
    - Makes application simpler

- Many systems claim transactions are too expensive in terms of performance 
and availability for distributed DBs
- And eventual consistency is inevitable in a scalable system
- This is somewhat true, but it is overly simplistic
- We will return to this in Chapters 7 and 9 and then in Part III

### Multi-Leader Replication
- Natural extension of leader-based replication model 
- Allow more than once node to accept writes
- aka master-master or active/active replication
- each leader simultaneously acts as a follower to the other leaders.

#### Use Cases for Multi-Leader Replication
<img src="/resources/images/ddia/Fig-5-6.png" title="Figure 5-6" style="height: 400px; width:800px;"/>
Figure 5-6. Multi-leader replication across multiple datacenters.

- Multi-datacenter operation
    - In leader-based replication, all writes must go through DC hosting leader
    - In multi DC, each DC hosts one leader
- Compare single-leader and multi-leader configs in a multi DC deployment
    - Performance
        - single-leader => since write go through DC hosting leader, users located far from 
        that DC may observer higher latency
        - multi-leader => less latency as leader is available in each DC to accept write requests
    - Tolerance of datacenter outages
        - single-leader => If DC hosting leader fails, failover to follower i another DC
        - multi-leader => DC can operate independently than other DC
    - Tolerance of network problems
        - multi-leader => with asynchronous replication can usually tolerate network problems better
- Some DBs support multi-leader configurations by default
- Some are implemented with external tools
    - Tungsten Replicator for MySQL
    - BDR for PostgreSQL
    - GoldenGate for Oracle

- Big downside of multi-leader configs
    - same data same data may be concurrently modified in two different datacenters
    - Those write conflicts must be resolved.
    - Also, has subtle configuration pitfalls
        - autoincrementing keys, triggers, and integrity constraints can be problematic

##### Clients with offline operation
- e.g. calender apps on your mobile
- allows to create meetings even if there is no n/w connectivity
- Every device has local DB that acts as a leader 

##### Collaborative editing
- e.g. Etherpad and Google Docs allow multiple people to concurrently edit a text 
document or spreadsheet. (“Automatic Conflict Resolution” algo briefly discussed this)

#### Handling Write Conflicts
<img src="/resources/images/ddia/Fig-5-7.png" title="Figure 5-7" style="height: 400px; width:800px;"/>
Figure 5-7. A write conflict caused by two leaders concurrently updating the same record.

- Above problem does not occur in a single-leader database.

##### Synchronous versus asynchronous conflict detection
- In single-leader, only single write wins at a time
- In multi-leader, both/all writes win and conflict observed at later some point of time

- Solutions 
    - Conflict avoidance
    - Converging toward a consistent state
        - every replication system must ensure that the data is eventually the same in all replicas.
        - DBs must resolve the conflict in a convergent way
        - means all replicas must arrive at the same final value when all 
        changes have been replicated
        - Various ways to achieve this
            - Give each write unique ID
            - winner => writer with highest ID
            - If timestamp used as ID then this is called LWW (Last Write Wins) 
            - LWW is popular, but it is dangerously prone to data loss
            - For other ways, see p173
    - Custom conflict resolution logic
        - most multi-leader replication tools let you write conflict resolution 
        logic using application code
        - This code may be executed on write or on read
        - On write
            - DB calls this code as soon as it detects conflict
            - The code typically cannot prompt a user and must runs in 
            background process and execute quickly
        - On read
            - all the conflicting writes are stored
            - On read, these multiple versions of data is returned to application to resolve
            - Application prompt user or amy resolve conflict automatically
            - CouchDB works this way
        - Note that conflict resolution usually applies at the level of an 
        individual row or document, not for an entire transaction. 
        Thus, if you have a transaction that atomically makes several different
        writes (see Chapter 7), each write is still considered separately 
        for the purposes of conflict resolution.

##### What is a conflict?
- Some conflicts are easier to detect (Figure 5-7)
- But other kinds of conflict can be more subtle to detect.
- There isn’t a quick ready-made answer, but in the following chapters 
we will trace a path toward a good understanding of this problem. 
We will see some more examples of conflicts in Chapter 7, and in Chapter 12 
we will discuss scalable approaches for detecting and resolving conflicts in 
a replicated system.

#### Multi-Leader Replication Topologies
- A replication topology describes path => how writes are propagated from one node to another
- If there are only two leaders (Figure 5-7), one one possible topology exists
- If more than two leaders, diff topologies exists

<img src="/resources/images/ddia/Fig-5-8.png" title="Figure 5-8" style="height: 400px; width:800px;"/>
Figure 5-8. Three example topologies in which multi-leader replication can be set up

- The most general topology is all-to-all
    - every leader sends writes to every other leader
- MySQL by default supports only a circular topology
- To prevent infinite replication loops in circular and star topologies
    - each node is given a unique identifier,
    - In the replication log, each write is tagged with the identifiers of 
    all the nodes it has passed through
    - Node ignores the changes with it's own ID

- all-to-all topology Vs circular & star topologies
    - if one node/link fails in circular & star topologies then it stops the replication until node is recovered
    - In all-to-all, there are multiple paths of replication, so it can tolerate few nodes/links failures

- But all-to-all topologies can have issues too

<img src="/resources/images/ddia/Fig-5-9.png" title="Figure 5-9" style="height: 400px; width:800px;"/>
Figure 5-9. With multi-leader replication, writes may arrive in the wrong order at some replicas


- Above is problem of causality similar to what we see in “Consistent Prefix Reads”
- Simply attaching a timestamp to every write is not sufficient, because 
clocks cannot be trusted to be sufficiently in sync to correctly order these 
events at leader 2 (see Chapter 8).
- To order these events correctly, a technique called version vectors can be used
- Discussed in “Detecting Concurrent Writes” section
- However, conflict detection techniques are poorly implemented in many 
multi-leader replication systems.

- If you are using a system with multi-leader replication, it is worth being 
aware of these issues, carefully reading the documentation, and thoroughly 
testing your database to ensure that it really does provide the guarantees you 
believe it to have.

### Leaderless Replication
- allows any replica to accept write
- Amazon uses this in it's in-house Dynamo system
    - Dynamo is not available outside Amazon
    - DynamoDB is Amazon's hosted DB product
    - DynamoDB uses completely diff architecture than Dynamo
    - DynamoDB uses single-leader replication
- Riak, Cassandra, and Voldemort uses this replication inspired by Dynamo
- So such DBs are also called as Dynamo-style DBs

- Writing mechanism
    - client directly sends its writes to several replicas, Or 
    - a coordinator node does this on behalf of the client. Coordinator does 
    not enforce a particular ordering of writes.

#### Writing to the Database When a Node Is Down
- In leader based replication, system need to perform failover
- In Leaderless Replication, failover does not exists
    - quorum write and quorum read is used
    - conflicts resolved on reading with versioning support

<img src="/resources/images/ddia/Fig-5-10.png" title="Figure 5-10" style="height: 400px; width:800px;"/>
Figure 5-10. A quorum write, quorum read, and read repair after a node outage


##### Read repair and anti-entropy
- entropy => measures of randomness or disorder of a system
- replication should ensure that eventually all the data is copied to every replica.
- How a node catches up with writes once he come back from crash or n/w outage
    - Read Repair
        - Per Figure 5-10, client sees that replica 3 has a stale value and 
        writes the newer value back to that replica. 
        - This works well for values that are frequently read.
        - Means Read Repairs are performed only when values are read by application
    - Anti-entropy process
        - A background process that constantly looks for differences
        - Unlike the replication log in leader-based replication, 
        anti-entropy process does not copy writes in any particular order
        - And there may be a significant delay before data is copied.
    - Not all systems implement both
        - Voldemort currently does not have an anti-entropy process.
    - Note => w/o anti-entropy process, values that are rarely read may be missing 
    from some replicas => reduced durability

##### Quorums for reading and writing
- n => number of replicas
- w => nodes confirming writes
- n => nodes confirming reads
- Configs with which reads are up-to-date
    - w + r > n
- Reads and writes that obey these r and w values are called quorum reads and write
- One can adjust n,w,n as per use case
- workload w/ few writes and many reads
    - w = n and r = 1
        - makes reads faster
        - but one node fail will cause all writes t fail

- With w + r > n tolerates unavailable nodes as follows

<img src="/resources/images/ddia/Fig-5-11.png" title="Figure 5-11" style="height: 400px; width:800px;"/>
Figure 5-11. If w + r > n, at least one of the r replicas you read from must have seen the most recent successful write.

##### Limitations of Quorum Consistency
- w + r > n => tolerates up to n/2 node failures
- You may also set w and r to smaller numbers => w + r ≤ n
    - quorum condition is not satisfied
    - reads and writes will still be sent to n nodes, but a smaller number of 
    successful responses is required for the operation to succeed.
    - allows lower latency and higher availability

- Although quorums appear to guarantee that a read returns the latest written 
value, in practice it is not so simple
- Dynamo-style DBs are generally optimized for use cases that can tolerate 
eventual consistency. 
- w and r allow you to adjust the probability of stale values being read, 
but it’s wise to not take them as absolute guarantees
- In particular, you usually do not get the guarantees discussed in 
“Problems with Replication Lag” (reading your writes, monotonic reads, or 
consistent prefix reads), so the previously mentioned anomalies can occur in 
applications.
- Stronger guarantees generally require transactions or consensus. We will 
return to these topics in Chapter 7 and Chapter 9.

##### Monitoring staleness
- In leader based replication, replication lag can be measured using diff bet 
leader and follower's current position in WAL
- In leaderless replication, there is no fixed order in which writes are 
applied, which makes monitoring more difficult.
- Moreover, if DB uses only read repairs (and no anti-entropy), there is no 
limit to how old a value might be, if a value is infrequently read
    - value returned by a stale replica may be ancient.
- But it is always good to include staleness measurements in the standard set 
of metrics for databases

##### Sloppy Quorums and Hinted Handoff
- With appropriately configured quorums
    - can tolerate node failures w/o need for failover
    - also tolerate individual nodes going slow (bec of overload), bec 
    requests don’t have to wait for all n nodes to respond
        - requests can return when w/r nodes have responded

- Above chars suits systems requiring high availability and low latency
    - provided systems can tolerate occasional stale reads.

- However, n/w breaks may prevent clients to reach w/r nodes
- In large clusters (with more n nodes), during n/w interruption, client can connect to some nodes, 
but not required Quorums
- Two trade-offs to consider
    - return error
    - allow writes to some w nodes, not necessarily from quorum => Sloppy Quorums
- Sloppy Quorums
    - writes and reads still require w and r successful responses, but those 
    may include nodes that are not among the designated n “home” nodes for a value. 
    - once n/w recovers, nodes can send writes to appropriate home nodes => Hinted Handoff
    - uses full t increase write availability
    - But clients are not sure to read latest value
    - So Sloppy Quorum is just assurance to durability
    - Sloppy Quorum is optional in all Dynamo (Cassandra and Voldemort) implementations
    - In Riak, it is enabled by default

##### Multi-datacenter operation
- Leaderless replication is also suitable for multi-datacenter operation since 
it is designed to 
    - Tolerate conflicting concurrent writes
    - Network interruptions and 
    - latency spikes (some nodes going slow)
- Each write is send to all replicas in all DCs, but 
- client client usually only waits for acknowledgment from a quorum of nodes 
within its local datacenter
- higher-latency writes to other datacenters are often configured to happen asynchronously

#### Detecting Concurrent Writes
- Dynamo-style databases allow several clients to concurrently write to the same key
    - means invitation to conflics
- In Dynamo-style databases conflicts can also arise during read repair or hinted handoff.

<img src="/resources/images/ddia/Fig-5-12.png" title="Figure 5-12" style="height: 400px; width:800px;"/>
Figure 5-12. Concurrent writes in a Dynamo-style datastore: there is no well-defined ordering.


- Above, two clients, A and B, simultaneously writing to a key X in a three-node datastore
- If each node simply overwrote the value for a key whenever it received a 
write request from a client, the nodes would become permanently inconsistent
- In order to become eventually consistent, the replicas should converge 
toward the same value. How ?

- Solutions to conflic resolutions
    - LWW (Last Write Wins)
        - Only supported conflict resolution method in Cassandra
        - An optional feature in Riak
        - LWW achieves eventual convergence, but at the cost of durability
        - If loosing data is not acceptable then LWW is not suitable
    - Virsion Vectors
        - Ensures data is not lost

<img src="/resources/images/ddia/Fig-5-13.png" title="Figure 5-13" style="height: 400px; width:800px;"/>
Figure 5-13. Capturing causal dependencies between two clients concurrently editing a shopping cart.

<img src="/resources/images/ddia/Fig-5-14.png" title="Figure 5-14" style="height: 400px; width:800px;"/>
Figure 5-14. Graph of causal dependencies in Figure 5-13

## Chapter 6. Partitioning
- Partitioning 
    - Intensionally breaking large DB into small one
    - Helps to acheive very high query throughput
- Different names to partitining
    - Shards - MongoDB, Elasticsearch and SolrCloud
    - region - HBase
    - tablet - Bigtable
    - vnode - Cassandra and Riak
    - vBucket - Couchbase
- Partitions are defined such that each piece of data (each record, row, 
or document) belongs to exactly one partition
- Each Partition is small DB as it's own
- DB supports operations that supprt multiple partitions at the same time
- Main reason to partition is Scalability
- Different partitions can be placed on different nodes in a shared-nothing cluster
- Query load distributed across many nodes

- In this Chapter, will see
    - Different approaches for partitioning large datasets
    - how the indexing of data interacts with partitioning
    - How rebalancing works
        - requires when nodes are added/removed in cluster
    - How DB routes requests to right partitions 

### Partitioning and Replication
- Everything about replication of databases applies equally to replication of partitions. 
- The choice of partitioning scheme is mostly independent of the choice of replication scheme
- so we will ignore replication in this chapter.

<img src="/resources/images/ddia/Fig-6-1.png" title="Figure 6-1" style="height: 400px; width:800px;"/>
Figure 6-1. Combining replication and partitioning: each node acts as leader for some partitions and follower for other partitions.

### Partitioning of Key-Value Data
- If partitioning is unfair, data skewed can happen
    - makes partitioning less effective
    - only some nodes will serve queries
- A partition with disproportionately high load is called a hot spot
- The simplest approach for avoiding hot spots => assign records to nodes randomly
    - Big DisAdv => while reading, no way to know which node contains key.
    - So have to query all nodes in parallel

### Partitioning by Key Range
<img src="/resources/images/ddia/Fig-6-2.png" title="Figure 6-2" style="height: 400px; width:800px;"/>
Figure 6-2. A print encyclopedia is partitioned by key range.

- Partitioning is to assign a continuous range of keys
- from some minimum to some maximum to each partition
- DisAdv 
    - The ranges of keys are not necessarily evenly spaced
- Partition boundaries might be chosen
    - manually by DB Admin
    - automatically by DB it self, used by
        - BigTable, HBase, RethinkDB, and MongoDB before version 2.4 

- Within each partition, we can keep keys in sorted order => makes range scan very fast
- DisAdv
    - certain access patterns can lead to hot spots

### Partitioning by Hash Key
- To mitigate risk of skew and hot stop, many distributed DBs uses a hash function to decide partition
- A good hash function takes skewed data and makes it uniformly distributed
- 32-bit hash function returns random no bet 0 To 2^32 - 1
- Even if the input strings are very similar, their hashes are evenly distributed across that range of numbers.

- hash function need not be cryptographically strong for partition purpose.
- MongoDB uses MD5, Cassandra uses Murmur3, and Voldemort uses the Fowler–Noll–Vo function.
- Many programming languages have simple hash built in functions
    - Java’s Object.hashCode()
    - Ruby’s Object#hash
    - But are not suitable for partitining
    - Bec same key may have a different hash value in different processes
- Post selecting suitable hash functin,  assign each partition a range of 
hashes (rather than a range of keys)

<img src="/resources/images/ddia/Fig-6-3.png" title="Figure 6-3" style="height: 400px; width:800px;"/>
Figure 6-3. Partitioning by hash of key.

- This technique is good at distributing keys fairly among the partitions.
- The partition boundaries can be 
    - evenly spaced, or 
    - chosen pseudorandomly => consistent hashing
- Big DisAdv
    - range queries are more expensive
    - adjacent keys are now distributed across all partitions => sort order is lost
    - So range query has to sent to all partitions

- Cassandra achieves a compromise between the two partitioning strategies
    - you can define compound primary key consisting of several columns.
    - Only the first part of that key is hashed to determine the partition
    - other columns are used as a concatenated index for sorting the data in Cassandra’s SSTables.
    - so range queries on first column is not supported, but
    - with fixed value of first column, it can perform an efficient range scan over the other columns of the key
    - This approach helps in one-to-many relationships
        - e.g. on a social media site, one user may post many updates
        - compound primary key => (user_id, update_timestamp)
        - Different users may be stored on different partitions
        - But within each user, the updates are stored ordered by timestamp on a single partition.
        - So you can efficiently retrieve all updates made by a particular user within some time interval

### Skewed Workloads and Relieving Hot Spots
- Key hashing can reduce hot spots, but can't avoid entirely
- extream case => celebrity user => all read and writes ends up on single partition
- Today, most data systems are not able to automatically compensate for such 
a highly skewed workload, so it’s the responsibility of the application to reduce the skew.
- Sol
    - for small number of hot keys, append some random number so they get ditributed across partitions

### Partitioning and Secondary Indexes
- A secondary index usually doesn’t identify a record uniquely but rather is 
a way of searching for occurrences of a particular value
- e.g. find all cars whose color is red

- The problem with secondary indexes is that they don’t map neatly to partitions
- Two main approaches to partitioning a database with secondary indexes
    - document-based partitioning
    - term-based partitioning.

#### Partitioning Secondary Indexes by Document

<img src="/resources/images/ddia/Fig-6-4.png" title="Figure 6-4" style="height: 400px; width:800px;"/>
Figure 6-4. Partitioning secondary indexes by document.

- aka local index
- Each partition maintains it's own Secondary Indexes covering only documents/rows in that partition
- However, reading from a document-partitioned index requires 
    - query to each partition
    - combine results before sending it to client
    - aka scatter/gather pattern
    - makes read queries expensive
- This pattern used in MongoDB, Riak, Cassandra, Elasticsearch, SolrCloud, and VoltDB
- Most DB vendors recommend to structure partitioning scheme so that secondary 
index queries can be served from a single partition
    - But this is not always possible
    - e.g. filtering cars by color and make at the same time


#### Partitioning Secondary Indexes by Term
<img src="/resources/images/ddia/Fig-6-5.png" title="Figure 6-5" style="height: 400px; width:800px;"/>
Figure 6-5. Partitioning secondary indexes by term.

- aka global index => covers data in all partitions
- A global index must also be partitioned, but it can be partitioned 
differently from the primary key index
- In above fig, car colors starting with the letters a to r appear in partition 0 
and colors starting with s to z appear in partition 1
- This is useful for range scans => makes read more efficient
- DisAdv
    - writes are slow and more complicated
    - Write to single document now affect multiple partitions 
- Term partitioned index require a distributed transaction across all partitions 
affected by a write, which is not supported in all databases (see Chapter 7 and Chapter 9).
- Often, updates to secondary indexes are asynchronous
- Riak's search feature lets you choose bet local and global indexing

### Rebalancing Partitions
- moving load from one node in the cluster to another is called rebalancing.
- rebalancing is usually expected to meet some min requirements irrespctive of 
partitioning schema
    - After rebalancing, the load (data storage, read and write requests) 
    should be shared fairly between the nodes in the cluster.
    - While rebalancing is happening, the database should continue accepting 
    reads and writes.
    - No more data than necessary should be moved between nodes, to make 
    rebalancing fast and to minimize the network and disk I/O load.

#### Strategies for Rebalancing

##### How not to do it: hash mod N
- The problem with the mod N approach is that if the number of nodes N changes, 
most of the keys will need to be moved from one node to another. 
- Such frequent moves makes Rebalancing expensive
- So need other approach. Solutions
    - Fixed partitioning
    - Dynamic partitioning

 ###### Fixed partitioning
- Keep fixed number of partitions over N nodes
- select number of partitions sufficiently large to accomodate future growth
- e.g. 100 nodes, 1000 partitions => each node get 100 partitions
- Only entire partitions are moved between nodes. 
- The number of partitions does not change, nor does the assignment of 
keys to partitions.
- Only change is assignment of patitions to nodes
- You can also assign more partitions of m/c's with more powerfull h/w
- This approach used in Riak, Elasticsearch, Couchbase, and Voldemort.

<img src="/resources/images/ddia/Fig-6-6.png" title="Figure 6-6" style="height: 400px; width:800px;"/>
Figure 6-6. Adding a new node to a database cluster with multiple partitions per node.

- There are trade-offs how large partition should be...
    - large partitions => expensive rebalancing and recovery from node failure
    - small partitions => incurs too much overheads
    - if dataset is highly variable (e.g. staets small, but grows very rapidly), 
    it is difficult to choose partition size

###### Dynamic partitioning
- DBs that uses Key range partitioning, if you select partition boundaries incorrectly 
then you may end up having data in one partition and other partitions being empty
- To avoid this, Key range partitioning DBs (HBase, RethinkDB) creats partitions dynamically
- 10 GB => HBase's default partition size
- If partition grows over threshold, it splits it int two
- Conversely, if data shrinks below threshold, it merges with an adjacent partition
- Adv 
    - no of partitions adapat t dataset size / data volume
- DisAdv
    - Empty DB starts with single partition and all queries server by single node only
    - Sol => HBase and MongoDB allows to set initial set of partitions, aka pre-splitting
- Dynamic partitioning is useful for hash partitioned data as well
- MongoDB since version 2.4 supports both key-range and hash partitioning
    - it splits partitions dynamically in either case


##### Partitioning proportionally to nodes
- In Dynamic partitioning
    - number of partitions   is proportional to the size of the dataset
- In Fixed partitioning
    - size of each partition is proportional to the size of the dataset
- Third option used by Cassandra and Ketama
    - number of partitions proportional to the number of nodes
    - size of each partition grows proportionally to the dataset size while 
    the number of nodes remains unchanged
    - But when you increase the number of nodes, the partitions become smaller again
    - This approach also keeps the size of each partition fairly stable.

#### Operations: Automatic or Manual Rebalancing
- Fully automated rebalancing can be convenient, but it can be unpredictable
- Rebalancing is expensive operation
    - requires re-routing requests
    - moving large amount of data
- If not done carefully, can overload n/w and nodes. May hamper ongoing read/write queries
- If failover happens during Rebalancing, situation may worsen causing a cascading failure
- So it is good to keep human in loop while rebalcing
    - slower than fully automatic process, but prevents operational suprises. 
- Couchbase, Riak, and Voldemort generate a suggested partition assignment automatically, 
but require an administrator to commit it before it takes effect.

### Request Routing
- This is an instance of a more general problem called service discovery
- Few appraches used. See Figure 6-7
<img src="/resources/images/ddia/Fig-6-7.png" title="Figure 6-7" style="height: 400px; width:800px;"/>
Figure 6-7. Three different ways of routing a request to the right node.

- Cassandra uses approach one
- In all cases, the key problem is: 
    - how does the component making the routing decision (which may be one 
    of the nodes, or the routing tier, or the client) learn about changes 
    in the assignment of partitions to nodes?

- Most systems ely on a separate coordination service such as ZooKeeper to 
keep track of this cluster metadata. See Figure 6-8
<img src="/resources/images/ddia/Fig-6-8.png" title="Figure 6-8" style="height: 400px; width:800px;"/>
Figure 6-8. Using ZooKeeper to keep track of assignment of partitions to nodes.

- ZooKeeper maintains the authoritative mapping of partitions to nodes
- ZooKeeper informs changes (node or partition changes) to routing layer
- HBase, SolrCloud, and Kafka also use ZooKeeper to track partition assignment
- MongoDB has a similar architecture, but it relies on its own config server 
implementation and mongos daemons as the routing tier.

- Cassandra and Riak take a different approach
    - use a gossip protocol among the nodes to disseminate any changes in cluster state. 
    - This model puts more more complexity in the database nodes but avoids 
    dependency on an external coordination service such as ZooKeeper.
- Couchbase does not rebalance automatically,
    - Normally it is configured with a routing tier called moxi
    - moxi learns about routing changes from the cluster nodes 

### Summary
- Goal of partitioning
    - spread data and query load evenly across nodes
- Two approaches to partitioning
    - Key range partitioning
        - keys are sorted
        - partition owns keys from some min to max range
        - makes range queries efficient
        - risk - creating hot spots for frequently accessed keys
        - Sol
            - Partitions are rebalanced dynamically when partition grows
    - Hash partitioning
        - hash(key), partition by hash ranges
        - Destroyes sort order => inefficient range queries
        - may distribute load evenly
        - It is common to create fixed no of partitions in advance
    - Hybrid approach also possible with compund key
        - one key used to find partition
        - other key for sort order
- Socondary indexes need to partitioned as well. Two methds
    - Document-partitioned indexes (local indexes)
        - Write - Socondary indexes stored in same partition as that of key
        - read - requires expensive scatter/gather approach 
    - Term-partitioned indexes (global indexes)
        - write - many partitions need to update when key is created/updated
        - read - can be served from a single partition
- Every partition operates mostly independently
- And with this, DB can scale to multiple m/c's
- But writting to several partitions makes things complex 
- What happen if write to one partition succeeds, but failed on another
- Will discuss this question in Chapter 7 


## Chapter 7. Transactions

Transaction => group of several reads and writes put together into logical unit

- In DB, things may go wrong bec of
    - DB s/w or h/W fails at any time (say in middle of write transaction)
    - application crashs (in mid of operations)
    - N/W interruption cut of app and DB
    - several clients writes to DB at the same time, overwriting each other changes
    - Race conditions bet clients

- To be reliable, you need to deal above faults to prevent catastrophic failures
- Implementing fault tolerance mechanism requires careful thinking and lot of testing
- For decades, Transactions solves/simplifies  these issues.
- Transaction execute as one operatin. Either it fails or succeeds
- This makes application much simpler. 
- It need not to worry if some operations fails and some fails (for any reason)

- However, transactions shuld not be taken as granted. They are not a law of nature 
- Transaction's main purpose => simplify programming model
- By using transactions, the application is free to ignore certain potential 
error scenarios and concurrency issues, bec DB takes care of them 
instead => aka safety guarantees

- Sometimes there are advantages to weakening transactional guarantees or 
abandoning them entirely => to acheive higher performance and availability
- Some safety properties can be achieved without transactions

- How to decide if transaction is required?
    - First, understand which safety guarantees they provide
    - and cost of it
- In this Chapter
    - will see things that go wrong
    - How DB handle them
    - will see concurrency control, diff race conditions
    - How DB implements isolation levels. e.g.
        - read committed
        - snapshot isolation
        - serializability
- This chapter applies to both single-node and distributed databases; 
- In Chapter 8 we will focus the discussion on the particular challenges 
that arise only in distributed systems.

### The Slippery Concept of a Transaction
- Almost all relational DBs and some non-relational DBs support transactions
- Mosy of them follow the style used by IBM's System R (introdcued in 1975)
- With new crop of NoSQL DBs, popular belief emerged that 
    - transactions were the antithesis of scalability
    - any large-scale system would have to abandon transactions in order 
    to maintain good performance and high availability
- On the other hand, relational DB vendors presses for transactional guarantees 
for “serious applications” with “valuable data.”
- Both viewpoints are pure hyperbole.
- like every design choice, transactions have advantages and limitations.

#### The Meaning of ACID
- ACID => Atomicity, Consistency, Isolation, and Durability
- System not meeting ACID criteria are called BASE (Basically Available, 
Soft state, and Eventual consistency)
- But sensible definition of BASE is “not ACID”

##### Atomicity
- something that cannot be broken down into smaller parts
- ACID atomicity
    - describes what happens if a client wants to make several writes, but 
    a fault occurs after some of the writes have been processed
    - faults => n/w interrupted, disk full, or some integrity constraint is violated
    - If writes are gruped into transaction, then either it fails or succeeds. No other state.
    - ability to abort a transaction on error => discard all writes from that transaction
    - This can be called as *abortability*

##### Consistency
- In the context of ACID, consistency refers to an application-specific 
notion of the database being in a “good state.”
- you have certain statements about your data (invariants) that must always be true
    - e.g. accounting system, credits and debits across all accounts must always be balanced
- It’s the application’s responsibility to define its transactions correctly 
so that they preserve consistency
- If you write bad data that violates your invariants, the database can’t stop you
- Atomicity, isolation, and durability are properties of the database, 
whereas consistency (in the ACID sense) is a property of the application.
- The application may rely on the database’s atomicity and isolation 
properties in order to achieve consistency

##### Isolation
- A race condition can be intrduced of > two clients reading/writing same DB record

<img src="/resources/images/ddia/Fig-7-1.png" title="Figure 7-1" style="height: 400px; width:800px;"/>
Figure 7-1. A race condition between two clients concurrently incrementing a counter.

- See Figure 7-1. 
    - Counter should have incremented to from 42 to 44 bec two increment happens
    - But it actually went to 43 bec of race condition
- Isolation in the sense of ACID means that concurrently executing transactions 
are isolated from each other
- Each transaction can pretend that it is the only transaction running on the entire DB
    - known as serializability
- DB ensures when transactions are committed, the result is the same as if 
they had run serially (one after another), even though they have run concurrently in reality 
- In practice, serializable isolation is rarely used
    - Bec of performance penalty
- Some DBs implement snapshot isolation => weaker guarantee than serializability

##### Durability
- Is the promise that once a transaction has committed successfully, any data 
it has written will not be forgotten, even if there is a h/w fault or DB crashes.
- Durability => data is written to non-volatile storage
- In practice, there is no one technique that can provide absolute guarantees
- only various risk-reduction techniques
    - writing to disk, replicating to remote machines, and backups etc

### Single-Object and Multi-Object Operations
- Multi-object transactions are often needed if several pieces of data need to be kept in sync
- See Figure 7-2

<img src="/resources/images/ddia/Fig-7-2.png" title="Figure 7-2" style="height: 400px; width:800px;"/>
Figure 7-2. Violating isolation: one transaction reads another transaction’s 
uncommitted writes (a “dirty read”).

- When user 2 checks emails table, s/he sees one unread email
- But mailboxes (where numbe of unread message count is stored) returns 0
- This happens bec user 2 trying to read user 1's uncommitted transaction


<img src="/resources/images/ddia/Fig-7-3.png" title="Figure 7-3" style="height: 400px; width:800px;"/>
Figure 7-3. Atomicity ensures that if an error occurs any prior writes from 
that transaction are undone, to avoid an inconsistent state.

- Figure 7-3 insists need to atomacity. 
- If error occurs inbet two writes, DB remain in inconsistent state
- Multi-object transactions require some way of determining which read and 
write operations belong to the same transaction
- Generally, everything bet BEGIN TRANSACTION and COMMIT considered as same transaction.
- However, many NoSQL DBs don’t have such a way of grouping operations together

#### Single-object writes
- storage engines almost universally aim to provide atomicity and isolation 
on the level of a single object (such as a key-value pair) on one node
- Atomicity can be implemented using a log (e.g. WAL) for crash recovery
- isolation can be implemented using a lock on each object
- Some DB supprts few complex operations like 
    - increment operation => eleminates read-modify-write cycle
    - compare-and-set operation => write only if value not changed concurrently

#### The need for multi-object transactions
- Use Cases where multi-object transactions are required => several different 
objects need to be coordinated
    - In relatinal model, when inserting several records that refer to one 
    another, the foreign keys have to be correct and up to date
    - Document data model lacks join functionality. Sol => Denormalization. 
    - But when denormalize data (like in Figure 7-2) need to update, you need to 
    update several documents in one go
    - secondary indexes need to be updated every time you change a value
    - without transaction isolation, it’s possible for a record to appear in 
    one index but not another. Bec second index hasn't updated yet.

- Above use cases can still be implemented w/o transactions, but 
    - w/o atomacity error handling becomes much more complicated
    - and lack of isolation can cause concurrency issues

#### Handling errors and aborts
- ACID DB philosophy
    - if DB in danger to violet it's atomicity, isolation, or durability, 
    guarantees then abandon the transaction entirely rather keep it half-finished
- Application can retry failed transaction, but it's not simple and effective error
handling mechanism
    - Bec of n/w failure, if client does not receive commit ack then client 
    can retry same transaction causing it running twice. 
    - You need to have deduplication mechanism to address above case
    - If error occure bec of overloading, retrying can cause more issues. Sol is
        - limit no of retries
        - use exponential backoff
        - handle overload-related errors differently from other errors (if possible).
    - retry only after transient errors and not after permanent error.
    - If transaction also has side effects outside DB, then it need to 
    rollback as well on transaction abort
    - 2PC can help if you want several systems to either commit or abort together

### Weak Isolation Levels
- => Non-serializable
- Concurrency issues / race conditions happens when
    - when one transaction reads data that is concurrently modified by 
    another transaction
    - two transactions try to simultaneously modify the same data
- Concurrency bugs are hard to find and reproduced as they are timing related
- Therefore DBs hide concurrency issues from application developers by providing transaction isolation.
- Serializable isolation => DB guarantees that transactions have the same 
effect as if they ran serially => one at a time, without any concurrency
- But Serializable isolation has performance cost
- So systems uses weak isolation levels which protect sme concurrency issues, but not all
- However, weak isolation levels are used in practice
- So rather blindly replying on tools, understand concurrency problems that 
exist, and how to prevent them

#### Read Committed
- is most basic level of transaction isolation
- Some DBs support even less weaker isolation level => read uncommitted
    - It prevents dirty writes, but does not prevent dirty reads

- Read Committed makes two guarantees
    - no dirty reads => when reading DB, client only sees data that has committed
    - no dirty writes => when writing DB, client only overwrites data that has been committed

##### No dirty reads
- See Figure 7-4. User 2 sees value of x only after User 1 commits it.

<img src="/resources/images/ddia/Fig-7-4.png" title="Figure 7-4" style="height: 400px; width:800px;"/>
Figure 7-4. No dirty reads: user 2 sees the new value for x only 
after user 1’s transaction has committed.

- Why it’s useful to prevent dirty reads:
    - It prevents issues mentined in Figure 7-2
    - If transaction rolled back, then any writes will be reverted. See Figure 7-3
    If dirty reads allowed, then transaction may see data that is later rolled back

##### No dirty writes
- When two transaction concurrently try to update the same DB object?
    - we don't t know in which order the writes will happen, but
    - normally assume that the later write overwrites the earlier write.
- dirty write => later write transaction overwrites uncommitted value of earlier transaction
- Transactions running at the read committed isolation level must prevent dirty writes
    - usually by delaying the second write until the first write’s transaction has committed or aborted


<img src="/resources/images/ddia/Fig-7-5.png" title="Figure 7-5" style="height: 400px; width:800px;"/>
Figure 7-5. With dirty writes, conflicting writes from different transactions 
can be mixed up.

- Dirty writes avoids some some kinds of concurrency problems:
    - See Figure 7-5 showing use case of used car sales website
        - Alice and Bob, are simultaneously trying to buy the same car
        - Sale is awarded t Bob, while invice is sent to Alice
        - Read committed prevents such mishaps. 
    - However, Read committed does not prevent race condition in Figure 7-1
        - the second write happens after the first transaction has committed, 
        so it’s not a dirty write.
        - It is still incorrect, but for diff reason
        - In “Preventing Lost Updates” section, we will see how to make such counter increment safe

##### Implementing Read Committed
- Read Committed is very popular isolation level. 
- is default setting in Oracle 11g, PostgreSQL, SQL Server 2012, MemSQL, and many other DBs
- DB prevent dirty writes by using row-level locks.
- This locking is done automatically in Read Committed mode
- How to prevent dirty reads
    - Option 1: use same lock mechanism
        - But this has big issues
        - long-running write transaction make many read transaction to wait 
        and harms response time => causes bad operability
        - this slowdown can propgate to diff part of the application
    - Most DB uses apprached mentioned in Figure 7-4
        - DB remembers both old committed value and new value of currently ongoing uncommitted transaction
        - Other transactions that read the objects are given old values 
        - DB starts retuning new value, once ongoing transaction is committed.

### Snapshot Isolation and Repeatable Read
- Even after DB supports read committed isolation, there are ways to occure 
concurrency bugs. See Figure 7-6

<img src="/resources/images/ddia/Fig-7-6.png" title="Figure 7-6" style="height: 400px; width:800px;"/>
Figure 7-6. Read skew: Alice observes the database in an inconsistent state.

- Alice feels that she has 900 balance, but actually balance is 1000
- If Alice refreshes her page of bank account after some time, she would see balance as 1000
- This anomaly is called as Read skew (timing anomaly) or nonrepeatable read

- For above scenario, read skew is acceptable, but it would not be 
acceptable for other scenarios, like
    - Backups
        - If a Backup is going on and it sees what Alice saw above and then 
        later backup is restored then DB will be in inconsistent state
        - And that state would become permanent
    - Analytic queries and integrity checks
        - will return nonsensical results
- Snapshot isolation is common solution to Read skew.
- Idea is each transaction sees consistent snapshot of DB
- Snapshot isolation is a boon for long-running, read-only queries such 
as backups and analytics.
- Snapshot isolation is popular feature supported by many DBs
    - PostgreSQL, 
    - MySQL with the InnoDB storage engine, 
    - Oracle, 
    - SQL Server and others

#### Implementing snapshot isolation
- Key principle =>  readers never block writers, and writers never block readers
- This allows DB to support long running read queries and hanlde write queries 
at the same time w/o any lock contention
- snapshot isolation is generalization of the mechanism we saw for preventing 
dirty reads in Figure 7-4.
- DB keeps diff committed versions of an object side by side => MVCC
    - multi-version concurrency control
- DB supporting snapshot isolation typically uses MVCC for read committed isolation as well

<img src="/resources/images/ddia/Fig-7-7.png" title="Figure 7-7" style="height: 400px; width:800px;"/>
Figure 7-7. Implementing snapshot isolation using multi-version objects.

- Figure 7-7 illustrates MVCC

#### Visibility rules for observing a consistent snapshot
- While reading, transaction IDs are used to decide which objects it can see and which are invisible
- Visibility rules are 
    1. At start of each transaction, DB creates list of all other in progress 
    transactions
        - Any writes that those transactions have made are ignored, even if the transactions subsequently commit
    2. Any writes made by aborted transactions are ignored.
    3. Any writes made by transactions with a later transaction ID (i.e., 
    which started after the current transaction started) are ignored, 
    regardless of whether those transactions have committed.
    4. All other writes are visible to the application’s queries.

#### Indexes and snapshot isolation
- Option 1
    - Index to pint all versions of objects and filter out any version that are 
    not visible to current transaction
    - Used by PostgreSQL 
- Option 2
    - use an append-only/copy-on-write variant
    - This is used by CouchDB, Datomic, and LMDB

#### Repeatable read and naming confusion
- snapshot isolation is called by diff names in diff DBs
    - serializable => Oracle
    - repeatable read => PostgreSQL and MySQL
- Reason for diff names is SQL standard does not have snapshot isolation concept
- IBM DB2 uses “repeatable read” to refer to serializability

### Preventing Lost Updates
- Read committed and snapshot isolation levels guarantees of what a 
read-only transaction can see in the presence of concurrent writes
- What about two transactions writing concurrently
- dirty writes => only one type of write-write conflict
- Several other conflicts can occur bet concurrently writing transactions.
    - Like Lost Update Problem 
    - Figure 7-1 => Two concurrent counter increments.
- Lost Updates occure during read-mdify-write cycle
- If two transactions doing read-mdify-write simultaneously, one's modification can be lost
- This pattern occur in diff scenarios
    - Incrementing a counter or updating an account balance
    - adding an element to a list within a JSON document (requires parsing 
    document, making the change, and writing back the modified document)
    - Two users editing a wiki page at the same time
- variety of solutions have been developed.

##### Atomic write operations
- DB removes read-mdify-write cycle and support atomic update operations instead

```SQL
UPDATE counters SET value = value + 1 WHERE key = 'foo';
```
- MongoDB and Redis supports this
- But not all operatins can be supported with above
- Like updating wiki page involving arbitrary text editing
- Atomic operations => takes exclusive lock on object when it is read, so no
other transactions can read it until update happens. aka cursor stability

##### Explicit locking
- Application explicitly lock objects that are going to be updated

Example 7-1. Explicitly locking rows to prevent lost updates
```SQL
BEGIN TRANSACTION;

SELECT * FROM figures
  WHERE name = 'robot' AND game_id = 222
  FOR UPDATE; -- => lock all rows returned by above query

-- Check whether move is valid, then update the position
-- of the piece that was returned by the previous SELECT.
UPDATE figures SET position = 'c4' WHERE id = 1234;

COMMIT;
```
- Above works, but it is easy to forget by programmer

##### Automatically detecting lost updates
- transaction manager to detects a lost update, abort the transaction and 
force it to retry its read-modify-write cycle.
- This is less error prone comapred with Explicit locking
- DBs can perform this check efficiently in conjunction with snapshot isolation
- Supprted by
    - PostgreSQL’s repeatable read
    - Oracle’s serializable
    - SQL Server's snapshot isolation levels
- But MySQL/InnoDB’s repeatable read does not detect lost updates 

##### Compare-and-set
- DBs that don't support transactions, can support atomic compare-and-set operation
    - avoids lost update
    - allow an update to happen only if the value has not changed since you 
    last read it.

##### Conflict resolution and replication
- Some additional steps required if data is replicated on diff nodes
- DBs with multi-leader or leaderless replication 
    - allow several writes to happen concurrently and 
    - replicate them asynchronously
    - So can not guarantee single up-to-date copy of the data
    - So locks and Compare-and-set do not apply here
    - Will see this issue in  “Linearizability”
- Common Solution
    - allow concurrent writes to create several conflicting versions of a value
    - use application code or special data structures to resolve and merge these versions

### Write Skew and Phantoms
- dirty writes and lost updates race conditions can occur when different 
transactions concurrently try to write to the same objects
- Let's see another race condition. See Figure 7-8

<img src="/resources/images/ddia/Fig-7-8.png" title="Figure 7-8" style="height: 400px; width:800px;"/>
Figure 7-8. Example of write skew causing an application bug.

- Above use case requirement => you must have at least one Dr on call
- But above, Alice and Bob goes off call at the same time and above requirement is violated
- Since DB using snapshot isolation, both the checks return 2 (currently_on_call = 2)
- So both transactions moves futher with update
- This anomaly is called Write Skew

#### Characterizing write skew
- This is neither dirty write or lost update
- Bec tow transactions updating diff objects (Alice’s and Bob’s on-call records, respectively)
- if the two transactions had run one after another, the second doctor would 
have been prevented from going off call.
- The anomalous behavior was only possible because the transactions ran concurrently.
- Write skew is generalization of the lost update problem
- Write skew can occur if two transactions read the same objects, and then 
update some of those objects
- If transactions update same object, you either get dirty write or lost update
anomaly depending on time

- We see various different ways of preventing lost updates, but write skew, 
our options are more restricted:
    - Automatically preventing write skew requires true serializable isolation
    - Constraints can be used, but not all DBs support them
        - But you can implement them using triggers or materialized views
    - If you can't use serializable isolation, then second best option is to use locks
        ```SQL
        BEGIN TRANSACTION;

        SELECT * FROM doctors
        WHERE on_call = true
        AND shift_id = 1234 FOR UPDATE; 

        UPDATE doctors
        SET on_call = false
        WHERE name = 'Alice'
        AND shift_id = 1234;

        COMMIT;

        ```
#### More examples of write skew

- Meeting room booking system
    - Example 7-2. A meeting room booking system tries to avoid double-booking 
    (not safe under snapshot isolation)
        ```SQL
        BEGIN TRANSACTION;

        -- Check for any existing bookings that overlap with the period of noon-1pm
        SELECT COUNT(*) FROM bookings
        WHERE room_id = 123 AND
            end_time > '2015-01-01 12:00' AND start_time < '2015-01-01 13:00';

        -- If the previous query returned zero:
        INSERT INTO bookings
        (room_id, start_time, end_time, user_id)
        VALUES (123, '2015-01-01 12:00', '2015-01-01 13:00', 666);

        COMMIT;
        ```
    - Unfortunately, snapshot isolation does not prevent another user from 
    concurrently inserting a conflicting meeting.
    - Here, you need serializable isolation.

- Multiplayer game    
    - In Example 7-1, we used a lock to prevent lost updates
    - But lock doesn’t prevent players from moving two different figures to 
    the same position on the board
- Claiming a username
    - Two users trying to create an accunt with same username
    - Fortunately, a unique constraint is a simple solution here
- Preventing double-spending
    - A service that allows users to spend money or points needs to check 
    that a user doesn’t spend more than they have
    - With write skew, two spending items can inserted concurrently which 
    can make balance negative

#### Phantoms causing write skew

- All above examples follow a similar pattern:
    1. SELECT query checks some requirement is satisfied
        - at least two Drs are on call
        - no existing booking for meeting room
        - username isn't already taken
        - positive and sufficient money in the account
    2. Depending on SELECT query result, application code moves ahead with update
    3. Application do either INSERT, UPDATE, or DELETE

- The effect of this write changes the precondition of the decision of step 2
- In Dr's case transactions checks for some existence of rows 
    - So you can lock those rows and prevent issue
- But in other cases, transactions checks for absense of rows
    - If the query in step 1 doesn’t return any rows, SELECT FOR UPDATE 
    can’t attach locks to anything.
- This effect, where a write in one transaction changes the result of a 
search query in another transaction, is called a phantom
- Snapshot isolation avoids phantoms in read-only queries
- But in read-write transactions (like above examples) phantoms can lead 
to particularly tricky cases of write skew.

##### Materializing conflicts
- The problem of phantoms is there is no objects/rows to lock
- One Solution - Inject such rows in advance.
    - Like all possible meeting rooms schedule for upcoming week
- materializing conflicts => it takes a phantom and turns it into a lock 
conflict on a concrete set of rows that exist in the database
- Unfortunately, it can be hard and error-prone to figure out how to materialize conflicts,
- Therefre materializing conflicts should be considered a last resort if no 
alternative is possible
- A serializable isolation level is much preferable in most cases.

### Serializability
- is strongest isolation level
- It guarantees parallelly running transactions's end result is same as if 
they had executed one at a time, serially, w/o concurrency
- With Serializability, DB prevents all race condition
- one of following techniques used to provide Serializability
    - Actual Serial Execution
    - Two-Phase Locking (2PL)
    - Serializable Snapshot Isolation (SSI)) => Optimistic concurrency control

#### Actual Serial Execution
- execute one transaction at a time serially, on a single thread
- completely avoids detecting and preventing conflicts between transactions
- Some of follwing facts changed to moved to single threaded execution than multi-threaded?
    - RAM became cheap. 
    - When all data required for transaction resides in RAM, it executes 
    faster than fetched it from disk
    - OLTP transactions are short and make small no of writes and reads
    - And Long running OLAP read-only queries can be run on consistent snapshot
- This approach is used in VoltDB/H-Store, Redis, and Datomic
- single-threaded execution can avoid coordination overhead of locking, so it 
can perform better vs multi-threaded
- But throughput is limited to single CPU core

##### Encapsulating transactions in stored procedures

- systems with single-threaded serial transaction processing don’t allow 
interactive multi-statement transactions.
- application must submit the entire transaction code to the database ahead 
of time, as a stored procedure
- See Figure 7-9

<img src="/resources/images/ddia/Fig-7-9.png" title="Figure 7-9" style="height: 400px; width:800px;"/>
Figure 7-9. The difference between an interactive transaction and a stored 
procedure (using the example transaction of Figure 7-8).

- Provided that all data required by a transaction is in memory, the stored 
procedure can execute very fast, without waiting for any network or disk I/O.

##### Pros and cons of stored procedures
- SQL Std gain a bad reputation for various reasons
    - DB vendors have their own lang for stored procedure.
        - Oracle => PL/SQL
        - SQL Server => T-SQL
        - PostgreSQL => PL/pgSQL
        - These languages looks ugly and did not kept progress with latest 
        general-purpose programming languages
        - lacks echosystem of libraries
    - Code running in DB is diff to manage, harder to debug and awkward to 
    keep in VCS, diff to deploy, test
    - Diff to integrate w/ metrics collection system for monitoring.
    - Since DB is much more senstitive to performance, badly written stored procedure code
    cause more throuble than equivalent badly written code in an application server.

- Modern implementations of stored procedures have abandoned PL/SQL and use 
existing general-purpose programming languages instead
    - VoltDB => Java or Groovy
    - Datomic => Java or Clojure
    - Redis => Lua

- So stored procedures and in-memory data, not waiting for I/O avoids 
concurrency control mechanisms  
- And thus acheive good throughput w/ single thread

##### Partitioning
- For application with high write throughput, single-threaded transaction 
processor can become a serious bottleneck.
- You need to partition the data in order to scale to multiple CPUs and nodes
- Partition data in such way that read and write happens on same partition
- This way each CPU code can handle one partition
- Cross partition transaction require to coordinate t avoid race conditions
- VolDB's cross partition write throughput is 1000 / sec which is orders of 
magnitude below its single-partition throughput
    - Also, it can not increased by adding more m/cs
- Simple key-value data can be partitioned easily
- But data w/ multiple secondary indexes likely require cross parition coordination

##### Summary of serial execution
You can acheive erializable isolation within certain constraints
- Every transaction must be small and fast bec a slow transaction stalls others
- Active data set can fit in RAM. One solution can be used anti-caching
    - If transaction needs data from disk, then abort it
    - fetch data from disk in background
    - restart the transaction
- Write throughput must be low enough to be handled on a single CPU core
- Or transactions need to partitioned w/o cross-partition coordination
- Cross-partition transactions are possible, but it should be limited

#### Two-Phase Locking (2PL)
- We saw dirty writes can be prevented using locks
- 2PL is similar, but makes the lock requirements much stronger.
    - many concurrent transactions allowed to read same object as long as nobody is writting
    - Exclusive lock is required to write (modify/delete) an object
    - T1 has read an object and T2 want to write, then T2 must wait till T1 commits or aborts
    - T1 has written an object and T2 want to read, then same as above. T2 must wait.

- 2PL Vs Snapshot isolation
    - In 2PL, writers don’t just block other writers; they also block readers and vice versa
    - In Snapshot isolation readers never block writers, and writers never block readers
    - 2PL supprts serializability, it protects all race conditions including 
    lost updates and write skew

##### Implementation of two-phase locking
- Refer p258 of book

##### Performance of two-phase locking
- The big downside => performance => transaction throughput and response 
times of queries are significantly worse Vs weak isolation
- By design, if two concurrent transactions try to do anything that may in 
any way result in a race condition, one has to wait for the other to complete.
- Therefore DBs running 2PL can have quite unstable latencies, and they can 
be very slow at high percentiles
- Deadlocks can happen more in 2PL, which requires one transaction to 
abort and restart. Means waste efforts

##### Predicate locks
- Refer p259 of book

##### Index-range locks
- aka Index-key locking
- Most 2PL implementations uses Index-range locking

#### Serializable Snapshot Isolation (SSI)
- Issues in earlier Serializable Isolation techniques
    - 2PL => don’t perform well 
    - serial execution => don't scale well
    - weak isolation => good performance, but prone to various race 
    conditions (lost updates, write skew, phantoms, etc.)

- SSI => provides full serializability and have small performance penalty 
compared to snapshot isolation
- SSI is fairly new. SSI was the subject of Michael Cahill’s PhD thesis
- SSI is used in both single-node DBs and distributed DBs

##### Pessimistic versus optimistic concurrency control
- Pessimistic => Someone allways expecting worst
- 2PL is Pessimistic locking 
- SSI is optimistic concurrency control
    - instead of blocking if something potentially dangerous happens, 
    transactions continue anyway
    - hope that everything will turn out all right
    - During transaction commit, DB checks if anything bad happen => isolation was violated
    - If so then abort and retry the transaction
- However, SSI performs badly if many transactions trying to access same object
    - leads high proportion of transactions to abort and restart
- But if contention between transactions is not too high, optimistic 
concurrency control techniques tend to perform better than pessimistic ones.

- SSI is based on snapshot isolation
    - all reads within a transaction are made from a consistent snapshot of DB
    - On top, SSI adds an algorithm for detecting serialization conflicts among writes
    - And determining which transactions to abort.

##### Decisions based on an outdated premise
- In DB queries, a recurring pattern is
    - transaction reads some data
    - examines it 
    - and decides to take actions based on earlier read
- In snapshot isolation
    - result from the original query may no longer be up-to-date by the 
    time the transaction commits
    - bec the data may have been modified in the meantime.
    - means transaction is taking an action based on a premise
    - And by the time, transaction commits, the premise has changed.
    - See Drs on-call example in Figure 7-8
- How DB know if a query result might have changed? There are two cases to consider:
    - Detecting reads of a stale MVCC object version (uncommitted write 
    occurred before the read)
    - Detecting writes that affect prior reads (the write occurs after the read)

##### Detecting stale MVCC reads
- This is first case => T43 reads uncommitted write

<img src="/resources/images/ddia/Fig-7-10.png" title="Figure 7-10" style="height: 400px; width:800px;"/>
Figure 7-10. Detecting when a transaction reads outdated values from an MVCC snapshot.

- When the transaction wants to commit, DB checks whether any of the ignored 
writes have now been committed. If so, the transaction must be aborted.

##### Detecting writes that affect prior reads
- This is second case => when another transaction modifies data after it has been read.

<img src="/resources/images/ddia/Fig-7-11.png" title="Figure 7-11" style="height: 400px; width:800px;"/>
Figure 7-11. In serializable snapshot isolation, detecting when one transaction 
modifies another transaction’s reads.

- T43 notifies T42 that its prior read is outdated, and vice versa. 
- T2 successfully commits first 
- When T43 want to commit, conflicting write from 42 has already been 
committed, so 43 must abort.

##### Performance of serializable snapshot isolation
- In SSI, all transactions reads and writes are tracked.
- This bookkeeping overhead can become significant.
- Less detailed tracking is faster, but may lead to more transactions 
being aborted than strictly necessary.

- Compared to 2PL, transaction doesn’t need to block waiting for locks held 
by another transaction.
- This makes query latency much more predictable and less variable
- In particular, read-only queries can run on a consistent snapshot without 
requiring any locks, which is very appealing for read-heavy workloads

- Compared to serial execution, serializable snapshot isolation is not 
limited to the throughput of a single CPU core
    - Even though data may be partitioned across multiple machines, 
    transactions can read and write data in multiple partitions while 
    ensuring serializable isolation
- The rate of aborts significantly affects the overall performance of SSI
- So SSI requires that read-write transactions be fairly short

### Summary
- Only serializable isolation prevents Write skew anomaly.
- 2PL => Pessimistic concurrency control
- SSI => Optimistic concurrency control

- In this chapter, we explored ideas and algorithms mostly in the context 
of a database running on a single machine. 
- Transactions in distributed databases open a new set of difficult 
challenges, which we’ll discuss in the next two chapters.


## Chapter 9. Consistency and Consensus

In this chapter
- Will see algorithms and protocols for building fault-tolerant distributed systems
- Will assume all the problems from Chapter 8 can occur
    - packets lost, reordered, duplicated, or arbitrarily delayed 
    - clocks are approximate at best
    - nodes can pause (e.g., due to gc) or crash
- The best way of building fault-tolerant systems is
    - find some general-purpose abstractions with useful guarantees
    - implement them once, and 
    - then let applications rely on those guarantees
- Above is same approach used in Transactions (Chapert 7). 
- Transaction abstraction can hide following issues and Application can pretent
    - There are no crashes (atomicity)
    - Nobody else is concurrently accessing the database (isolation)
    - Storage devices are perfectly reliable (durability)

- most important abstractions for distributed systems is consensus
    - means getting all of the nodes to agree on something

- Correct implementations of consensus help avoid issues like 
    - split brain (see Chapter 5)
- In Distributed Transactions and Consensus section, will see algorithms to 
solve consensus and related problems
- Need to understand the scope of what can and cannot be done
    - In some cases, system can tolerate faults and continue working
    - However in some cases, it is not possible 
    - Will explore the limits of what is and isn’t possible in depth in this chapter

### Consistency Guarantees
- Inconsistencies like Replication Lag can occur no matter what replication 
method the database uses (single-leader, multi-leader, or leaderless replication)
- Most DBs support eventual consistency
    - means inconsistency is temporary, and it eventually resolves itself
    - assuming network faults are also eventually repaired
    - A better name for eventual consistency may be convergence
- eventual consistency weak guarantee
    - Until the time of convergence, reads could return anything or nothing
- The edge cases of eventual consistency only become apparent when there is 
a fault in the system (e.g., a network interruption) or at high concurrency.
- You need to aware of limitations of DBs providing weak guarantees.

- Will explore strong guarantees, but they come at cost of being 
    - less tolerant comapred with weaker guarantees

- distributed consistency models and transaction isolation levels are diff
- Transaction isolation means
    - avoiding race conditions due to concurrently executing transactions
- Distributed consistency means
    - coordinating the state of replicas in the face of delays and faults

- In this Chapert, will cover
    - linearizability - one of the strongest consistency models commonly used
    - Ordering events in a distributed system => Ordering Guarantees
    - how to atomically commit a distributed transaction => Distributed Transactions and Consensus

### Linearizability
- aka atomic consistency, strong consistency, immediate consistency, or external consistency
- Idea is to make a system appear as
    - there were only one copy of the data and 
    - all operations on it are atomic
- Single copy of the data means guaranteeing 
    - value read is the most recent, up-to-date value, and 
    - doesn’t come from a stale cache or replica (bec of replication lag)
- linearizability is a recency guarantee
    - recency => ability of being recent

<img src="/resources/images/ddia/Fig-9-1.png" title="Figure 9-1" style="height: 400px; width:800px;"/>
Figure 9-1. This system is not linearizable, causing football fans to be confused.

- In above Figure 9-1, Bob's query returns stale result => violation of linearizability 

#### What Makes a System Linearizable?

<img src="/resources/images/ddia/Fig-9-2.png" title="Figure 9-2" style="height: 400px; width:800px;"/>
Figure 9-2. If a read request is concurrent with a write request, it may return either the old or the new value.

- In the distributed systems literature, 
    - x is called a register—in practice, means it could be 
    - one key in a key-value store or
    - one row in a relational database or 
    - one document in a document database

- read(x) ⇒ v => client requested value if x and DB returns the value as v
- write(x, v) ⇒ r => client requested to set the register x to value v and 
DB returns response r (which could be ok/success or error)

- In Figure 9-2
    - Any read operations that overlap in time with the write operation might 
    return either 0 or 1
- This is not linearizability
- if reads that are concurrent with a write can return either the old or 
the new value, then readers could see a value flip back and forth between 
the old and the new value several times while a write is going on.
- That is not what we expect of a system that emulates a “single copy of the data"

- To make the system linearizable, we need to add another constraint, 
illustrated in Figure 9-3.

<img src="/resources/images/ddia/Fig-9-3.png" title="Figure 9-3" style="height: 400px; width:800px;"/>
Figure 9-3. After any one read has returned the new value, 
all following reads (on the same or other clients) must also return the new value.

Let' see another example Figure 9-4

<img src="/resources/images/ddia/Fig-9-4.png" title="Figure 9-4" style="height: 400px; width:800px;"/>
Figure 9-4. Visualizing the points in time at which the reads and writes 
appear to have taken effect. The final read by B is not linearizable.

- cas(x, v<sub>old</sub>, v<sub>new</sub>) ⇒ r means 
    - client requested an atomic compare-and-set operation 
    - If the current value of the register x equals v<sub>old</sub>, then
    - it should be atomically set to v<sub>new</sub>
    - If x != v<sub>old</sub>, then the operation should leave the register 
    unchanged and return an error. 
    - r is the database’s response (ok or error).

- Model shown in Figure 9-4 does not assume any transaction isolation
    - means another client may change a value at any time.
- In Figure 9-4
    - The final read by client B (in a shaded bar) is not linearizable
    - client A has already read the new value 4 before B’s read started
    - so B is not allowed to read an older value than A
    - it’s the same situation as with Alice and Bob in Figure 9-1.

##### Linearizability Versus Serializability
- both are quite different guarantees

- Serializability
    - concurrent transactions behave the same as if they had executed 
    in some serial order
    - And It is okay for that serial order to be different from the 
    order in which transactions were actually run
- Linearizability
    - is a recency guarantee on  reads and writes of a register (an individual object).
    - doesn’t group operations together into transactions,
    - so it does not prevent problems such as write skew unless you take 
    additional measures such as materializing conflicts
- DB supporting both Linearizability and Serializability is called as
    - strict serializability or 
    - strong one-copy serializability (strong-1SR)
- serializable snapshot isolation (SSI) is not linearizable
    - bec it makes reads from a consistent snapshot, to avoid lock 
    contention between readers and writers
    - consistent snapshot does not include writes that are more recent than 
    the snapshot
    - thus reads from snapshot are not linearizable.

#### Relying on Linearizability
- Issue described in Figure 9-1 is unlikely to cause any real harm
- However, there a few areas in which linearizability is an important 
requirement for making a system work correctly.

##### Locking and leader election
- In single-leader replication, lock can be used to elect a leader
    - every node on start up tries to acquire the lock
    - and the one that succeeds becomes the leader
- No matter how this lock is implemented, it must be linearizable
    - means all nodes must agree which node owns the lock
- ZooKeeper and etcd are often used to implement distributed locks and leader election
- They use consensus algorithms to implement linearizable operations in a fault-tolerant way
- Apache Curator help by providing higher-level recipes on top of ZooKeeper.
- linearizable storage service is the basic foundation for these coordination tasks.

- Distributed DBs like Oracle Real Application Clusters (RAC), uses Distributed locking
    - RAC uses a lock per disk page, with multiple nodes sharing access 
    to the same disk storage system.

##### Constraints and uniqueness guarantees
- examples where uniqueness guarantees required
    - two clients trying to create username or file with same string/path
    - bank account balance never goes -ve
    - two uses don't concurrently book same seat
- In some situations, you can tolerate few constraint violations
    - like if flight is overbooked, you can move cust to diff flights
    and compensate for inconvenience
    - will see such loosely interpreted constraints in “Timeliness and Integrity”.
- hard uniqueness constraint, typically find in relational databases requires linearizability.
- However, constraints such as  foreign key or attribute constraints, can be implemented without requiring linearizability

##### Cross-channel timing dependencies
- In Figure 9-1, linearizability violation was only noticed because there 
was an additional communication channel in the system (Alice’s voice to Bob’s ears).
- See another example in Figure 9-5

<img src="/resources/images/ddia/Fig-9-5.png" title="Figure 9-5" style="height: 400px; width:800px;"/>
Figure 9-5. The web server and image resizer communicate both through 
file storage and a message queue, opening the potential for race conditions.

- Image resizer may receive the message to resize faster.
- So it might see an old version of the image, or nothing at all.
- This problem arises because there are two different communication channels 
between the web server and the resizer
- If you control the additional communication channel (like in the case 
of the message queue, but not in the case of Alice and Bob), you can use 
alternative approaches similar to what we discussed in 
“Reading Your Own Writes”, at the cost of additional complexity.

#### Implementing Linearizable Systems
- Simple solution is really use single copy of data
    - but this approach is not fault tolerant.
    - what if node holding data crashes or n/w breaks happen?
- Most common approach making a system fault-tolerant is to use replication
- Let's compare whether diff replication methods can be made linearizable

- Single-leader replication (potentially linearizable)
    - If you make reads from the leader, or from synchronously updated followers, 
    they have the potential to be linearizable
    - However, not every single-leader DB is actually linearizable, either 
        - by design (e.g., because it uses snapshot isolation) or 
        - due to concurrency bugs
    - In split brain scenario, if the delusional leader continues to serve 
    requests, it is likely to violate linearizability
    - With asynchronous replication, failover may even lose committed writes 
    (see “Handling Node Outages”), which violates durability and linearizability both

- Consensus algorithms (linearizable)
    - consensus protocols contain measures to prevent split brain and 
    stale replicas. 
    - consensus algorithms can implement linearizable storage safely. 
    - This is how ZooKeeper and etcd work

- Multi-leader replication (not linearizable)
    - bec they concurrently process writes on multiple nodes and asynchronously 
    replicate them to other nodes
    - this can produce conflicting writes that require resolution
    - Such conflics means lack of single copy of data

- Leaderless replication (probably not linearizable)
    - Leaderless replication used by Dynamo-style DBs
    - people claim you can obtain “strong consistency” by requiring quorum 
    reads and writes (w + r > n), but this is not quite true
    - LWW based on time-of-day clocks are almost certainly nonlinearizable bec 
    of clock skew
    - Sloppy quorums also ruin any chance of linearizability.
    - Even with strict quorums, nonlinearizable behavior is possible, see Figure 9-6

##### Linearizability and quorums

<img src="/resources/images/ddia/Fig-9-6.png" title="Figure 9-6" style="height: 400px; width:800px;"/>
Figure 9-6. A nonlinearizable execution, despite using a strict quorum

- when we have variable network delays, it is possible to have nonlinearizable behavior
- Writer writes with n=3 and w=3 configuration
- B’s request begins after A’s request completes, 
- but B returns the old value while A returns the new value. 
- Even though quorum condition (w + r > n) is met
- At cost of reduced performance, it is possible to make Dynamo-style quorums linearizable
    - reader must perform read repair synchronously (see Read repair and anti-entropy)
    - writer must read the latest state of a quorum of nodes before sending its writes
- Riak does not perform synchronous read repair due to the performance penalty 
- Cassandra does wait for read repair to complete on quorum reads 
    - but it loses linearizability if there are multiple concurrent writes 
    to the same key due to LWW conflict resolution
- Moreover, only linearizable read and write operations can be implemented 
in this way; a linearizable compare-and-set operation cannot, because it 
requires a consensus algorithm
- In summary, it is safest to assume that a leaderless system with 
Dynamo-style replication does not provide linearizability.

#### The Cost of Linearizability
Lets explore pros and cons of linearizability in more depth.

<img src="/resources/images/ddia/Fig-9-7.png" title="Figure 9-7" style="height: 400px; width:800px;"/> 
Figure 9-7. A network interruption forcing a choice between 
linearizability and availability.

- multi-leader replication is often a good choice for multi-datacenter replication
- If two DC cut offs due to n/w break, DCs can continue operating normally with multi-leader DB
    - since writes from one datacenter are asynchronously replicated to 
    the other DC, 
    - Writes are simply queued up and exchanged when network connectivity is restored.
- In single leader replication
    - leader must be in one DC
    - Any writes and any linearizable reads must be sent to the leader
    - So clients connected to follower DC, those read and write requests 
    must be sent synchronously over the network to the leader DC
    - Such client can not make any writes/linearizable reads as n/w is broken bet DCs
    - They can make reads from followers, but they can be stale => nonlinearizable

##### The CAP theorem

Unreliable n/w can happen within single DC. So trade-off is as follows

- If application requires linearizability, 
    - they must wait until n/w problem is fixed or return error
    - either way, they become unavailable
- If application does not require linearizability
    - application can remain available even with n/w faults
    - but its behavior is not linearizable
    - such applications can be more tolerant to n/w faults

- CAP was originally proposed as a rule of thumb
    - without precise definitions, 
    - with the goal of starting a discussion about trade-offs in databases.
- At the time, many distributed DBs focused on providing linearizable semantics 
on a cluster of m/cs with shared storage, and CAP encouraged DB engineers 
to explore a wider design space of distributed shared-nothing systems, 
which were more suitable for implementing large-scale web services. 
- CAP deserves credit for this culture shift—witness the explosion of new 
DB technologies since the mid-2000s (known as NoSQL).

###### The Unhelpful CAP Theorem
- CAP is sometimes presented as Consistency, Availability, 
Partition tolerance: pick 2 out of 3. 
- But in distributed systems, you can not opt out P
- So when a network fault occurs, you have to choose between either 
linearizability or total availability
- Thus, a better way of phrasing CAP would be either Consistent or 
Available when Partitioned
- Also, CAP doesn’t say anything about network delays, dead nodes, or 
other trade-offs. 

##### Linearizability and network delays

- RAM on a modern multi-core CPU is not linearizable
    - every CPU core has its own memory cache and store buffer
    - Memory access first goes to the cache by default
    - And any changes are asynchronously written out to main memory
    - since cache is fast, this is required for performance
    - But with several copies of data, linearizability is lost.
        - one in RAM
        - others in several caches (on several CPUs)
- therefore if a thread running on one CPU core writes to a memory address, 
and a thread on another CPU core reads the same address shortly afterward, 
it is not guaranteed to read the value written by the first thread 
(unless a memory barrier or fence is used).
- Within one computer we usually assume reliable communication
- Here, the reason for dropping linearizability is performance, 
not fault tolerance

- Linearizability is slow—and this is true all the time, not only during a 
network fault.

- Can’t we maybe find a more efficient implementation of linearizable storage? 
- It seems the answer is no
- Attiya and Welch prove that if you want linearizability, the response time 
of read and write requests is at least proportional to the uncertainty of 
delays in the network.

- Trade-off is important for latency-sensitive systems.
    - A faster algorithm for linearizability does not exist
    - but weaker consistency models can be much faster

- In Chapter 12 we will discuss some approaches for avoiding linearizability 
without sacrificing correctness.

### Ordering Guarantees
- we saw linearizable register behaves as 
    - there is only single copy of data
    - every operation happens atomically
- It means operations are executed in some well-defined order

- Let’s briefly recap some of the other contexts in which we have discussed ordering:
    - In single-leader replication, replication log maintains order of writes
        - And followers apply those writes in same order
        - If there is no single leader, conflicts can occur due to concurrent 
        operations (see “Handling Write Conflicts”)
    - Serializability
        - ensures concurrent transactions behave as if they were executed in 
        some sequential order.
        - Serializability can be achieved by
            - literally executing transactions in that serial order or
            - allowing concurrent execution while preventing serialization 
            conflicts (by locking or aborting)
    - Timestamps and clocks
        - used to determine which one of two writes happened later.
        - See “Relying on Synchronized Clocks” in Chapter 8
- There is deep connections between ordering, linearizability, and consensus

#### Ordering and Causality
- Ordering reserves Causality. Exmaples we saw earlier
    - In Consistent Prefix Reads
        - There is causal dependency between the question and the answer.
        - However observer of a conversation saw first the answer to a question
        - It violates our intuition of cause and effect
    - In Figure 5-9, 
        - some writes could “overtake” others due to network delays
        - there was an update to a row that did not exist
        - ausality here means that a row must first be created before it can be updated.
    - In “Detecting Concurrent Writes”
        - If A and B are concurrent, there is no causal link between them; 
        - in other words, we are sure that neither knew about the other.
    - In Snapshot Isolation and Repeatable Read
        - Read skew (non-repeatable reads, as illustrated in Figure 7-6) 
        means reading data in a state that violates causality.
    - In Write skew between transactions (see “Write Skew and Phantoms”)
        - Figure 7-8, both Alice and Bob go off call
        - going off call is causally dependent on the observation of who is currently on call.
        - SSI detects write skew by tracking the causal dependencies between transactions.
    - In Figure 9-1
        - Bob got a stale result from the server after hearing Alice exclaim 
        the result is a causality violation

- Causality imposes an ordering on events => cause comes before effect
    - question comes before the answer
    - like in real life, one thing leads to another

- If a system obeys the ordering imposed by causality, we say that it is causally consistent
- For example, snapshot isolation provides causal consistency:
    - when you read from the DB, and you see some piece of data, then you must 
    also be able to see any data that causally precedes it (assuming it has 
    not been deleted in the meantime).

##### The causal order is not a total order
- Total Order means
    - it allows any two elements to be compared
    - which one is greater and which one is smaller
    - e.g. natural numbers are totally ordered.
    - if I give you any two numbers, say 5 and 13, you can tell me that 13 is greater than 5
    - However, mathematical sets are not totally ordered
        - is {a, b} greater than {b, c}?
        - There are incomparable or partially ordered

- The difference between a total order and a partial order is reflected in 
different DB consistency models
    - Linearizability
        - If system is linearizable then we can always say which operation happened first
    - Causality
        - Two operations are concurrent if neither happened before the other
        - see  “The “happens-before” relationship and concurrency"
        - two events are ordered if they are causally related (one happened before the other), 
        - but they are incomparable if they are concurrent.
        - This means that causality defines a partial order, not a total order:
        - some operations are ordered with respect to each other, but some are incomparable.
- Therefore, according to this definition, there are no concurrent operations 
in a linearizable datastore

- Figure 5-14 
    - is not a straight-line total order
    - but rather a jumble of different operations going on concurrently. 
    - The arrows in the diagram indicate causal dependencies—the partial 
    ordering of operations.
- In GIT, version histories are very much like the graph of causal dependencies

##### Linearizability is stronger than causal consistency
- linearizability implies causality: any system that is linearizable will preserve causality correctly
- linearizable systems are easy to understand and appealing, but harms the system performance
- For this reason, some distributed data systems have abandoned linearizability, 
which allows them to achieve better performance but can make them difficult to work with.
- The good news is that a middle ground is possible. 
    - There are other ways to preserve causality
    - E.g. causal consistency is the strongest possible consistency model 
    that does not slow down due to network delays, and remains available in 
    the face of network failures
- In many cases, systems that appear to require linearizability in fact only 
really require causal consistency, which can be implemented more efficiently.

##### Capturing causal dependencies
- We won’t go into all the nitty-gritty details of how nonlinearizable 
systems can maintain causal consistency, but let's see some key ideas

- The techniques for determining which operation happened before which other 
operation are similar to what we discussed in “Detecting Concurrent Writes”.
- Causal consistency needs to track causal dependencies across the entire DB, 
not just for a single key. Version vectors can be generalized to do this

#### Sequence Number Ordering
- keeping track of all causal dependencies can become impracticable
    - clients read lots of data before writing something
    - it is not clear whether the write is causally dependent on all or only 
    some of those prior reads
    - tracking all read data is quite large overhead
- better way => use sequence numbers or timestamps to order events.
- we can create sequence numbers in a total order that is consistent with causality. 
- we promise that if operation A causally happened before B, then A occurs 
before B in the total order
- A has a lower sequence number than B

- In single-leader replication, replication log defines a total order of 
write operations that is consistent with causality
- If follower applies writes in that order, then follower is always causally consistent

##### Noncausal sequence number generators
- In multi-leader or leaderless database, it is less clear how to generate sequence 
numbers for operations.  
- Various methods are used in practice
    - In sequence number object, reserve some bits for unique node identifier
    - If timestamps have sufficiently high resolution, then they might be sufficient to totally order operations.
        - This fact is used in LWW conflict resolution method
    - Preallocate blocks of sequence numbers. Say Node A uses 1-1000 and Node B uses 1001-2000
- Above three options all perform better and are more scalable
- However, they all have a problem 
    - The sequence numbers they generate are not consistent with causality.
    - sequence number generated do not correctly capture the ordering of 
    operations across different nodes

##### Lamport timestamps
- is a simple method for generating sequence numbers that is consistent with causality
- proposed in 1978 by Leslie Lamport

<img src="/resources/images/ddia/Fig-9-8.png" title="Figure 9-8" style="height: 400px; width:800px;"/> 
Figure 9-8. Lamport timestamps provide a total ordering consistent with causality.

- The Lamport timestamp is then simply a pair of (counter, node ID).
- As long as the maximum counter value is carried along with every operation, 
this scheme ensures that the ordering from the Lamport timestamps is consistent 
with causality, because every causal dependency results in an increased timestamp.

- Lamport timestamps are sometimes confused with version vectors
- Although there are some similarities, they have a different purpose
- version vectors can 
    - distinguish whether two operations are concurrent or 
    - whether one is causally dependent on the other
- Lamport timestamps 
    - always enforce a total ordering
    - But you cannot tell whether two operations are concurrent or 
    whether they are causally dependent.
    - The advantage of Lamport timestamps over version vectors is that they are more compact.

##### Timestamp ordering is not sufficient
- Lamport timestamps is not quite sufficient to solve many common problems in distributed systems
- E.g. system that needs to ensure that a username uniquely identifies a user account.
- To conclude
    - in order to implement something like a uniqueness constraint for usernames, 
    it’s not sufficient to have a total ordering of operations
    - you also need to know when that order is finalized. 
    - If you have an operation to create a username, and you are sure that no 
    other node can insert a claim for the same username ahead of your 
    operation in the total order, then you can safely declare the operation successful.

- This idea of knowing when your total order is finalized is captured in the 
topic of total order broadcast.

#### Total Order Broadcast
- In single CPU core, it is easy to define a total ordering of operations
- But in distributed systems, getting all nodes to agree on the same total 
ordering of operations is tricky.
- single-leader replication
    - determines a total order of operations by choosing one node as the leader and 
    - sequencing all operations on a single CPU core on the leader
- Challenge is how to scale system if throughput is greater than a single leader can handle
- Also, how to handle failover if the leader fails (see “Handling Node Outages”)
- In the distributed systems literature, this problem is known as total order 
broadcast or atomic broadcast

- Total Order Broadcast is usually described as a protocol for exchanging messages between nodes.
- It requires that two safety properties always 
    1. Reliable delivery
        - No messages are lost
        - if a message is delivered to one node, it is delivered to all nodes.
    2. Totally ordered delivery
        - Messages are delivered to every node in the same order.

- A correct algorithm for total order broadcast must ensure that the 
reliability and ordering properties are always satisfied, even if a node or 
the network is faulty.

##### Using total order broadcast
- Consensus services such as ZooKeeper and etcd actually implement total order broadcast.
- Means there is a strong connection between total order broadcast and consensus

- Total order broadcast can be used to implement serializable transactions 
(See “Actual Serial Execution”)
- Total order broadcast is also useful for implementing a lock service that 
provides fencing tokens (see “Fencing tokens”)
    - Every request to acquire the lock is appended as a message to the log, 
    - and all messages are sequentially numbered in the order they appear in the log. 
    - The sequence number can then serve as a fencing token, because it is 
    monotonically increasing. 
    - In ZooKeeper, this sequence number is called zxid

##### Implementing linearizable storage using total order broadcast
- Is linearizability the same as total order broadcast? Not quite
- Total order broadcast is asynchronous
    - messages are guaranteed to be delivered reliably in a fixed order, 
    - but there is no guarantee about when a message will be delivered 
    (so one recipient may lag behind the others)
- By contrast, linearizability is a recency guarantee
    - a read is guaranteed to see the latest value written.
- However, if you have total order broadcast, you can build linearizable 
storage on top of it. 
    - For example, you can ensure that usernames uniquely identify user accounts.

##### Implementing total order broadcast using linearizable storage
- In general, if you think hard enough about linearizable sequence number 
generators, you inevitably end up with a consensus algorithm
- It can be proved that a linearizable compare-and-set (or increment-and-get) 
register and total order broadcast are both equivalent to consensus


### Distributed Transactions and Consensus
- Consensus goal is to get several nodes to agree on something
- Number of situations in which it is important for nodes to agree. 
    - Leader Election
        - single-leader replication, all nodes should agree on which node is a leader
        - to avoid issues like bad failover and split brain situations
        - If 2 nodes assumes leadership then both accepts writes and
            - data would diverge leading to 
            - inconsistent and data loss
    - Atomic commit
        - transactions spanning several nodes or partitions, some transactions 
        may fail, some succeeds
        - To maintain transaction atomicity, all transactions must either 
        fail/abort or succeed on all nodes
        - This instance of consensus is known as the atomic commit problem
#### Atomic Commit and Two-Phase Commit (2PC)
- 2PC is most common way of solving atomic commit
- Implemented in various DBs, messaging systems and application servers
- 2PC is a kind of consensus algorithm—but not a very good one
- By learning from 2PC we will then work our way toward better consensus 
algorithms, such as those used in ZooKeeper (Zab) and etcd (Raft).

- Atomicity prevents failed transactions from littering the database with 
half-finished results and half-updated state. 
- This is imp for multi-object transactions and DBs maintaining secondary indexes

##### From single-node to distributed atomic commit
- transactions executed at a single DB node, atomicity is commonly implemented 
by the storage engine. 
- DB makes transaction's write durable using WAL and then appends commit record
- Once commit record written successfully, transaction is considered committed
- Thus, on a single node, transaction commitment crucially depends on the 
order in which data is durably written to disk
    - first the data, and 
    - then the commit record
- Thus, it is a single device (the controller of one particular disk drive, 
attached to one particular node) that makes the commit atomic.
- what if multiple nodes are involved in a transaction?
- Say you have multi-object transaction in a partitioned database, or a 
term-partitioned secondary index
- it is not sufficient to simply send a commit request to all of the nodes 
and independently commit the transaction on each one. 
- Reasons being only some nodes commit transactions, but
    - Some nodes may detect a constraint violation or conflict, aborts transaction
    - Some of the commit requests might be lost in the network, eventually 
    aborting due to a timeout
    - Some nodes may crash before the commit record is fully written and 
    roll back on recovery

- If any of the above happens, node and data becomes inconsistent.
- Also, it is not possible to rollback/retracted committed transaction
- Thumb Rules is A transaction commit must be irrevocable
    - means not allow to abort once committed
-  Reason for above rule is
    - once transaction is committed, it becomes visible to other transactions
    - other clients may start relying on that data

##### Introduction to two-phase commit
- is an algorithm for achieving atomic transaction commit across multiple nodes
- either all nodes commit or all nodes abort
- 2PC is made available to applications as well in form of XA transactions
    - supported by Java Transaction API or
    - via WS-AtomicTransaction for SOAP web services
- In 2PC, commit and abort process are split into two phases (hence the name)

<img src="/resources/images/ddia/Fig-9-9.png" title="Figure 9-9" style="height: 400px; width:800px;"/>
Figure 9-9. A successful execution of two-phase commit (2PC).

- Btw 2PC and 2PL are completely difference
    - 2PL provides serializable isolation.
    - 2PC provides atomic commit in a distributed DB

- 2PC uses new component => coordinator aka ransaction manager
- coordinator is often implemented as a library within the same application 
process that is requesting the transaction (e.g., embedded in a Java EE container)
- It can be separate process or service as well. E.g
    - Narayana, JOTM, BTM, or MSDTC.
- When the application is ready to commit, the coordinator begins phase 1
- It sends prepare requests to each node asking if they are ready to commit
- The coordinator then tracks the responses from the participants:
    - If all participants reply “yes,” indicating they are ready to commit, 
    then the coordinator sends out a commit request in phase 2, and the 
    commit actually takes place.
    - If any of the participants replies “no,” the coordinator sends an 
    abort request to all nodes in phase 2.

- Above process is somewhat like the traditional marriage ceremony in Western cultures

##### A system of promises
- Why two-phase commit ensures atomicity, while one-phase commit across several nodes does not
- What makes 2PC different?
    1. When application want ot begin a distributed transaction, it requests a 
    transaction ID from the coordinator. This transaction ID is globally unique.
    2. The application begins a single-node transaction on each of the 
    participants with globally unique transaction ID
    3. When the application is ready to commit, the coordinator sends a 
    prepare request to all participants
    4. When a participant receives the prepare request, it makes sure that it 
    can definitely commit the transaction under all circumstances
    5. On responses from partitcipants, coordinator decides either commit or abort. 
    Coordinator must must write that decision to its transaction log on disk. This
    is called the commit point
    6. After that, coordinator sends commit or abort msg to all participants. 
    If this request fails or times out, the coordinator must retry forever 
    until it succeeds. There is no more going back. The decision must be 
    enforced, no matter how many retries it takes

- Thus, the protocol contains two crucial “points of no return”
    - when a participant votes “yes,” it promises that it will definitely be 
    able to commit later
    - once the coordinator decides, that decision is irrevocable
    - Above two promises ensure the atomicity of 2PC.
- Single-node atomic commit lumps above two events into one: 
    - writing the commit record to the transaction log.

##### Coordinator failure
- In 2PC,
    - if any of the prepare requests fail or time out, the coordinator aborts the transaction
    - if any of the commit or abort requests fail, the coordinator retries them indefinitely
- Let's see how Coordinator failure is handle

<img src="/resources/images/ddia/Fig-9-10.png" title="Figure 9-10" style="height: 400px; width:800px;"/> 
Figure 9-10. The coordinator crashes after participants vote “yes.” 
Database 1 does not know whether to commit or abort.

- If the coordinator crashes or the network fails, the participant can do 
nothing but wait. A participant’s transaction in this state is 
called in-doubt or uncertain transaction.
- if DB 1 unilaterally aborts after a timeout, it will end up inconsistent 
with DB 2, which has committed. 
- Similarly, it is not safe to unilaterally commit, because another participant 
may have aborted.
- In principle, the participants could communicate among themselves to find 
out how each participant voted and come to some agreement, but that is not 
part of the 2PC protocol.
- The only way 2PC can complete is by waiting for the coordinator to recover. 

##### Three-phase commit
- Two-phase commit is called a blocking atomic commit protocol due to the 
fact that 2PC can become stuck waiting for the coordinator to recover.
- As an alternative to 2PC, 3PC is proposed.
- However, 3PC assumes a network with bounded delay and nodes with bounded response times
- But most systems with unbounded n/w delay and process pauses, 3PC cannot guarantee atomicity.

- In general, nonblocking atomic commit requires a perfect failure detector 
- In a network with unbounded delay a timeout is not a reliable failure detector
- Therefore 2PC continues to be used, despite the known problem with coordinator failure

#### Distributed Transactions in Practice
- 2PC is criticized for causing operational problems, killing performance, 
and promising more than they can deliver 
- So many cloud services choose not to implement distributed transactions due 
to the operational problems
- distributed transactions in MySQL are reported to be over 10 times slower 
than single-node transactions
- 2 PC requires additional disk forcing (fsync), required for crash recovery, 
and the additional network round-trips.

- But before we discard Distributed Transactions, let's be precise about what 
we mean by “distributed transactions.”
- Two quite different types of distributed transactions are often conflated:

1. Database-internal distributed transactions
    - Some distributed DBs support internal transactions among the nodes of that database
    - E.g VoltDB and MySQL Cluster’s NDB storage engine have such internal transaction support
    - In this case, all the nodes participating in the transaction are running 
    the same database software. 

2. Heterogeneous distributed transactions
    - participants are two or more different technologies
    - E.g. two databases from different vendors, or even non-database systems 
    such as message brokers.
    - A distributed transaction across these systems must ensure atomic commit, 
    even though the systems may be entirely different under the hood.

- database-internal distributed transactions can often work quite well. 
- transactions spanning heterogeneous technologies are a lot more challenging.

##### Exactly-once message processing
- A message queue can be acknowledged as processed if and only if the 
DB transaction for processing the message was successfully committed

- We will return to the topic of exactly-once message processing in Chapter 11.
- Let’s look first at the atomic commit protocol that allows such 
heterogeneous distributed transactions.

##### XA transactions
- X/Open XA (short for eXtended Architecture) 
- is a standard for implementing two-phase commit across heterogeneous technologies
- supported by 
    - many traditional relational databases and 
        - PostgreSQL, MySQL, DB2, SQL Server, and Oracle
    - message brokers 
        -ActiveMQ, HornetQ, MSMQ, and IBM MQ
- XA is not a network protocol—it is merely a C API for interfacing with a transaction coordinator. 
- Bindings in other languages are available too
    - Java Transaction API (JTA) implements XA transaction
    - many drivers for DBs using Java Database Connectivity (JDBC) and
    - drivers for message brokers using the Java Message Service (JMS) APIs.
- XA assumes that your application uses a network driver or client library to 
communicate with the participant databases or messaging services
- The driver also exposes callbacks through which the coordinator can ask the 
participant to prepare, commit, or abort.
- The transaction coordinator implements the XA API.

##### Holding locks while in doubt
- Why do we care so much about a transaction being stuck in doubt?
- Can't system ignore the in-doubt transaction?
- The problem is with locking.
- The database cannot release those locks until the transaction commits or 
aborts (illustrated as a shaded area in Figure 9-9).
- Therefore, when using two-phase commit, a transaction must hold onto the 
locks throughout the time it is in doubt. 
- While those locks are held, no other transaction can modify those rows
- This can cause large parts of your application to become unavailable until 
the in-doubt transaction is resolved.

##### Recovering from coordinator failure
- In practice, orphaned in-doubt transactions do occur 
- These transactions cannot be resolved automatically, so they sit forever 
in the DB, holding locks and blocking other transactions.
- The only way out is for an administrator to manually decide whether to 
commit or roll back the transactions. 
- However, above requirs lot of manual efforts done under high stress to resolve production outage
- Therefore, Many XA implementations have an emergency escape hatch called heuristic decisions
    - participants unilaterally decide to abort or commit an in-doubt 
    transaction without a definitive decision from the coordinator
    - heuristic decision may violate the system of promises in two-phase commit.
    - Thus, heuristic decisions are intended only for getting out of catastrophic 
    situations, and not for regular use.

##### Limitations of distributed transactions
- XA transactions solve the real and important problem of keeping several 
participant data systems consistent with each other,
- But they introduce major operational problems.
- Key realization is that the transaction coordinator is itself a kind of DB
- So it needs to be approached with the same care as any other DBs

1. If coordinator is not replicated, becomes single point of failure
2. Many server-side applications are developed in a stateless model (as favored by HTTP), 
with all persistent state stored in a database. But when coordinator is part 
of the application server, it changes the nature of the deployment
3. Since XA needs to be compatible with a wide range of data systems, 
it is necessarily a lowest common denominator.
    - It cannot detect deadlocks across different systems
    - It does not work with SSI (requirs identifying conflicts across different systems.)
4. Distributed transactions thus have a tendency of amplifying failures

- So should we give up all hope of keeping several systems consistent?
- In Chapter 11 and 12, we will see alternative methods that allow us to 
achieve the same thing without the pain of heterogeneous distributed transactions

#### Fault-Tolerant Consensus
- consensus means getting several nodes to agree on something
- if several people concurrently try to do one/same thing, consensus algorithm could be used.
    - book last seat on an airplane, or 
    - the same seat in a theater

- Consensus algorithm must satisfy the following properties
    - Uniform agreement
        - No two nodes decide differently.
    - Integrity
        - No node decides twice.
    - Validity
        - If a node decides value v, then v was proposed by some node.
        - validity property exists mostly to rule out trivial solutions
            - E.g. you could have an algorithm that always decides null, 
            no matter what was proposed by other nodes
    - Termination
        - Every node that does not crash eventually decides some value.
        - formalizes the idea of fault tolerance
        - Means consensus algorithm cannot simply sit around and do nothing forever
        - Means it must makes prgress

- Termination is a liveness property, whereas the other three are 
safety properties (see “Safety and liveness” from Chapter 8)
- it can be proved that any consensus algorithm requires at least a majority 
of nodes to be functioning correctly in order to assure termination. 
That majority can safely form a quorum (see “Quorums for reading and writing”).
- Most consensus algorithms assume that there are no Byzantine faults

#### Consensus algorithms and total order broadcast
- The best-known fault-tolerant consensus algorithms are 
    - Viewstamped Replication (VSR) 
    - Paxos
    - Raft
    - Zab
- In this book, will not go in much details of this algos, but will see high level ideas
- Consensus algorithms works based on the principe of total order broadcast
- Remember that total order broadcast requires messages to be delivered 
exactly once, in the same order, to all nodes
- This is equivalent to performing several rounds of consensus
- So total order broadcast is equivalent to repeated rounds of consensus 
- Viewstamped Replication, Raft, and Zab implement total order broadcast directly, 
because that is more efficient than doing repeated rounds of one-value-at-a-time consensus. 
- In the case of Paxos, this optimization is known as Multi-Paxos.

##### Single-leader replication and consensus
- If the leader is manually chosen, then  you essentially have a 
“consensus algorithm” of the dictatorial variety
    - If leader goes down, it is required to manually select new leader
    - This does not satisfy the termination property of consensus because it 
    requires human intervention in order to make progress.
- Some DB perform automatic leader election and failover, promoting a follower 
to be the new leader if the old leader fails (see “Handling Node Outages”). 
This brings us closer to fault-tolerant total order broadcast, and thus to solving consensus.

- But there are issues like split brain.
- Thus, we need consensus in order to elect a leader.
- But consensus algo described here is actually total order broadcast
- And otal order broadcast is like single-leader replication, and single-leader 
replication requires a leader, then…
- It seems that in order to elect a leader, we first need a leader. In order 
to solve consensus, we must first solve consensus. How do we break out of 
this conundrum?

##### Epoch numbering and quorums
- Here, we have two rounds of voting: once to choose a leader, and a second 
time to vote on a leader’s proposal.

##### Limitations of consensus
- consensus algo bring concrete safety properties (agreement, integrity, and 
validity) to systems where everything else is uncertain.
- They provide total order broadcast, and therefore they can also implement 
linearizable atomic operations in a fault-tolerant way (see “Implementing 
linearizable storage using total order broadcast”).
- But they are not used everywhere, because the benefits come at a cost 
- The process by which nodes vote on proposals before they are decided is a 
kind of synchronous replication
- As discussed, DBs are often configured with asynchronous replication.
    - With this, some committed data can potentially be lost on failover
    - But many people choose to accept this risk for the sake of better performance.
- Consensus systems always require a strict majority to operate
    - Means three nodes required in order to tolerate one failure
    - Five nodes required in order to tolerate two nodes failure

- Most consensus algorithms assume a fixed set of nodes that participate in voting
    - means that you can’t just add or remove nodes in the cluster.
    - Dynamic membership extensions to consensus algorithms exists, but it 
    is much less well understood than static membership algos
- Consensus systems generally rely on timeouts to detect failed nodes.
    - In environments with highly variable network delays, especially 
    geographically distributed systems, it often happens that a node falsely 
    believes the leader to have failed due to a transient network issue.
    - Although this error does not harm the safety properties, frequent 
    leader elections result in terrible performance
- Sometimes, consensus algorithms are particularly sensitive to network problems
- designing consensus algorithm that are more robust to unreliable networks is 
still an open research problem.

#### Membership and Coordination Services
- Projects like ZooKeeper or etcd are often described as “distributed key-value 
stores” or “coordination and configuration services.” 
- APIs they provide looks much like a DB Service
- But they are not DBs. So what makes them different from any other kind of DB?

- To understand, first let's briefly explore how a service like ZooKeeper is used. 
    - Application developer does not directly use ZooKeeper, but uses it indirectly
    - HBase, Hadoop YARN, OpenStack Nova, and Kafka all rely on ZooKeeper 
    running in the background
- ZooKeeper and etcd are designed to hold small amounts of data that can fit 
entirely in memory 
    -  small amount of data is replicated across all the nodes using a 
    fault-tolerant total order broadcast algorithm
- ZooKeeper is modeled after Google’s Chubby lock service, implemented many features 
apart from  total order broadcast (and hence consensus)
    - Linearizable atomic operations
        - The consensus protocol guarantees that the operation will be atomic 
        and linearizable, even if a node fails or the network is interrupted 
        at any point
        - distributed lock is usually implemented as a lease, which has an 
        expiry time so that it is eventually released in case the client 
        fails (see “Process Pauses” in Chapter 8).
    - Total ordering of operations
        - Here, fencing tokens are used to prevent clients from conflicting 
        with each other in the case of a process pause. (see "The leader and the lock”)
    - Failure detection
        - Clients maintain a long-lived session on ZooKeeper servers, w/ heartbeats
        - So temporary n/w break r ZooKeeper node failuire does not terminate session
        - However, if the heartbeats cease for a duration that is longer 
        than the session timeout, ZooKeeper declares the session to be dead.
        - Locks held by session are released once session times out
        - ZooKeeper calls these ephemeral nodes
    - Change notifications
        - Client can watch read locks and valuescreated by another Clients
        - So client can find out if another client joins or leaves cluster
        - Subscription mechanism used t avoid frequent polling

- Of these features, only the linearizable atomic operations really require 
consensus.

##### Allocating work to nodes
- Apart from electing leader in single-leader DBs, ZooKeeper/Chubby model well in 
other uses cases as well E.g Job scheduler
- Another example
    - when you have some partitioned resource (database, message streams, 
    file storage, distributed actor system, etc.) 
    - When a node fails or new node joines, it is needed to decide which 
    partition to assign to which node
- These kinds of tasks can be achieved by judicious use of atomic operations, 
ephemeral nodes, and notifications in ZooKeeper.

- Normally, the kind of data managed by ZooKeeper is quite slow-changing
- ZooKeeper is not intended for storing the runtime state of the application, 
which may change thousands or even millions of times per second.

##### Service discovery
- ZooKeeper, etcd, and Consul are also often used for service discovery
- When the nodes providing the service are start up, they register their network 
endpoints in a service registry
- However, it is less clear whether service discovery actually requires consensus. 
- DNS is the traditional way of looking up the IP address for a service name, 
and it uses multiple layers of caching to achieve good performance and availability.
- Reads from DNS are absolutely not linearizable,
- Stale results returned by DNS are generally not problematic
- It is more important that DNS is reliably available and robust to 
network interruptions.
- Although service discovery does not require consensus, leader election does

##### Membership services
- ZooKeeper and friends can be seen as part of a long history of research 
into membership services, which goes back to the 1980s and has been important 
for building highly reliable systems, e.g., for air traffic control

### Summary
- We saw that achieving consensus means deciding something in such a way that 
all nodes agree on what was decided, and such that the decision is irrevocable.
- It turns out that a wide range of problems are actually reducible to 
consensus and are equivalent to each other
- In the sense that if you have a solution for one of them, you can easily 
transform it into a solution for one of the others. 
- Such equivalent problems include:
    - Linearizable compare-and-set register
        - The register needs to atomically decide whether to set its value, 
        based on whether its current value equals the parameter given in 
        the operation.
    - Atomic transaction commit
        - A database must decide whether to commit or abort a distributed 
        transaction.
    - Total order broadcast
        - The messaging system must decide on the order in which to deliver 
        messages.
    - Locks and leases
        - When several clients are racing to grab a lock or lease, the lock 
        decides which one successfully acquired it.
    - Membership/coordination service
        - Given a failure detector (e.g., timeouts), the system must decide 
        which nodes are alive, and which should be considered dead 
        because their sessions timed out.
    - Uniqueness constraint
        - When several transactions concurrently try to create conflicting 
        records with the same key, the constraint must decide which one to 
        allow and which should fail with a constraint violation.

- A single-leader database can provide linearizability without executing a 
consensus algorithm on every write, it still requires consensus to 
maintain its leadership and for leadership changes.

- Tools like ZooKeeper play an important role in providing an “outsourced” 
consensus, failure detection, and membership service that applications can use.

- Not every system necessarily requires consensus: for example, leaderless 
and multi-leader replication systems typically do not use global consensus.
- Conflicts can occur (See “Handling Write Conflicts”). 
- In this case, we simply need to cope without linearizability and learn 
to work better with data that has branching and merging version histories.

# Part III: Derived Data
- No single DB can satify today's different needs simulataneously.
- So Apps generally use combination of several different datastores, indexes, 
caches, analytics systems, etc
- So data moved from one store to another
- In this part, we will examine the issues around integrating multiple 
different data systems, potentially with different data models and optimized 
for different access patterns, into one coherent application architecture
- Integrating disparate systems is one of the most important things that needs 
to be done in a nontrivial application.

## Systems of Record and Derived Data
### Systems of Record
- aka source of truth
- holds the authoritative version of your data.
- Each fact is represented exactly once
- In case of discrepancies, value in system of record (by definition) is the correct one.
### Derived Data
- Data in a derived system is result of taking some existing data from another system and transforming or processing it in some way
- If you lose derived data, you can recreate it from the original source
- Classic example is cache.
- Denormalized values, indexes, and materialized views also fall in this category
- In recommendation systems, predictive summary data is often derived from usage logs.
- Derived data is redundant and denormalized. This is often essential for getting good performance on read queries.
- Several different datasets from a single source enables to look at the data from 
different “points of view.”

### Note
- Most databases, storage engines, and query languages are not inherently 
either a system of record or a derived system. 
- A database is just a tool
- How you use it is up to you. 
- The distinction between system of record and derived data system depends not 
on the tool, but on how you use it in your application.

## Chapter 11 Stream Processing
```
A complex system that works is invariably found to have evolved from a simple system that works. 
The inverse proposition also appears to be true: 
A complex system designed from scratch never works and cannot be made to work.

John Gall, Systemantics (1975)
```

- We studied batch processing in Chatper 10. 
- Big assumption was - input is bounded
- so the batch process knows when it has finished reading its input. 
- In batch processing, starting output early is not an options
    - say your are sorting keys
    - lowest key happened to be very last input

- But in reality, a lot of data is unbounded because it arrives gradually over time
- Using batch processing, we can process the data in specific window duration
- For Example, every days data
- We can reduce this window, say per every minute or may be more granular
- Or we can do porcessing continuously, abandoning the fixed time slices entirely 
and simply processing every event as it happens.
That is the idea behind stream processing. 

### Transmitting Event Streams
- event means
    - small, self-contained, immutable object 
    - contains the details of something that happened at some point in time
- An event usually contains a timestamp indicating when it happened according 
to a time-of-day clock
- An event may be encoded as a text string, or JSON, or perhaps in some 
binary form (AVRO, Protobuf, etc)
- An event is generated by producer and potentially processed by multiple consumers
- In a streaming system, related events are usually grouped together into 
a topic or stream
- In principle, a file or database is sufficient to connect producers and consumers
- However, file/DB is not designed for streaming user case
    - Consumer requires to poll for events, if any
    - The more often you poll, the lower the percentage of requests that return 
    new events, and thus the higher the overheads become.
        - Say you poll 10 times.
        - It generally happens that new event is returned in 2 polls only
        - In 8 polls, no new event is returned
        - Means 20% poll yields new events
        - As you poll more, this percentage goes down even more
    - Instead, it is better for consumers to be notified when new events appear.
- DBs do not support such kind of notifications natively.
- Triggers is one option (which can react to a change), but there are limits you can do with triggers

#### Messaging Systems
- Simplest way to implement Messaging Systems => Unix pipe or TCP socket
- But Unix pipe or TCP connects exactly one sender with one recipient
- Whereas a messaging system allows multiple producer nodes to send messages 
to the same topic and allows multiple consumer nodes to receive messages in a topic.
- Within this publish/subscribe model, different systems take a wide range of approaches.
- To differentiate the systems, it is particularly helpful to ask the following 
two questions
    - What happens if the producers send messages faster than the consumers can 
    process them? Broadly, there are three options
        - Drop message
        - Queue message
            - imp to understand what happens if Q grows
            - does it write to disk?
            - performance implications bec of disk access
        - backpressure. aka flow control => Unix pipe and TCP uses this
    - What happens if nodes crash or temporarily go offline?
        - are any messages lost?
        - Similar to DB, durability may require some combination of writing to 
        disk and/or replication which has a cost
        - if you afford to sometimes lose messages, you can probably get 
        higher throughput and lower latency on the same hardware.

##### Direct messaging from producers to consumers
Produce and consumer communicate w/o going via intermediary nodes.
- UDP multicast
    - used in the financial industry for streams such as stock market feeds
    - low latency is important
    - Since UDP is unrelible, application protocol can recover lost packets
    - Producer should support restranmitting packets on demand
- Brokerless messaging libraries such as ZeroMQ and nanomsg
    - Implements publish/subscribe messaging over TCP or IP multicast.
- StatsD and Brubeck use unreliable UDP messaging for collecting metrics
- If the consumer exposes a service on the network, producers can make a direct 
HTTP or RPC request

- In above direct messaging systems, applications need to aware of possible 
message loss
- Therefore the faults they can tolerate are quite limited
- Even if the protocols detect and retransmit packets that are lost in the 
network, they generally assume that producers and consumers are constantly online

##### Message brokers 
- aka message Qs
- are a kind of DBs optimized for handling message streams.
- By centralizing the data in the broker, these systems can more easily tolerate 
clients that come and go (connect, disconnect, and crash),
- durability resopnsibility is moved to broker
- To help slow consumers, Message brokers generally allow unbounded queueing
- A consequence of queueing is also that consumers are generally asynchronous
    - producer only waits broker to ack the message
    - producer does not wait till consumer consumes the message

##### Message brokers Vs DBs
Some message brokers can even participate in two-phase commit protocols using XA or JTA.
This is something similar in nature to DB.
However, there are still important practical differences between message brokers and databases

- DBs keep the data until it is explicitly deleted, whereas most message brokers
delete the data as soon as it is delivered to consumer
- message brokers assumes their working set is fairly small => Qs are short
    - If they need to persist/buffer data bec the consumers are slow then
        - each individual message may take longer time to process
        - overall throughput may degrade
- Databases often support secondary indexes and various ways of searching for data, 
while message brokers often support some way of subscribing to a subset of topics 
matching some pattern
- DBs support arbitrary queries, while message brokers don't. But they do notify 
clients when data changes (i.e., when new messages become available).

- This is traditional view of message brokers 
    - encapsulated in standards like JMS [14] and AMQP [15] 
    - and implemented in software like 
        - RabbitMQ, ActiveMQ, HornetQ, Qpid, 
        - TIBCO Enterprise Message Service, 
        - IBM MQ, Azure Service Bus, and Google Cloud Pub/Sub

##### Multiple consumers

<img src="/resources/images/ddia/Fig-11-1.png" title="Figure 11-1" style="height: 400px; width:800px;"/>
Figure 11-1. (a) Load balancing: sharing the work of consuming a topic among 
consumers; (b) fan-out: delivering each message to multiple consumers.

- When multiple consumers read messages in the same topic, two main patterns of messaging are used, as illustrated in Figure 11-1
    - Load balancing
        - Each message is delivered to one of the consumers
        - consumers can share the work of processing the messages in the topic.
        - In AMQP, you can implement load balancing by having multiple clients 
        consuming from the same queue
        - and in JMS it is called a shared subscription.
    - Fan-out
        - Each message is delivered to all of the consumers
        - This feature is provided by topic subscriptions in JMS, and exchange 
        bindings in AMQP.
- The two patterns can be combined
    - two separate groups of consumers may each subscribe to a topic
    - such that each group collectively receives all messages
    - but within each group only one of the nodes receives each message

##### Acknowledgments and redelivery
- What is Consumers crash in bet processing of message?
- broker delivers the message to consumer, but it fails to process it
- To address above, message brokers use acknowledgments
- On receiving acks from client, message brokers deletes the message
- On n/w connection failure or timeout, message brokers assume message was not 
processed and delivers it again
    - it could happen that the message actually was fully processed
    - but the ack was lost in the network
    - Handling this case requires an atomic commit protocol,
    - See "Distributed Transactions in Practice"
- When combined with load balancing, this redelivery behavior has an interesting 
effect on the ordering of messages. See Figure 11-2

<img src="/resources/images/ddia/Fig-11-2.png" title="Figure 11-2" style="height: 400px; width:800px;"/>
Figure 11-2. Consumer 2 crashes while processing m3, so it is redelivered to consumer 1 at a later time.

- Bec the consumer 2 crashed bef sending ack to ```m3```, broker delivers it to consumer 1.
- consumer 1 processes messages in the order ```m4```, ```m3```, ```m5```
- The above overder is not the same as that producer that produced.
- Even if the JMS and AMQP standards mandates broker to preserve order of messages,
the combination of load balancing with redelivery inevitably leads to messages 
being reordered
- To avoid above issues, you can use a separate queue per consumer => no LB
- But this requires messages to be independent of each other
- Hwoever, this will not work if there are causal dependencies between messages 

#### Partitioned Logs
- Messages brokers are buit around transient messaging mindset
    - even if they durably write messages to disk quickly delete them again 
    after they have been delivered to consumers
- DB/File systems take opposite approach
    - They keep the data until someone deletes them explicitely
- In Batch Processing
    - It never touches the input data
    - So you can run batch processing repeatedly.
- Messages brokers takes destructive approach to delete the messages
- If you add new consumer, they receives new messages after they have been registered
    - they can not process old messages
- Why can we not have a hybrid approach?
    - combining the durable storage approach of databases and
    - low-latency notification facilities of messaging? 
    - This is the idea behind log-based message brokers

##### Using logs for message storage
- A log is simply an append-only sequence of records on disk. 
- We previously discussed logs in the context of 
    - log-structured storage engines and write-ahead logs in Chapter 3,
    - replication in Chapter 5.
- The same structure can be used to implement a message broker
    - producer's messages are appended to the log
    - consumer receives messages by reading log sequentially
    - When consumer reaches end of log, it waits for new message notification
    - Unix tool ```tail -f``` works on similar principle
- In order to scale to higher throughput than a single disk can offer, the log 
can be partitioned
    - Different partitions can then be hosted on different machines
    - each partition becomes a separate log that can be read and written 
    independently from other partitions
    - A topic can then be defined as a group of partitions that all carry 
    messages of the same type.
- Figure 11-3 illustrates above approach

<img src="/resources/images/ddia/Fig-11-3.png" title="Figure 11-3" style="height: 400px; width:800px;"/>
Figure 11-3. Producers send messages by appending them to a topic-partition file, 
and consumers read these files sequentially.

- Within each partition, the broker assigns a monotonically increasing 
sequence number, or offset, to every message
- Bec partition is append only, messages within a partition are totally ordered
- There is no ordering guarantee across different partitions
- Apache Kafka, Amazon Kinesis Streams, and Twitter’s DistributedLog are 
log-based message brokers
-  Google Cloud Pub/Sub is architecturally similar but exposes a JMS-style API 
rather than a log abstraction
- Even though these message brokers write all messages to disk, they are able 
to achieve throughput of millions of messages per second by partitioning across 
multiple machines, and fault tolerance by replicating messages

##### Logs compared to traditional messaging
- The log-based approach trivially supports fan-out messaging, because several 
consumers can independently read the log without affecting each other
- To achieve load balancing across a group of consumers, instead of assigning 
individual messages to consumer clients, the broker can assign entire partitions 
to nodes in the consumer group.
- Each consumer client then consumes all the messages in the partitions it has been assigned
- This coarse-grained load balancing approach has some downsides:
    - The number of nodes sharing the work of consuming a topic can be at most 
    the number of log partitions in that topic, because messages within the 
    same partition are delivered to the same node.
        - It’s possible to create a load balancing scheme in which two consumers 
        share the work of processing a partition by having both read the full 
        set of messages, but one of them only considers messages with 
        even-numbered offsets while the other deals with the odd-numbered offsets.
        - Alternatively, you could spread message processing over a thread pool,
        but that approach complicates consumer offset management.
        - In general, single-threaded processing of a partition is preferable, 
        and parallelism can be increased by using more partitions.
    - If a single message is slow to process, it holds up the processing of 
    subsequent messages in that partition (a form of head-of-line blocking; see “Describing Performance”).

- So JMS/AMQP style of message broker is preferable when
    - messages may be expensive to process
    - you want to parallelize processing on a message-by-message basis
    - message ordering is not so important
- Log-based message brokers works well when
    - high message throughput is required
    - each message is fast to process
    - message ordering is important

##### Consumer offsets
- Consuming a partition sequentially makes it easy to tell which messages have 
been processed
- all messages with an offset less than a consumer’s current offset have 
already been processed
- broker does not need to track acknowledgments for every single message—it 
only needs to periodically record the consumer offsets
- This reduces  bookkeeping overhead
- The batching and pipelining in this approach help increase the throughput of 
log-based systems
- This offset is in fact very similar to the log sequence number that is 
commonly found in single-leader database replication.
- Thus Message broker behaves like a leader database, and the consumer like a follower
- If a consumer node fails, another consumer node is assigned to partition
    - In this, another consumer may process few messages again depending on 
    when last consumer node has recorded the offset 

##### Disk space usage
- To reclaim disk space, the log is actually divided into segments
- From time to time old segments are deleted or moved to archive storage. 
- The log implements a bounded-size buffer that discards old messages when it 
gets full, also known as a circular buffer or ring buffer
- However, since that buffer is on disk, it can be quite large. 
- A back-of-the-envelope calculation looks like:
    - A typical large hard drive has 
        - 6 TB capacity
        - 150 MB/s write throughput
    - So at 150 MB/s write speed, it will take ~11 hours to fill the drive
        - 150 MB/s * 60 = 9000 MB/min => 9 GB/min => 540 GB/Hr
        - 6000 / 540 = ~11 Hrs
    - Generally deployments rarely use the full write bandwidth of the disk
    - so the log can typically keep a buffer of several days’ or even weeks’ 
    worth of messages
- Regardless of how long you retain messages, the throughput of a log remains 
more or less constant
- This is in contrast to Q based messaging systems
- Q based messaging systems 
    - keeps messages in RAM by default
    - only writes to Disk if Q grows too large
    - such systems are fast when queues are short and become much slower when 
    they start writing to disk
    - So throughput depends on the amount of history retained

##### When consumers cannot keep up with producers
- log-based approach is a form of buffering with a large but fixed-size buffer 
(limited by the available disk space).
- You can monitor how far a consumer is behind the head of the log, and 
raise an alert if it falls behind significantly
- As the buffer is large, there is enough time for a human operator to fix 
the slow consumer and allow it to catch up before it starts missing messages.
- Slow consumer does not disrupt the service for other consumers.
- This has big operational advantage
- But in traditional Q based message broker systems
    - you need to careful to delete any queues whose consumers have been shut down
    - Else they continue unnecessarily accumulating messages and taking away 
    memory from consumers that are still active.
##### Replaying old messages
- In AMQP/JSM style brokers, reading message is destructive operation.
    - broker deletes the message as soon as it is consumed
- In log-based brokers, reading messages is just like rteading a record in file
    - consumer can go back and read the messages again
    - offset is under consumer's control
- Above features of log-based broker system allows more experimentation and easier
 recovery from errors and bugs, making it a good tool for integrating dataflows 
 within an organization 

### Database and Streams
- we saw that log-based message brokers have been successful in taking ideas 
from databases and applying them to messaging
- We can also go in reverse: take ideas from messaging and streams, and apply 
them to databases
- The fact that something was written to a database is an event that can be 
captured, stored, and processed
- In fact, a replication log (see “Implementation of Replication Logs”) is a 
stream of database write events, produced by the leader as it processes transactions
- The events in the replication log describe the data changes that occurred.
- We also came across the state machine replication principle in 
“Total Order Broadcast”, which states:
    - if every event represents a write to the database, and every replica 
    processes the same events in the same order,
    - then the replicas will all end up in the same final state.
    - (Processing an event is assumed to be a deterministic operation.) 
    It’s just another case of event streams
- In this section we will first look at a problem that arises in 
heterogeneous data systems, and then explore how we can solve it by 
bringing ideas from event streams to databases.

#### Keeping Systems in Sync
- most nontrivial applications need to combine several different technologies 
in order to satisfy their requirements. For example
    - using an OLTP database to serve user requests
    - a cache to speed up common requests
    - a full-text index to handle search queries
    - a data warehouse for analytics
- Above systems are required to be kept in sync with one another.
- If an item is updated in the database, it also needs to be updated in the 
cache, search indexes, and data warehouse
- How to keep all systems in sync
- One solution dual writes
    - Application writes to DB first and then updates search index, cache, etc
- However, dual writes has some serious problems which leads to race conditions

<img src="/resources/images/ddia/Fig-11-4.png" title="Figure 11-4" style="height: 400px; width:800px;"/>
Figure 11-4. In the database, X is first set to A and then to B, while at the 
search index the writes arrive in the opposite order.

- post sequence mentioned in Figure 11-4, the two systems (DB and search index) 
are now permanently inconsistent with each other, even though no error occurred
- Another problem with dual writes is that one of the writes may fail while 
the other succeeds
    - This is a fault-tolerance problem rather than a concurrency problem
    - Ensuring that dual writes either both succeed or both fail is a case of 
    the atomic commit problem
    - atomic commit problem is expensive to solve (see 
    “Atomic Commit and Two-Phase Commit (2PC)”).

#### Change Data Capture (CDC)
- Historically, replication logs are considered internal implementation of DB
rather a public API
- DBs don't have documented way of getting the log of changes written to them
- So it was difficult to take all the changes made in a database and replicate 
them to a different storage technology such as a search index, cache, or data warehouse.
- But more recently, DBs are started supporting CDC mechanism

ToDo Fifure 11-5

##### Implementing change data capture
- The data stored in the search index and the data warehouse is just another 
view onto the data in the system of record
- CDC makes DB a leader and turns others into followers
- A log-based message broker is well suited for transporting the change events 
from the source database to the derived systems, since it preserves the 
ordering of messages (avoiding the reordering issue of Figure 11-2).
- DB triggers can also used to implement CDC
- But triggers tend to be fragile and have significant performance overheads
- Parsing the replication log can be a more robust approach, although it also 
comes with challenges, such as handling schema changes.

- Bottled Water implements CDC for PostgreSQL using an API that decodes 
the write-ahead log
- Maxwell and Debezium do something similar for MySQL by parsing the binlog
- Mongoriver reads the MongoDB oplog
- GoldenGate provides similar facilities for Oracle.
- The Kafka Connect framework offers further CDC connectors for various DBs.
- Like message brokers, change data capture is usually asynchronous
    - System of record DB does not wait for the change to be applied to 
    consumers before committing it
    - This design has operational advantages
        - slow consumer not to affect system of record
    - But has downside that all the issues of replication lag apply 
    (see “Problems with Replication Lag”).

##### Initial snapshot
- To add a derived system at any point of time, it needs to sync up with 
system of record DB
- But DB can keep limited number of replication log entries
- Solution is to start from a consistent snapshot as previously discussed in 
“Setting Up New Followers”.

##### Log compaction
- In a log-structured storage engine, an update with a special null value 
(a tombstone) indicates that a key was deleted, and causes it to be removed 
during log compaction
- But as long as a key is not overwritten or deleted, it stays in the log forever
- If the same key is frequently overwritten, previous values will eventually 
be garbage-collected, and only the latest value will be retained
- The same idea works in the context of log-based message brokers and CDC
- whenever you want to rebuild a derived data system such as a search index, 
you can start a new consumer from offset 0 of the log-compacted topic, and 
sequentially scan over all messages in the log. 
- The log is guaranteed to contain the most recent value for every key in the 
database (and maybe some older values)
- in other words, you can use it to obtain a full copy of the database contents 
without having to take another snapshot of the CDC source database
- This log compaction feature is supported by Apache Kafka. 
    - It allows the message broker to be used for durable storage, not just 
    for transient messaging.

##### API support for change streams
- Increasingly, DBs are beginning to support change streams as a first-class 
interface, rather than the typical retrofitted and reverse-engineered CDC efforts
    -  RethinkDB allows queries to subscribe to notifications when the results 
    of a query change
    - Firebase and CouchDB provide data synchronization based on a change feed 
    that is also made available to applications
    - Meteor uses the MongoDB oplog to subscribe to data changes and update 
    the user interface
    - VoltDB allows transactions to continuously export data from a database 
    in the form of a stream
    - Kafka Connect is an effort to integrate change data capture tools for 
    a wide range of DB systems with Kafka

#### Event Sourcing
- is a technique that was developed in the domain-driven design (DDD) community
- Similarly to CDC, event sourcing involves storing all changes to the 
application state as a log of change events. 
The biggest difference is that event sourcing applies the idea at a different 
level of abstraction:
- In CDC
    - log of changes is extracted from the database at a low level. 
    - The application writing to the database does not need to be aware that 
    CDC is occurring
- In event sourcing
    - the application logic is explicitly built on the basis of immutable 
    events that are written to an event log
    - event store is append-only
    - updates or deletes are discouraged or prohibited
    - Events are designed to reflect things that happened at the application 
    level, rather than low-level state changes.
- Event sourcing is a powerful technique for data modeling
    - from an application point of view it is more meaningful to record the 
    user’s actions as immutable events, rather than recording the effect of 
    those actions on a mutable database
- Event sourcing helps with debugging by making it easier to understand 
after the fact why something happened
- For example
    - storing the event “student cancelled their course enrollment” clearly 
    expresses the intent of a single action in a neutral fashion
    - whereas the side effects “one entry was deleted from the enrollments 
    table, and one cancellation reason was added to the student feedback table” 
    embed a lot of assumptions about the way the data is later going to be used.
    - If a new application feature is introduced, for example, 
    “the place is offered to the next person on the waiting list”, 
    the event sourcing approach allows that new side effect to easily be 
    chained off the existing event.

## Glossary
- Fanout => In transaction processing systems,number of request to other services that need to make in order to satisfy one incoming request.
- Latency => is a duration that a req is waiting to be handled. Means during which it is latent, awaiting service
- Response time Vs Latency
    - Response time is a time that client sees
    - includes n/w + queueing delays
- Nonfunctional Requirements => security, reliability, compliance, scalability, compatibility, maintainability, etc.
- schema-on-read => the structure of the data is implicit, and only interpreted when the data is read
- schema-on-write => the traditional approach of relational databases, where the schema is explicit and the database ensures all written data conforms to it
- OLTP => Online Transaction Processing
- OLAP => Online Analytics processing
- ELT => Extract, Transform, Load
- VCS => Version Control System