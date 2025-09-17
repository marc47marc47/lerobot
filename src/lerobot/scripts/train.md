# 讀懂 `train()`：從流程到機器學習原理（含文字公式與純文字流程圖）

本文用淺顯語言帶你理解 `src/lerobot/scripts/train.py` 中的 `train()` 做了什麼，並用「文字形式的公式」補充機器學習原理，最後附上純文字流程圖，幫你把整個訓練步驟串起來。

---

## 一、先用白話帶你走一遍
- 讀設定 → 設隨機種子 → 選 CPU 或 GPU
- 準備資料集與資料載入器（DataLoader）
- 建立模型（policy）、優化器與學習率排程
- 進入訓練迴圈：一批資料 → 算損失 → 反向傳播 → 更新參數
- 依頻率：記錄訓練指標、存 checkpoint、在環境做小考（評估）
- 結束時收尾，需要時把模型推到 Hub

---

## 二、對照 `train()` 的主要步驟
1) 驗證與印出設定：`cfg.validate()`，並設定記錄（本地或 wandb）
2) 固定隨機種子：`set_seed(cfg.seed)` 讓實驗更可重現
3) 選裝置與加速設定：`get_safe_torch_device(...)`、啟用 cudnn benchmark 與 TF32
4) 準備資料集與（可選）評估環境：`make_dataset(cfg)`、`make_env(cfg.env, ...)`
5) 建立模型：`policy = make_policy(cfg.policy, ds_meta=dataset.meta)`
6) 準備優化器與學習率排程：`make_optimizer_and_scheduler(cfg, policy)`
7) 建立資料載入器：可能用 `EpisodeAwareSampler` 或一般隨機打亂
8) 建立紀錄器：`AverageMeter`、`MetricsTracker`
9) 進入訓練迴圈：
   - 取 batch、搬到裝置
   - `update_policy(...)`：前向、反向、裁剪梯度、更新參數、學習率步進、AMP 縮放
   - 依頻率記錄、存檔、評估
10) 結束收尾：關閉評估環境、（可選）`push_to_hub`

---

## 三、機器學習原理（用文字寫公式）
以下用文字替代數學符號，盡量不使用特殊字元。把模型參數寫成 `theta`，一個資料點是 `(x, y)`，模型預測寫成 `f_theta(x)`。

### 1) 訓練目標：經驗風險最小化
- 整體目標：最小化「平均訓練損失」。
- 文字公式：
  - `objective(theta) 等於 training_set 上的平均 loss`，也就是
  - `objective(theta) 等於 (1 除以 N) 乘上 sum 從 i 等於 1 到 N 的 loss( f_theta(x_i), y_i )`
- 小批次（minibatch）近似：
  - 訓練時每一步只看一小批資料，
  - `batch_objective(theta) 等於 (1 除以 B) 乘上 sum 在 batch 中的 loss( f_theta(x), y )`

在程式中：`policy.forward(batch)` 會回傳 `loss`，這就是上面 `batch_objective(theta)` 的數值。

### 2) 常見損失函數
- 回歸常用「均方誤差」：
  - `mse_loss 等於 (1 除以 B) 乘上 sum 在 batch 的 (y_hat 減 y) 的平方`
  - 其中 `y_hat 等於 f_theta(x)`。
- 分類常用「交叉熵」：
  - `cross_entropy 等於 負的 (1 除以 B) 乘上 sum 在 batch 的 log( 模型給真實類別的機率 )`

實務上 `policy.forward(batch)` 會依任務型態挑適合的損失。

### 3) 反向傳播與參數更新（梯度下降的精神）
- 基本梯度下降：
  - `theta_new 等於 theta_old 減去 learning_rate 乘上 objective 對 theta 的梯度`
  - 文字說法：沿著「讓損失下降最快」的方向，走一小步，步長由 `learning_rate` 決定。
- 在程式中：
  - `loss.backward()` 計算梯度；本檔案中由 `GradScaler` 介入為 `grad_scaler.scale(loss).backward()`。
  - `optimizer.step()` 依優化法則更新參數。

