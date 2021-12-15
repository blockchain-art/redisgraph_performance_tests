require 'Benchmark'
require 'redisgraph'
require 'redis'



@redis_graph_url = 'redis://127.0.0.1:26380/0'
@redis_graph_name = 'HMS'

Benchmark.bmbm do |x|
  x.report('Redis') do
    @redis = Redis.new(url: @redis_graph_url)
    query = "MATCH (requested_measure:Measure)-[:EQUALS*0..]->(equal_measures:Measure)\nWHERE requested_measure.value = \"occasions_1\"\nWITH collect(requested_measure) + collect(equal_measures) as measure_nodes, requested_measure\nUNWIND measure_nodes as relevant_measures\nWITH DISTINCT relevant_measures, requested_measure\nMATCH (relevant_measures)-[:CAPTURES]->(m:Measurement)-[:MEASURES]->(constants:Constant), p=(constants)<-[d:MEASURES]-(m)-[:EQUALS*0..]->(equal_measurements)<-[cap:CAPTURES]-(source_measures:Measure)\nWHERE 1 = 1 RETURN id(m), collect(distinct cap.storage_key), collect(d.dimension), collect(constants.value), requested_measure, collect(distinct d)"
    response = @redis.call('GRAPH.QUERY', @redis_graph_name, query, '--compact')
  end
end
