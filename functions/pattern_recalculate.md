# Recalculate Stats Pattern

Diagram ini menunjukkan alur pattern yang sama untuk semua recalculate stats (`kehamilan`, `kunjungan`, `pasien`, `persalinan`) di Firestore.

```mermaid
flowchart TD
    A[Fetch all documents from collection] --> B{Loop per document}
    B --> C[Check if document has id_bidan]
    C -->|No| B
    C -->|Yes| D[Extract relevant data]
    D --> E[Determine monthKey using created_at / date field]
    E --> F[Aggregate counts in temporary stats object per bidan & month]
    F --> G[Track latest month per bidan for last_updated_month]
    B --> B

    G --> H[Prepare batch write]
    H --> I[Fetch existing statistics document per bidan]
    I --> J[Initialize by_month map if missing]

    J --> K[Merge existing by_month with new stats]
    K --> L[Filter months: only keep last 13 months]
    L --> M[Set last_updated_month = latest month]
    M --> N[Add to batch]
    N --> O[Commit batch]

    O --> P[Return response / log results]
