# # 假設 ts/train.py 接受相同鍵名參數
# python src/lerobot/scripts/train.py \
#   --steps 30000 \
#   --eval_freq 1000 --save_freq 1000 \
#   --policy.use_amp true --policy.dim_model 384 --policy.n_encoder_layers 3 \
#   --dataset.image_transforms.enable true \
#   --optimizer.lr 2e-5 --optimizer.weight_decay 3e-4
sh train-local.sh --confiug-path . --config-name train_local.yaml
