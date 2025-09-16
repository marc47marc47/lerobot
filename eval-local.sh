sudo chmod 666 /dev/video0
rm -rf /home/ub22/.cache/huggingface/lerobot/seeedstudio123/eval_test
python -m lerobot.record  \
  --robot.type=so101_follower \
  --robot.port=/dev/ttyACM1 \
  --robot.cameras="{ side: {type: opencv, index_or_path: 0, width: 640, height: 480, fps: 30}} " \
  --robot.id=my_awesome_follower_arm \
  --display_data=false \
  --dataset.repo_id=seeedstudio123/eval_test \
  --dataset.single_task="Put lego brick into the transparent box" \
  --policy.path=outputs/train/act_so101_test/checkpoints/last/pretrained_model


exit $?

