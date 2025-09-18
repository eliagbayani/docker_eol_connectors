from neo4j import GraphDatabase
import os

uri = os.getenv("NEO4J_URI")
username = os.getenv("NEO4J_USERNAME")
password = os.getenv("NEO4J_PASSWORD")

driver = GraphDatabase.driver(uri, auth=(username, password))

with driver.session() as session:
    session.run(
        "CREATE (n:Greeting {message: 'Hello from Python and Neo4j!'})")
    result = session.run("MATCH (n:Greeting) RETURN n.message AS message")
    for record in result:
        print(record["message"])

driver.close()
