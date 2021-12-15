import timeit
import redis
from redisgraph import Node, Edge, Graph, Path

def query_redisgraph():
    r = redis.Redis(host='127.0.0.1', port=26380, db=0)
    redis_graph = Graph('HMS', r)

    query = "MATCH (requested_measure:Measure)-[:EQUALS*0..]->(equal_measures:Measure)\nWHERE requested_measure.value = \"occasions_1\"\nWITH collect(requested_measure) + collect(equal_measures) as measure_nodes, requested_measure\nUNWIND measure_nodes as relevant_measures\nWITH DISTINCT relevant_measures, requested_measure\nMATCH (relevant_measures)-[:CAPTURES]->(m:Measurement)-[:MEASURES]->(constants:Constant), p=(constants)<-[d:MEASURES]-(m)-[:EQUALS*0..]->(equal_measurements)<-[cap:CAPTURES]-(source_measures:Measure)\nWHERE 1 = 1 RETURN id(m), collect(distinct cap.storage_key), collect(d.dimension), collect(constants.value), requested_measure, collect(distinct d)"

    result = redis_graph.query(query, timeout=50000)
  #  result.pretty_print()


num_runs = 1
duration = timeit.Timer(query_redisgraph).timeit(number = num_runs)
avg_duration = duration/num_runs
print(f'On average it took {avg_duration} seconds')
