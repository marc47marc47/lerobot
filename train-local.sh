sudo apt install ffmpeg
python -m lerobot.scripts.train \
  --dataset.repo_id=seeedstudio123/test_01 \
  --policy.type=act \
  --output_dir=outputs/train/act_so101_test \
  --job_name=act_so101_test \
  --policy.device=cuda \
  --wandb.enable=false \
  --policy.push_to_hub=false\
  --steps=3000
