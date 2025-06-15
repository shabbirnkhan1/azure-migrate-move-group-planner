# Azure Migrate Move Group Planner

This project analyzes Azure Migrate dependency analysis exports and automatically generates logical move groups based on actual server-to-server communication.

## 📌 Features

- Parses Azure Migrate dependency CSV
- Filters out noise ports like RDP, SSH, etc.
- Automatically detects server groups based on mutual communication
- Exports clean `move-groups.csv` for use in migration planning

## 📁 Folder Structure

```
.
├── scripts/
│   └── move-group-planner.ps1
├── sample-data/
│   └── dependency-export-sample.csv
├── output/
│   └── move-groups.csv (output)
```

## ▶️ How to Use

1. Edit `dependency-export-sample.csv` with your real data from Azure Migrate.
2. Open PowerShell and run:

```powershell
cd scripts
.\move-group-planner.ps1
```

3. Output file: `output/move-groups.csv`

## ⚙️ Parameters

| Parameter            | Default value                       | Description                                      |
|----------------------|-------------------------------------|--------------------------------------------------|
| `DependencyCsvPath`  | `./sample-data/dependency-export-sample.csv` | Path to your input file                       |
| `OutputCsvPath`      | `./output/move-groups.csv`          | Where result CSV is saved                        |
| `ExcludePorts`       | `22, 3389, 135, 445, 53, 123`       | Ports to ignore (RDP, SSH, DNS, etc.)            |
| `MaxGroupSize`       | `10`                                | Max servers per group (not currently enforced)   |

## 📤 Example Output

| Server Name   | Move Group Name |
|---------------|-----------------|
| app1-server   | Group1          |
| app2-server   | Group1          |
| db1-server    | Group1          |
| web1-server   | Group2          |

## 🛡️ License

MIT
