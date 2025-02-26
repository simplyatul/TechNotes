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
- System working as expected even when things go wrong.
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
- Handle/cpe with increased load
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

- In batch processing => cares about throughput
    - e.g. Hadoop
    - number of records processed / sec
- In online systems => cares about response time/Latency
    - time bet client sending req and receiving response

- Mean/Average time is not really good measure
    - it suppresses  outliers

### Maintainability


## Glossary
- Fanout => In transaction processing systems,number of request to other services that need to make in order to satisfy one incoming request.
- Latency => is a duration that a req is waiting to be handled. Means during which it is latent, awaiting service
- Response time Vs Latency
    - Response time is a time that client sees
    - includes n/w + queueing delays


