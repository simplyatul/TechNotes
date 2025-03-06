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
    - user view tweets by people s/he follows
    - 300k req/sec

- Twitter faces main challenge due to Fanout (fetching user's home timeline)
    - each user follows many people
    - each user is followed by many people
    - Two Approaches to address
##### Approach I
- Make join query on following tables
- This fails on high load. So Twitter switched to [Approach II](Approach II)
TODO: Fig 1-2

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

TODO: Fig 1-3

##### Approach III - Hybrid of both
- for users having much more followers => Approach I
- for rest of the uses with less/avg followers => Approach II
- This provides good performance

#### Describing Performance
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

- median response time = 200 ms => half od request returns in < 200 ms and
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
    - 99the percentile under 1 sec
    - service uptime is 99.9%
- It is also required to measure response time at client side

ToDo Figure 1.5
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
        - (3*2*10^9) / 60 = 10^8 B/sec

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

ToDo Fig 2-1

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
    - and support for joins is often weak (but RethinkDB and ConchDB supports them to some extend)

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
ToDo Fig 3-1
- Above approach used in Bitcask (the default storage engine in Riak)
- Bitcask offers high-performance reads and writes, subject to the requirement that all the keys fit in the available RAM
    - uses case value of each key updated frequently

- How to avoid running out of disk space when using single append-only log file
    - on a threshold, break the log into certain size segment file
    - make subsequent writes to a new segment file
    - perform compaction on these segments
    - can also perform merge of segments together along with compaction
    - Segments are never modified after they have been written, so the merged segment is written to a new file.
- Compaction => Throwing away duplicate keys in the log, and keeping only the most recent update for each key.

ToDo - Fig 3-2
ToDo - Fig 3-3
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
    2. Each key only only appears once withing merged segment file
        - compaction process ensures this
ToDo Fig 3-4

- SSTables have several big advantages over log segments with hash indexes
    - Merging segments is simple and efficient, even if the files are bigger than the available memory. Bec segments contains keys in sorted order already
    - When multiple segments contain the same key, we can keep the value from the most recent segment and discard the values in older segments.
    - No need to keep an index for all keys in the memory
    - You still need an in-memory index to tell you the offsets for some of the keys, but it can be sparse
    - range queries are possible
    - compression reduces disk space + reduces I/O b/w use.
ToDo Fig 3-5

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

ToDo Fig 3-6

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

ToDo Fig 3-7

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
    - the place where rows are stored DB
    - stores data in no particular order
    - The heap file approach is common because it avoids duplicating data when multiple secondary indexes are present: each index just references a location in the heap file, and the actual data is kept in one place.

- Sometimes extra hop from index to heap file can reduce performance
- So it can be desirable to store the indexed row directly within an index.
- This is known as a clustered index
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

ToDo Fig 3-8

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

ToDo Fig 3-9

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

ToDo Fig 3-10

- The column-oriented storage layout relies on each column file containing the rows in the same order
- Thus, if you need to reassemble an entire row, you can take the 23rd entry from each of the individual column files and put them together to form the 23rd row of the table.

#### Column Compression
- column-oriented storage often lends itself very well to compression.
- Check values for each column Figure 3-10. They often look quite repetitive, which is a good sign for compression.
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
