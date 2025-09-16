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

## 第二層目錄詳解
### `cameras/`
- `opencv/`：以 OpenCV 實作的攝影機封裝，包含串流組態與影格擷取器。
- `reachy2_camera/`：針對 Reachy2 平台的相機驅動與設定封裝。
- `realsense/`：Intel RealSense 相機介面與參數設定模組。

### `datasets/`
- `push_dataset_to_hub/`：將資料集推送至 Hugging Face Hub 的輔助工具。
- `v2/`：舊版資料集轉換至 v2 格式的批次與單次轉換腳本。
- `v21/`：v2.1 資料格式轉換腳本與語言指令過濾工具。

### `motors/`
- `dynamixel/`：Dynamixel 伺服馬達的驅動程式與控制註冊表。
- `feetech/`：Feetech 伺服馬達控制邏輯與參數表。

### `policies/`
- `act/`：ACT 行為克隆策略的設定與模型實作。
- `diffusion/`：擴散策略的超參數設定與核心模型。
- `pi0/`：Pi0 語言條件策略，含 `conversion_scripts/` 轉換工具與專用 Flex Attention 實作。
- `pi0fast/`：Pi0 快速推論版本，提供簡化配置與模型。
- `sac/`：Soft Actor-Critic 策略；`reward_model/` 子目錄為獨立分類器獎勵模型。
- `smolvla/`：以小型視覺語言模型為基底的策略實作與專屬權重映射。
- `tdmpc/`：TDMPC 模型預測控制策略與設定檔。
- `vqbet/`：VQ-BET 策略模型與量化工具。

### `robots/`
- `bi_so100_follower/`：雙臂 SO-100 追隨者設定與介面。
- `hope_jr/`：HopeJR 機器人手臂/手掌模組與對應說明文件。
- `koch_follower/`：Koch 平台追隨者配置與操作腳本。
- `lekiwi/`：LeKiwi 行動底盤主控、客戶端與通信模組。
- `reachy2/`：Reachy2 機器人整合介面與配置。
- `so100_follower/`：SO-100 追隨者驅動與末端執行器支援。
- `so101_follower/`：SO-101 追隨者模組與說明文件。
- `stretch3/`：Stretch 3 移動操作手的配置與控制模組。
- `viperx/`：ViperX 手臂組態與介面。

### `scripts/`
- `rl/`：強化學習訓練服務腳本（包含學習者、推理器與資料裁切工具）。
- `server/`：遠端策略服務端與機器人客戶端腳本、常數與協助函式。

### `teleoperators/`
- `bi_so100_leader/`：雙臂 SO-100 主控端設定。
- `gamepad/`：通用手把操控設定與工具。
- `homunculus/`：Homunculus 手套/手臂驅動與關節映射。
- `keyboard/`：鍵盤即時操控模組。
- `koch_leader/`：Koch 主控端設定。
- `reachy2_teleoperator/`：Reachy2 遙控端流程。
- `so100_leader/`：SO-100 主控端設定。
- `so101_leader/`：SO-101 主控端設定。
- `stretch3_gamepad/`：Stretch3 與手把整合模組。
- `widowx/`：WidowX 遙控端設定。

### 其他
- `templates/`：包含模型卡樣板及資料視覺化 HTML 樣板，可直接複製修改。
- `transport/`：gRPC services 定義與自動產生檔，用於伺服器/客戶端通訊。
- `utils/`：雖無次層目錄，但涵蓋訓練流程、佇列、視覺化與 Hub 上傳等共用工具模組。

## 測試與整合提示
- 對應測試請置於 `tests/` 下同名結構，例如 `tests/policies/` 對應 `policies/`。
- 新增硬體相關功能時，優先檢查 `teleoperators/`、`motors/` 與 `robots/` 的現有抽象以維持一致。
- 若引入新的 CLI 指令，請在 `scripts/` 建立對應模組並更新 `pyproject.toml` 的 `project.scripts` 區段。
