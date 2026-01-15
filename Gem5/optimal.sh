
#!/bin/bash
set -euo pipefail

# --- gem5 base ---
GEM5_BIN="./build/ARM/gem5.opt"
CONFIG="configs/example/se.py"

# --- benchmark: specsjeng ---
BENCH_NAME="specsjeng"
BENCHMARK="spec_cpu2006/458.sjeng/src/specsjeng"
BENCH_ARGS="spec_cpu2006/458.sjeng/data/test.txt"
MAX_INSTS="100000000"
CPU_CLOCK="1GHz"

# --- LOW/HIGH levels (your choices) ---
L1I_SIZE_LOW="32kB";  L1I_SIZE_HIGH="64kB"
L1I_ASSOC_LOW=2;      L1I_ASSOC_HIGH=4
L1D_SIZE_LOW="64kB";  L1D_SIZE_HIGH="128kB"
L1D_ASSOC_LOW=2;      L1D_ASSOC_HIGH=4
L2_SIZE_LOW="512kB";  L2_SIZE_HIGH="2MB"
L2_ASSOC_LOW=8;       L2_ASSOC_HIGH=16
CL_LOW=32;            CL_HIGH=64

# --- PB-12 (run_id + A..G signs; + = HIGH, - = LOW) ---
PB12=(
"1 - - - - - + +"
"2 + + - - - + +"
"3 + - + - - + +"
"4 + - - + - + +"
"5 + - - - + + +"
"6 + - - - - - +"

)

pick_pm() { # pick_pm <+|-> <low> <high>
  if [ "$1" = "+" ]; then echo "$3"; else echo "$2"; fi
}
#bench=specsjeng run=4 A=+ B=- C=- D=- E=- F=+ G=+ 
LOG="runs_${BENCH_NAME}.log"
: > "$LOG"

mkdir -p "spec_results/${BENCH_NAME}"

for row in "${PB12[@]}"; do
  read -r run_id A B C D E F G <<< "$row"

  l1i_size=$(pick_pm "$A" "$L1I_SIZE_LOW" "$L1I_SIZE_HIGH")
  l1i_assoc=$(pick_pm "$B" "$L1I_ASSOC_LOW" "$L1I_ASSOC_HIGH")
  l1d_size=$(pick_pm "$C" "$L1D_SIZE_LOW" "$L1D_SIZE_HIGH")
  l1d_assoc=$(pick_pm "$D" "$L1D_ASSOC_LOW" "$L1D_ASSOC_HIGH")
  l2_size=$(pick_pm "$E" "$L2_SIZE_LOW" "$L2_SIZE_HIGH")
  l2_assoc=$(pick_pm "$F" "$L2_ASSOC_LOW" "$L2_ASSOC_HIGH")
  cacheline=$(pick_pm "$G" "$CL_LOW" "$CL_HIGH")

  outdir="spec_results/${BENCH_NAME}/pb_run${run_id}_cl${cacheline}_l1i${l1i_size}_${l1i_assoc}_l1d${l1d_size}_${l1d_assoc}_l2${l2_size}_${l2_assoc}"
  mkdir -p "$outdir"

  echo "Running ${BENCH_NAME} PB run $run_id -> $outdir"

  $GEM5_BIN -d "$outdir" "$CONFIG" \
    --cpu-type=MinorCPU \
    --caches \
    --l2cache \
    --l1i_size="$l1i_size" --l1i_assoc="$l1i_assoc" \
    --l1d_size="$l1d_size" --l1d_assoc="$l1d_assoc" \
    --l2_size="$l2_size"   --l2_assoc="$l2_assoc" \
    --cacheline_size="$cacheline" \
    --cpu-clock="$CPU_CLOCK" \
    -c "$BENCHMARK" -o "$BENCH_ARGS" \
    -I "$MAX_INSTS"

  # Extract stats from gem5's stats.txt written in outdir [web:833]
  stats="$outdir/stats.txt"
  cpi=$(awk '$1=="system.cpu.cpi"{print $2}' "$stats")
  dmiss=$(awk '$1=="system.cpu.dcache.overall_miss_rate::total"{print $2}' "$stats")
  imiss=$(awk '$1=="system.cpu.icache.overall_miss_rate::total"{print $2}' "$stats")
  l2miss=$(awk '$1=="system.l2.overall_miss_rate::total"{print $2}' "$stats")

  printf "bench=%s run=%s A=%s B=%s C=%s D=%s E=%s F=%s G=%s cl=%s l1i=%s/%s l1d=%s/%s l2=%s/%s cpi=%s dmiss=%s imiss=%s l2miss=%s out=%s\n" \
    "$BENCH_NAME" "$run_id" "$A" "$B" "$C" "$D" "$E" "$F" "$G" \
    "$cacheline" "$l1i_size" "$l1i_assoc" "$l1d_size" "$l1d_assoc" "$l2_size" "$l2_assoc" \
    "$cpi" "$dmiss" "$imiss" "$l2miss" "$outdir" >> "$LOG"
