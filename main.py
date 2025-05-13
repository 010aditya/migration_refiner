import json
import os
from agents.metadata_agent import MetadataAgent
from agents.mapping_verifier import MappingVerifierAgent
from agents.coordinator import CoordinatorAgent

if __name__ == "__main__":
    MetadataAgent().parse()
    MappingVerifierAgent().verify("mapping.json")

    if not os.path.exists("mapping.verified.json"):
        raise FileNotFoundError("❌ No valid mappings found.")

    with open("mapping.verified.json") as f:
        verified_mapping = json.load(f)

    CoordinatorAgent(verified_mapping).run()
