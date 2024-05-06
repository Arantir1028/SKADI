#!/usr/bin/env bash
# bash experiments/7.2_qos/2in7.sh

combination=(
  # '0 1'
  # '0 2'
  # '0 3'
  # '0 4'
  # '0 5'
  # '1 2'
  # '1 3'
  # '1 4'
  # '1 5'
  # '2 3'
  # '2 4'
  # '2 5'
  # '3 4'
  # '3 5'
  '4 5'
)

qos_target=(
  # '90' # Res50+Res101
  # '150' # Res50+Res152
  # '80' # Res50+IncepV3
  # '55' # Res50+VGG16
  # '60' # Res50+VGG19
  # '120' # Res101+Res152
  # '110' # Res101+IncepV3
  # '80' # Res101+VGG16
  # '55' # Res101+VGG19
  # '115' # Res152+IncepV3
  # '110' # Res152+VGG16
  # '130' # Res152+VGG19
  # '75' # IncepV3+VGG16
  # '60' # IncepV3+VGG19
  '70' # VGG16+VGG19
)

comb_name=(
  # "resnet50resnet101.csv"
  # "resnet50resnet152.csv"
  # "resnet50inception_v3.csv"
  # "resnet50vgg16.csv"
  # "resnet50vgg19.csv"
  # "resnet101resnet152.csv"
  # "resnet101inception_v3.csv"
  # "resnet101vgg16.csv"
  # "resnet101vgg19.csv"
  # "resnet152inception_v3.csv"
  # "resnet152vgg16.csv"
  # "resnet152vgg19.csv"
  # "inception_v3vgg16.csv"
  # "inception_v3vgg19.csv"
  "vgg16vgg19.csv"
)

load=(
  # '5'
  # '10'
  # '20'
  # '30'
  # '40'
  '50'
  # '60'
  # '70'
  # '80'
  # '90'
  # '100'
  # '110'
  # '120'
  # '130'
  # '140'
  # '150'
  # '160'
)

# qos
CURRENT_DIR=$(cd "$(dirname "$0")";pwd)
from=0
load_len=${#load[*]}
method_len=${#comb_name[*]}
comb_len=${#combination[*]}

res_dir="$CURRENT_DIR/../../results/2080Ti/2in7"
echo $res_dir

# for ((i = from; i < load_len; i++)); do
#   for ((k = 0; k < comb_len; k++)); do
#     python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy Abacus --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer
#     sleep 15
    # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy linear --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer
#     sleep 15
#     python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy mt-dnn --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer
#     sleep 15
    # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy tcp --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer
#     sleep 15
#     # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy FCFS --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
#     # sleep 15
#     # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy SJF --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
#     # sleep 15
#     # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy EDF --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
#     # sleep 15
#   done
#   # tag=`echo ${combination["$k"]} | sed s/' '//g`
#   # python3 ./experiments/7.2_qos/percentile2.py
#   # sleep 5
#   new_res_dir="$CURRENT_DIR/../../results/2080Ti/2in7-load${load["$i"]}"
#   echo $new_res_dir
#   cp -rf $res_dir $new_res_dir
# done


for ((i = from; i < load_len; i++)); do
  new_res_dir="$CURRENT_DIR/../../results/2080Ti/2in7-load${load["$i"]}"
  for ((k = 0; k < comb_len; k++)); do
    # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy mt-dnn --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
    # sleep 15
    # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy mt-dnn2 --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
    # sleep 15
    # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy mt-dnn3 --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer  --abandon --batch
    # sleep 10
    python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy tcp --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
    # sleep 15
    python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy linear --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
    # sleep 15
    # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy Abacus --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
    # sleep 15
    # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy FCFS --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
    # sleep 15
    # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy SJF --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
    # sleep 15
    # python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb ${combination["$k"]} --policy EDF --load ${load["$i"]} --qos ${qos_target["$k"]} --queries 1000 --thld 5 --ways 2 --predictor layer --abandon
    # sleep 15
    # cp -rf $res_dir/mt-dnn/${comb_name["$k"]} $new_res_dir/mt-dnn/${comb_name["$k"]}
    # cp -rf $res_dir/mt-dnn2/${comb_name["$k"]} $new_res_dir/mt-dnn2/${comb_name["$k"]}
    cp -rf $res_dir/tcp/${comb_name["$k"]} $new_res_dir/tcp/${comb_name["$k"]}
    cp -rf $res_dir/linear/${comb_name["$k"]} $new_res_dir/linear/${comb_name["$k"]}
    # cp -rf $res_dir/mt-dnn/${comb_name["$k"]} $new_res_dir/mt-dnn/${comb_name["$k"]}
    # cp -rf $res_dir/mt-dnn3/${comb_name["$k"]} $new_res_dir/mt-dnn3/${comb_name["$k"]}
    # cp -rf $res_dir/FCFS/${comb_name["$k"]} $new_res_dir/FCFS/${comb_name["$k"]}
    # cp -rf $res_dir/SJF/${comb_name["$k"]} $new_res_dir/SJF/${comb_name["$k"]}
    # cp -rf $res_dir/EDF/${comb_name["$k"]} $new_res_dir/EDF/${comb_name["$k"]}
    # cp -rf $res_dir/Abacus/${comb_name["$k"]} $new_res_dir/Abacus/${comb_name["$k"]}
  done
  # cp -rf $res_dir/mt-dnn2 $new_res_dir/mt-dnn2
  # python3 ./experiments/7.2_qos/percentile2.py
  # sleep 1
done


# for ((i = 0; i < load_len; i++)); do
#   python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb 0 1 --policy Abacus --load ${load["$i"]} --qos 50 --queries 1000 --thld 5 --ways 2 --abandon
#   python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb 0 1 --policy FCFS --load ${load["$i"]} --qos 50 --queries 1000 --thld 5 --ways 2 --abandon
#   python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb 0 1 --policy SJF --load ${load["$i"]} --qos 50 --queries 1000 --thld 5 --ways 2 --abandon
#   python3 main.py --task server --platform single --node 0 --gpu 2080Ti --device 0  --model_num 2 --comb 0 1 --policy EDF --load ${load["$i"]} --qos 50 --queries 1000 --thld 5 --ways 2 --abandon
#   new_res_dir="$CURRENT_DIR/../../results/2080Ti/2in7-01-load${load["$i"]}-ab"
#   cp -r $res_dir $new_res_dir
#   sleep 10
# done

# throughput
# for i in {0..20}; do
#   python main.py --task server --model_num 2 --comb ${combination["$i"]} --policy Abacus --load 50 --qos ${qos_target["$i"]} --queries 1000 --thld 5 --ways 2 --abandon
# done

# for i in {0..20}; do
#   python main.py --task server --model_num 2 --comb ${combination["$i"]} --policy SJF --load 50 --qos ${qos_target["$i"]} --queries 1000 --thld 5 --ways 2 --abandon
# done

# for i in {0..20}; do
#   python main.py --task server --model_num 2 --comb ${combination["$i"]} --policy FCFS --load 50 --qos ${qos_target["$i"]} --queries 1000 --thld 5 --ways 2 --abandon
# done

# for i in {0..20}; do
#   python main.py --task server --model_num 2 --comb ${combination["$i"]} --policy EDF --load 50 --qos ${qos_target["$i"]} --queries 1000 --thld 5 --ways 2 --abandon
# done
# cp -r scripts/server/7.2_qos/2in7 data/server/7.2_qos