done

echo "Done. Log saved to $LOG"


# # LOW/HIGH επιλογές (βάλε εσύ τις τιμές)
# L1I_SIZE_LOW="32kB";  L1I_SIZE_HIGH="64kB"
# L1I_ASSOC_LOW=2;      L1I_ASSOC_HIGH=4
# L1D_SIZE_LOW="64kB";  L1D_SIZE_HIGH="128kB"
# L1D_ASSOC_LOW=2;      L1D_ASSOC_HIGH=4
# L2_SIZE_LOW="512kB";  L2_SIZE_HIGH="2MB"
# L2_ASSOC_LOW=8;       L2_ASSOC_HIGH=16
# CL_LOW=32;            CL_HIGH=64

# pick() { # pick level value: pick <level(1/2)> <low> <high>
#   if [ "$1" -eq 1 ]; then echo "$2"; else echo "$3"; fi
# }

# count = 0

# for entry in "${L12[@]}"; do
#   run_id="${entry%%:*}"
#   levels="${entry#*: }"
#   set -- $levels
#   c1=$1; c2=$2; c3=$3; c4=$4; c5=$5; c6=$6; c7=$7

#   l1i_size=$(pick $c1 "$L1I_SIZE_LOW" "$L1I_SIZE_HIGH")
#   l1i_assoc=$(pick $c2 "$L1I_ASSOC_LOW" "$L1I_ASSOC_HIGH")
#   l1d_size=$(pick $c3 "$L1D_SIZE_LOW" "$L1D_SIZE_HIGH")
#   l1d_assoc=$(pick $c4 "$L1D_ASSOC_LOW" "$L1D_ASSOC_HIGH")
#   l2_size=$(pick $c5 "$L2_SIZE_LOW" "$L2_SIZE_HIGH")
#   l2_assoc=$(pick $c6 "$L2_ASSOC_LOW" "$L2_ASSOC_HIGH")
#   cacheline=$(pick $c7 "$CL_LOW" "$CL_HIGH")

#   output_dir="screening/run${run_id}_cl${cacheline}_l1i${l1i_size}_${l1i_assoc}_l1d${l1d_size}_${l1d_assoc}_l2${l2_size}_${l2_assoc}"
#   ((count++))
    
#     echo "----------------------------------------"
#     echo "Running simulation $count"
#     echo "Configuration:"
#     echo "  Cache Line Size: ${cacheline}B"
#     echo "  L1I Size: $l1i_size, Assoc: $l1i_assoc"
#     echo "  L1D Size: $l1d_size, Assoc: $l1d_assoc"
#     echo "  L2 Size: $l2_size, Assoc: $l2_assoc"
#     echo "  Output: $output_dir"
#     echo "" 


#   $GEM5_BIN -d "$output_dir" $CONFIG \
#     --cpu-type=MinorCPU --caches --l2cache \
#     --l1i_size="$l1i_size" --l1i_assoc="$l1i_assoc" \
#     --l1d_size="$l1d_size" --l1d_assoc="$l1d_assoc" \
#     --l2_size="$l2_size"   --l2_assoc="$l2_assoc" \
#     --cacheline_size="$cacheline" \
#     --cpu-clock=1GHz \
#     -c "$BENCHMARK" -o "$BENCH_ARGS" -I "$MAX_INSTS"

