# 📘 Migration Refiner (Silver Bullet Edition) — Documentation

## 🧭 Overview

Migration Refiner is an intelligent, agent-driven system to refine and complete partially migrated Java enterprise applications (e.g., from EJB, Struts, JSP, iBatis) into production-ready Spring Boot apps using GPT-4o and code context stitching.

It supports Java 21, Gradle/Maven, vector similarity context resolution, auto healing on build failure, and unit test generation.

---

## 🧠 Agent-Based Architecture

The system is modular. Each agent is responsible for a single responsibility, working together to perform full migration refinement.

### 1. **MetadataAgent**

**Purpose**: Automatically detects build tools, database technologies, and caching mechanisms used in the legacy code.

* Scans `legacy_code/` for `pom.xml`, `build.gradle`, `.properties`, `.xml` files
* Outputs `metadata.json` with fields like:

  ```json
  {
    "buildTools": ["Maven", "Gradle"],
    "databases": ["Oracle"],
    "caches": ["EhCache"]
  }
  ```

### 2. **MappingVerifierAgent**

**Purpose**: Validates file-to-file mappings using semantic similarity.

* Loads `mapping.json` with legacy → migrated file pairs
* Embeds each file using OpenAI embeddings
* Computes cosine similarity
* Keeps valid pairs above a similarity threshold (default: 0.3)
* Produces:

  * `mapping.verified.json`
  * `mapping_verification.log` (rejected mappings with reasons)

### 3. **EmbeddingIndexerAgent**

**Purpose**: Embeds all Java source files from `legacy_code/` and `framework_code/` to FAISS vector DB.

* Uses `langchain` + `FAISS`
* Creates document chunks with `RecursiveCharacterTextSplitter`
* Stores the index in `embeddings/`

### 4. **ContextStitcherAgent**

**Purpose**: Retrieves semantically similar legacy files to stitch relevant context for GPT-4o prompts.

* Uses vector similarity from `EmbeddingIndexerAgent`
* Combines up to 4 most relevant legacy chunks
* Returns a stitched legacy context string (within GPT token limit)

### 5. **FixAndCompleteAgent**

**Purpose**: Prompts GPT-4o to fix and complete the broken/partial migrated class.

* Combines:

  * Legacy stitched context
  * Migrated (incomplete) class
* Constructs a rich prompt:

  > You are a Spring Boot expert... fix the following incomplete class using legacy context...
* Rewrites the target `.java` file with fixed output

### 6. **TestGeneratorAgent**

**Purpose**: Generates JUnit 5 test classes using GPT-4o

* Input: Fixed Java class
* Prompt: “Generate a JUnit 5 test class for the following class...“
* Writes to `<ClassName>Test.java`

### 7. **BuildValidatorAgent**

**Purpose**: Validates the build using Maven or Gradle

* Detects `pom.xml` or `build.gradle` under `migrated_code/`
* Runs `mvn install` or `gradle build`
* Logs output to `build.log`
* Returns success/failure status

### 8. **RetryAgent**

**Purpose**: Fixes code that failed to build by re-prompting GPT-4o with build error logs.

* Reads `build.log`
* For each migrated `.java` file:

  * Includes build error + broken class in prompt
  * Writes repaired class back
* Optional: logs retry status

### 9. **CoordinatorAgent**

**Purpose**: Orchestrates the full pipeline:

```text
For each verified mapping:
  - Get legacy + migrated files
  - Stitch legacy context
  - Fix the class using GPT-4o
  - Generate a test class
Validate the build
Retry failed files if needed
```

---

## 🧪 Pipeline Flow

```text
mapping.json
  ↓
MappingVerifierAgent → mapping.verified.json
  ↓
MetadataAgent → metadata.json
  ↓
EmbeddingIndexerAgent → embeddings/
  ↓
For each mapping:
  ContextStitcherAgent
  → FixAndCompleteAgent
  → TestGeneratorAgent
BuildValidatorAgent
  ↓
If build fails → RetryAgent
```

---

## ⚙️ Technical Requirements

### 🖥️ Environment

* Python 3.10+
* Java 21 (JDK)
* Gradle 8.6+ and/or Maven 3.9+
* Docker (optional, for containerized setup)
* OpenAI API Key (with GPT-4o access)

### 📦 Python Dependencies (in `requirements.txt`)

* `openai`
* `langchain`
* `faiss-cpu`
* `chromadb`
* `python-dotenv`

Install:

```bash
bash init.sh
python main.py
```

Or run in Docker:

```bash
docker build -t migration-refiner .
docker run -v $(pwd):/app migration-refiner
```

---

## 📂 Directory Layout

```
migration-refiner/
├── legacy_code/           # Legacy .java, .xml, .properties
├── migrated_code/         # Incomplete migrated code
├── framework_code/        # Base Spring Boot code/framework
├── agents/                # All intelligent agents
├── main.py
├── Dockerfile
├── init.sh
├── requirements.txt
├── mapping.json           # Input: file mappings
├── mapping.verified.json  # Output: valid mappings
├── build.log              # Output: build result
├── metadata.json
└── review_required/       # Files that still fail after retries
```

---

## 🚀 Future Extensions

* Auto-retry failed test cases
* Visualize mappings and diffs in web UI
* Add support for class merging (1\:N mapping)
* GitHub Action for CI pipeline

---

## 🏁 Conclusion

You now have a powerful, self-correcting, LLM-guided migration refiner ready to support complex, inconsistent legacy Java application modernization — at scale.
