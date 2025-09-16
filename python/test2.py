from neo4j import GraphDatabase
import os

# uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
# user = os.getenv("NEO4J_USER", "neo4j")
# password = os.getenv("NEO4J_PASSWORD", "your_password")

uri = os.getenv("NEO4J_URI")
user = os.getenv("NEO4J_USERNAME")
password = os.getenv("NEO4J_PASSWORD")

driver = GraphDatabase.driver(uri, auth=(user, password))


def create_node(tx, name):
    tx.run("CREATE (a:Person {name: $name})", name=name)


with driver.session() as session:
    session.write_transaction(create_node, "Alice")

print("Node 'Alice' created in Neo4j.")
driver.close()
