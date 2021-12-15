defmodule ElixirRedisgraphClient do
  def bench do
    Benchee.run(%{
      "graph_query" => fn -> query_redisgraph() end
    },
    time: 3,
    memory_time: 0.1,
    warmup: 0,
    formatters: [
      Benchee.Formatters.HTML,
      Benchee.Formatters.Console
    ]
    )
  end

  def query_redisgraph do
    alias RedisGraph.{QueryResult}

    query = "MATCH (requested_measure:Measure)-[:EQUALS*0..]->(equal_measures:Measure)\nWHERE requested_measure.value = \"occasions_1\"\nWITH collect(requested_measure) + collect(equal_measures) as measure_nodes, requested_measure\nUNWIND measure_nodes as relevant_measures\nWITH DISTINCT relevant_measures, requested_measure\nMATCH (relevant_measures)-[:CAPTURES]->(m:Measurement)-[:MEASURES]->(constants:Constant), p=(constants)<-[d:MEASURES]-(m)-[:EQUALS*0..]->(equal_measurements)<-[cap:CAPTURES]-(source_measures:Measure)\nWHERE 1 = 1 RETURN id(m), collect(distinct cap.storage_key), collect(d.dimension), collect(constants.value), requested_measure, collect(distinct d)"

    {:ok, conn} = Redix.start_link("redis://127.0.0.1:26380/0")
    {:ok, query_result} = RedisGraph.query(conn, "HMS", query)

   # IO.puts(QueryResult.pretty_print(query_result))
  end

  # def query_redisgraph do
  #   #query = "MATCH (requested_measure:Measure)-[:EQUALS*0..]->(equal_measures:Measure)\nWHERE requested_measure.value = \"gender\"\nWITH collect(requested_measure) + collect(equal_measures) as measure_nodes, requested_measure\nUNWIND measure_nodes as relevant_measures\nWITH DISTINCT relevant_measures, requested_measure\nMATCH (relevant_measures)-[:CAPTURES]->(m:Measurement)-[:MEASURES]->(constants:Constant), p=(constants)<-[d:MEASURES]-(m)-[:EQUALS*0..]->(equal_measurements)<-[cap:CAPTURES]-(source_measures:Measure)\nWHERE 1 = 1 RETURN id(m), collect(distinct cap.storage_key), collect(d.dimension), collect(constants.value), requested_measure, collect(distinct d)"
  #   query = "MATCH (n) return count n"
  #   {:ok, conn} = Redix.start_link("redis://127.0.0.1:26380/0")
  #   c = ["GRAPH.QUERY", "HMS", query, "--compact", "timeout", 50000]
  #   Redix.command(conn, c)
  # end
end
