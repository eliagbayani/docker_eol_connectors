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
    tx.run("CREATE (a:Girl1 {name: $name})", name=name)


with driver.session() as session:
    session.execute_write(create_node, "Isaiah")
    # DeprecationWarning: write_transaction has been renamed to execute_write

print("Node 'Alice' created in Neo4j.")
driver.close()
