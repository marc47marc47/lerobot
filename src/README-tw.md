# `lerobot` 目錄導覽

此目錄為 LeRobot Python 套件的核心程式碼，所有可安裝的模組皆從此處匯出。以下依子目錄或檔案列出用途，協助在地化維護與功能擴充。

## 主要模組
- `calibrate.py`：手動與自動校正流程入口，提供 CLI 與 API（對應 `lerobot-calibrate` 指令）。
- `record.py` / `replay.py` / `teleoperate.py`：資料錄製、離線重播與遠端操控的高階腳本邏輯。
- `setup_motors.py`：電機初始化與測試指令入口，整合多種伺服驅動器設定。
- `constants.py`、`errors.py`：集中維護共用常數與自訂例外，使多模組互通一致。

## 子目錄概覽
- `cameras/`：相機驅動、串流封裝與裝置探查；包含多種攝影機後端與同步工具。
- `configs/`：預設 YAML/JSON 設定與 dataclass 定義，支援訓練、資料集與機械手流程的組態載入。
- `datasets/`：資料集下載、轉換與緩存邏輯，含 Hugging Face Hub 整合及資料前處理工具。
- `envs/`：模擬與實體環境抽象層，定義與 gym-compatible 的環境包裝器。
- `model/`：共用模型元件（如影像編碼器、tokenizer 與特徵抽取器）。
- `motors/`：不同伺服驅動器與控制板的驅動程式，含 Feetech、Dynamixel 等實作。
- `optim/`：訓練常用最佳化器、排程器與梯度處理工具。
- `policies/`：各類策略模型（ACT、Diffusion、TDMPC、SAC、SmolVLA 等）與工廠方法。
- `processor/`：感測資料與動作訊號的批次處理、正規化與增強流程。
- `robots/`：特定機器人平台（HopeJR、SO-101、Reachy2...）的驅動、組態與介面。
- `scripts/`：命令列腳本入口與共用 CLI 工具，供 `lerobot-train`、`lerobot-eval` 等命令使用。
- `teleoperators/`：遙控設備（手套、操縱桿等）的抽象層與具體實作。
- `templates/`：生成新專案或設定檔的樣板，協助快速建立資料流程。
- `transport/`：訊息傳輸、串流與跨程序通訊層，支援即時資料交換。
- `utils/`：跨模組使用的工具函式，包含 IO、時間戳與數值處理等功能。

## 測試與整合提示
- 對應測試請置於 `tests/` 下同名結構，例如 `tests/policies/` 對應 `policies/`。
- 新增硬體相關功能時，優先檢查 `teleoperators/`、`motors/` 與 `robots/` 的現有抽象以維持一致。
- 若引入新的 CLI 指令，請在 `scripts/` 建立對應模組並更新 `pyproject.toml` 的 `project.scripts` 區段。