# done



# #!/bin/bash

# # gem5 Cache Parameter Sweep Script for SPEC LBM benchmark
# # This script varies cache parameters and runs simulations

# # Base configuration
# GEM5_BIN="./build/ARM/gem5.opt"
# CONFIG="configs/example/se.py"
# BENCHMARK="spec_cpu2006/470.lbm/src/speclibm"
# BENCH_ARGS="20 spec_cpu2006/470.lbm/data/lbm.in 0 1 spec_cpu2006/470.lbm/data/100_100_130_cf_a.of"
# MAX_INSTS="10000000"

# # Parameter ranges
# CACHELINE_SIZES=(32 64 128)
# L1I_SIZES=(16kB 32kB 64kB 128kB)
# L1I_ASSOCS=(2 4)
# L1D_SIZES=(16kB 32kB 64kB 128kB)
# L1D_ASSOCS=(2 4)
# L2_SIZES=(256kB 512kB 1MB 2MB)
# L2_ASSOCS=(4 8)

# # Counter for tracking simulations
# sim_count=0

# echo "Starting gem5 cache parameter sweep..."
# echo "Total configurations to test: This will be calculated based on your selection"
# echo ""

# # Nested loops to iterate through all combinations
# for cacheline in "${CACHELINE_SIZES[@]}"; do
#   for l1i_size in "${L1I_SIZES[@]}"; do
#     for l1i_assoc in "${L1I_ASSOCS[@]}"; do
#       for l1d_size in "${L1D_SIZES[@]}"; do
#         for l1d_assoc in "${L1D_ASSOCS[@]}"; do
#           for l2_size in "${L2_SIZES[@]}"; do
#             for l2_assoc in "${L2_ASSOCS[@]}"; do
              
#               # Create unique directory name for this configuration
#               output_dir="spec_results_cache/speclibm_cl${cacheline}_l1i${l1i_size}_l1ia${l1i_assoc}_l1d${l1d_size}_l1da${l1d_assoc}_l2${l2_size}_l2a${l2_assoc}"
              
#               # Increment counter
#               ((sim_count++))
              
#               echo "----------------------------------------"
#               echo "Running simulation $sim_count"
#               echo "Configuration:"
#               echo "  Cache Line Size: ${cacheline}B"
#               echo "  L1I Size: $l1i_size, Assoc: $l1i_assoc"
#               echo "  L1D Size: $l1d_size, Assoc: $l1d_assoc"
#               echo "  L2 Size: $l2_size, Assoc: $l2_assoc"
#               echo "  Output: $output_dir"
#               echo ""
              
#               # Run gem5 simulation
#               $GEM5_BIN -d $output_dir $CONFIG \
#                 --cpu-type=MinorCPU \
#                 --caches \
#                 --l2cache \
#                 --l1d_size=$l1d_size \
#                 --l1i_size=$l1i_size \
#                 --l2_size=$l2_size \
#                 --l1i_assoc=$l1i_assoc \
#                 --l1d_assoc=$l1d_assoc \
#                 --l2_assoc=$l2_assoc \
#                 --cacheline_size=$cacheline \
#                 --cpu-clock=1GHz \
#                 -c $BENCHMARK \
#                 -o "$BENCH_ARGS" \
#                 -I $MAX_INSTS
              
#               # Check if simulation completed successfully
#               if [ $? -eq 0 ]; then
#                 echo "Simulation $sim_count completed successfully"
#               else
#                 echo "ERROR: Simulation $sim_count failed!"
#               fi
#               echo ""
              
#             done
#           done
#         done
#       done
#     done
#   done
# done

# echo "========================================="
# echo "All simulations completed!"
# echo "Total simulations run: $sim_count"
# echo "Results stored in spec_results/speclibm_* directories"
# echo "========================================="