#### Adam 優化器（常用）
以文字描述 Adam 的更新：
- 設 `g_t` 為當前步的梯度（對 `theta` 的導數）。
- 一階動量（像移動平均）：`m_t 等於 beta1 乘上 m_{t-1} 加上 (1 減去 beta1) 乘上 g_t`。
- 二階動量（平方梯度的移動平均）：`v_t 等於 beta2 乘上 v_{t-1} 加上 (1 減去 beta2) 乘上 (g_t 的逐元素平方)`。
- 偏差校正：`m_hat 等於 m_t 除以 (1 減去 beta1 的 t 次方)`；`v_hat 等於 v_t 除以 (1 減去 beta2 的 t 次方)`。
- 參數更新：`theta_new 等於 theta_old 減去 learning_rate 乘上 ( m_hat 除以 ( sqrt(v_hat) 加上 epsilon ) )`。

在本程式中，具體使用哪個優化器由 `make_optimizer_and_scheduler` 依設定決定，但精神相同：用梯度的平滑與縮放讓訓練更穩定。

### 4) 混合精度與梯度縮放（AMP 與 GradScaler）
- 目的：加速運算、節省顯存，同時避免數值太小造成梯度變成零。
- 文字流程：
  - `scaled_loss 等於 scale_factor 乘上 loss`；反向傳播會得到被放大的梯度。
  - 更新前用 `grad_scaler.unscale_(optimizer)` 把梯度縮回原比例，否則裁剪與更新會錯。
  - 若偵測到數值爆掉（例如出現無限或非數），`GradScaler` 會跳過這次 `optimizer.step()`，並自動調整 `scale_factor`。

對應到原始碼：`with torch.autocast(...)` 開啟混合精度；`grad_scaler.scale(loss).backward()`、`grad_scaler.unscale_(optimizer)`、`grad_scaler.step(optimizer)`、`grad_scaler.update()` 負責整個縮放與安全更新流程。

### 5) 梯度裁剪（避免一步走太大）
- 核心想法：如果當前梯度的大小太大，先把它縮小到可接受範圍，避免更新暴衝。
- 文字公式（以 l2 範數為例）：
  - 設 `g` 為所有參數梯度拼在一起的向量，`g_norm` 為 `g` 的 l2 範數。
  - 如果 `g_norm 大於 clip_norm`，那麼把每個梯度都乘上 `clip_norm 除以 g_norm`。
  - 否則不變。
- 在程式中：`torch.nn.utils.clip_grad_norm_(policy.parameters(), grad_clip_norm, ...)` 就是做這件事。

### 6) 學習率排程（學到後期放慢腳步）
- 想法：前期可以學快一點，後期放慢讓模型調得更精細。
- 常見例子（文字形式）：
  - 線性暖身：`當步數小於 warmup_steps 時，lr 等於 base_lr 乘上 ( 當前步數 除以 warmup_steps )`。
  - 餘弦退火：`lr_t 等於 min_lr 加上 (base_lr 減去 min_lr) 乘上 0.5 乘上 ( 1 加上 cos( pi 乘上 t 除以 T ) )`。
- 在程式中：`lr_scheduler.step()` 於每個 batch 後更新當前學習率。

### 7) 小批次梯度是整體梯度的近似
- 理想上要用整個資料集的平均梯度更新，但太慢。
- 文字公式：`full_gradient 約等於 (1 除以 B) 乘上 sum 在 batch 的 gradient( loss( f_theta(x), y ) 對 theta )`。
- 這種近似在多步下仍能朝降低損失的方向前進，因此成為標準做法。

### 8) 評估與指標
- 在環境中跑 `cfg.eval.n_episodes` 回合，量測：
  - 平均回饋（`avg_sum_reward`）：每回合得到的獎勵總和的平均。
  - 成功率（`pc_success`）：成功次數占比乘上一百。
- 文字上可理解為：`avg_sum_reward 等於 (1 除以 回合數) 乘上 sum 每回合的總獎勵`；`pc_success 等於 (成功回合數 除以 總回合數) 乘上一百`。

