# Designing Data Intensive Applications
Book by Martin Kleppmann

## Chapter 1:  Reliable, Scalable and Maintainable  Application

- DBs Vs Msg Qs
    - Both store data for some time
    - diff access patterns
    - The boundaries bet them becoming blurred.
    - Redis => Datastore also used as message Qs
    - Kafka => Msg Qs with DB like durable guarantees

- Many applications now a days have demanding and wide ranging requirements
- So no single tool (DBs, Msg Qs, Caches, etc) can meet all storage and data processing needs
- Generally, its application code responsibility to keep caches in sync w/ main DB.

TODO: Figure 1-1

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

## Chapter 2: Data Models and Query Languages
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

## Chapter 3: Storage and Retrieval
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
    - 




























## Glossary
- Fanout => In transaction processing systems,number of request to other services that need to make in order to satisfy one incoming request.
- Latency => is a duration that a req is waiting to be handled. Means during which it is latent, awaiting service
- Response time Vs Latency
    - Response time is a time that client sees
    - includes n/w + queueing delays
- Nonfunctional Requirements => security, reliability, compliance, scalability, compatibility, maintainability, etc.
- schema-on-read => the structure of the data is implicit, and only interpreted when the data is read
- schema-on-write => the traditional approach of relational databases, where the schema is explicit and the database ensures all written data conforms to it