### 9) 檢查點與恢復
- 檢查點會存：`theta`（模型參數）、優化器狀態（例如 Adam 的 `m` 與 `v`）、學習率排程狀態、目前 `step`。
- 恢復訓練時，從檔案把這些讀回來，等同於「從同一個 `theta` 與相同學習進度」接著學。

---

## 四、把原理套回 `update_policy(...)`
`update_policy` 這個函式的順序基本就是一次標準的「小批次訓練步」：
- 自動混合精度下計算 `loss`
- 以縮放過的 `loss` 反向傳播，得到梯度
- 將梯度反縮放，然後做「梯度裁剪」
- `optimizer.step()` 進行參數更新；`lr_scheduler.step()` 更新學習率
- `grad_scaler.update()` 自動調整縮放因子
- 回傳這一步的訓練指標（如 `loss`、`grad_norm`、`lr`、用時）

從數學角度來看，這就是在以「小批次估計的梯度」往下走，並用一些穩定技巧（AMP、裁剪、排程）讓訓練更快更穩。

---

## 五、快速小抄（你可以對照程式碼）
- 目標：`minimize 平均訓練損失`
- 更新：`theta_new 等於 theta_old 減去 learning_rate 乘上 gradient(loss 對 theta)`
- Adam：`m_t`、`v_t` 的移動平均與偏差校正，再用 `m_hat 除以 sqrt(v_hat)` 更新
- AMP：`scaled_loss` 反向、再 `unscale`、再更新
- 裁剪：若梯度 l2 範數超過 `clip_norm` 就等比例縮小
- 排程：每步 `lr_scheduler.step()` 更新 `lr`

---

## 六、作業流程圖（純文字）
```text
[Start]
  |
  v
[讀取並驗證設定 cfg]
  |-- 若 cfg.wandb.enable 且有 project --> [建立 WandB 記錄器]
  |-- 否則 --> [本地記錄]
  |
  v
[固定隨機種子 set_seed(cfg.seed) (可選)]
  |
  v
[選擇裝置 get_safe_torch_device / 啟用 cudnn.benchmark 與 TF32]
  |
  v
[建立資料集 make_dataset(cfg)] --> [建立 EpisodeAwareSampler? 視 cfg.policy]
  |
  v
[建立評估環境 make_env (可選：若 cfg.env 且 cfg.eval_freq > 0)]
  |
  v
[建立模型 make_policy(cfg.policy, ds_meta=dataset.meta)]
  |
  v
[建立優化器與學習率排程 make_optimizer_and_scheduler]
  |
  v
[建立 GradScaler (若 cfg.policy.use_amp)]
  |
  v
[建立 DataLoader(dataset, batch_size, num_workers, sampler)]
  |
  v
+------------------ 訓練迴圈：step = 1..cfg.steps ------------------+
|  取一個 batch --> 搬到裝置 (CPU/GPU)                               |
|  若啟用 AMP：with torch.autocast(...)                               |
|  前向：loss, outputs = policy.forward(batch)                         |
|  反向：grad_scaler.scale(loss).backward()                            |
|  反縮放：grad_scaler.unscale_(optimizer)                             |
|  裁剪：clip_grad_norm_(params, cfg.optimizer.grad_clip_norm)         |
|  參數更新：grad_scaler.step(optimizer)                               |
|  縮放器更新：grad_scaler.update()                                    |
|  清梯度：optimizer.zero_grad()                                       |
|  學習率步進（如有）：lr_scheduler.step()                            |
|  內部更新（如有）：policy.update()                                   |
|  步數加一：step += 1；更新 MetricsTracker                            |
|  若到 log 步：記錄到 logger / wandb                                  |
|  若到 save 步：save_checkpoint + update_last_checkpoint               |
|  若到 eval 步：eval_policy，記錄 avg_sum_reward / pc_success          |
+---------------------------------------------------------------------+
  |
  v
[關閉評估環境 (如建立)]
  |
  v
[若 cfg.policy.push_to_hub --> push_model_to_hub]
  |
  v
[End]
```

---

有了這份「流程 + 原理 + 文字公式 + 作業流程圖」的地圖，你不只知道 `train()` 在做什麼，也能理解為什麼這樣做有效，以及每一個步驟對穩定和效率的幫助。

