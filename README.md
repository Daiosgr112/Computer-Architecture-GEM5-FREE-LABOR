
### ΓΡΗΓΟΡΙΟΣ ΔΑΙΟΣ | ΑΕΜ 10334 | ΑΡΧΙΤΕΚΤΟΝΙΚΗ  ΠΡΟΗΓΜΕΝΩΝ ΥΠΟΛΟΓΙΣΤΩΝ ΚΑΙ ΕΠΙΤΑΧΥΝΤΩΝ

# GEM5 

An educational project for the tool GEM5. In this project we run only the System Call Emulation mode (just a specific program)


## Step 1 
We actually skip this one since we are working on a provided virtual machine .

## Step 2 :Getting to know gem5 and "Hello World"
We go to gem5 folder and we add the file greg.sh which includes the command given in this step to execute "Hello World" program through the simulator. Our terminal is:
```
cd ~/Desktop/gem5

./build/ARM/gem5.opt configs/example/arm/starter_se.py --cpu="minor" "tests/test-progs/hello/bin/arm/linux/hello"
```
and the output is :

![Output of Hello World](/Gem5/terminal.png)

### Q1
Configuring the simulator with starter_se.py and and giving in parameters the above script we have the following parameters:

>**CPU** 
>>- Type : Minor
>>- Cores : 1
>>- Voltage : 3.3V
>>- Frequency clock: 1GHz

>**Caches**
>>- L1 Instruction
>>- L1 Data
>>- L2
>>- WalkCache

>**Memory**
>>- 2 GB
>>- DDR3 1600 8x8
>>- 2 memory channels


### Q2
#### a,b,c)
```
both the output of our program and the stats.txt show ticks simulated (cross-checking our results)
stats.txt:
sim_seconds         0.000035    # Number of seconds simulated
sim_ticks           35144000    # Number of ticks simulated
sim_insts           5027        # Number of instructions simulated
host_seconds        0.07        # Real time elapsed on the host
host_tick_rate      530727361   # Simulator tick rate (ticks/s)
system.cpu_cluster.cpus.committedInsts      5027    # Number of instructions committed
system.cpu_cluster.cpus.dcache.demand_accesses::total        2160    # number of demand (read+write)accesses or L1
system.cpu_cluster.l2.demand_accesses::total          474       # number of demand (read+write) accesses
```

```
config.ini:
We can see here what type of cpu we used (cross-checks with starter_se.py)
[system.cpu_cluster.cpus]
type=MinorCPU
```
```
config.json:
     we can also see the voltage and the cache line size parameters given in starter_se.py
     "eventq_index": 0, 
            "voltage": [
                3.3
            ], 
            "cxx_class": "VoltageDomain", 
            "path": "system.voltage_domain", 
            "type": "VoltageDomain"
        }, 
        "cache_line_size": 64, 
```
#### d)
L1 data access = 2160 which can also be found from the formula : hits + miss
```
system.cpu_cluster.cpus.dcache.overall_hits::total         1983        # number of overall hits
system.cpu_cluster.cpus.dcache.overall_misses::total          177       # number of overall misses
```
L1=1983+177=2160

L2 = hits +misses (there is no hits)
```
system.cpu_cluster.l2.demand_misses::total          474                       # number of demand (read+write) missessystem.
system.cpu_cluster.l2.demand_miss_rate::total         1                       # miss rate for demand accesses
```
miss rate = 1 thus hits are 0

L2=474 + 0 =474

### Q3
#### In-order cpus
>- Simple cpu
>>- The SimpleCPU is a purely functional, in-order model that is suited for cases where a detailed model is not necessary. This can include warm-up periods, client systems that are driving a host, or just testing to make sure a program works .It is broken in three classes.
>>- BaseSimpleCpu 
>>- The AtomicSimpleCPU is the version of SimpleCPU that uses atomic memory accesses 
>>- The TimingSimpleCPU is the version of SimpleCPU that uses timing memory accesses 


>- MinorCpu
>>- Minor is an in-order processor model with a fixed pipeline but configurable data structures and execute behaviour. 
>>- It is intended to be used to model processors with strict in-order execution behaviour and allows visualisation of an instruction’s position in the pipeline through the MinorTrace/minorview.py format/tool

#### Run our program 
We find 1+2+...+N (myprog.c file)


| Stat | MinorCPU -2GHz| TimingSimpleCPU-2GHz |MinorCPU -1GHz| TimingSimpleCPU-1GHz|
|---|---:|---:|---:|---:|
| sim_seconds | 0.000036 | 0.000042 |0.000044 | 0.000057 |
| sim_ticks | 36300000 | 41793000 |43920000 | 56684000 |
| sim_insts | 9483 | 9429 |9483 | 9429 |
| host_inst_rate | 193030 | 689096 |194809 | 583153 |
| committedInsts | 9483 | 9429 |9483 | 9429 |
| dcache.demand_accesses | 3382 | 3089 |3382 | 3089 |
| l2.demand_accesses | - | - |-| - |

It seems like both CPUs don't have l2 cache from the parameters given in "se.py". Also there is a big difference in host instuction rate and more simulation time in TimingSimpleCPU albeit the less cache l1 accesses.

The TimingSimpleCPU stalls on cache accesses and waits for the memory system to respond prior to proceeding but since its a simple model it actually takes less time for the host to simulate thus a higher instruction rate.

Minor models a fixed in-order pipeline with multiple stages (e.g., fetch/decode/execute) and internal structures (buffers/scoreboard), so it can capture stalls and some pipeline effects beyond just memory latency. 
#### c) Run with different clock and memory
We can change our file.sh and to achieve 1 or 2Ghz frequency (default is probably 2Ghz since stats look the same when we .
did't give clock in the options). Since I didn't include in the table with the stats, how different CPUs behave with different memory types (simple memory or DDR3 1600 8x8) I am listing them here.Clock this time is left default.  

| Stat | MinorCPU Simple-mem| TimingSimpleCPU Simple-mem |MinorCPU DDR| TimingSimpleCPU DDR|
|---|---:|---:|---:|---:|
| sim_seconds | 0.000029 | 0.000034 |0.000036 | 0.000042 |
| sim_ticks | 29118000 | 34416000 |36300000 | 41793000 |
| sim_insts | 9483 | 9429 |9483 | 9429 |
| host_inst_rate | 205924 | 712824 |200436 | 661514 |
| committedInsts | 9483 | 9429 |9483 | 9429 |
| dcache.demand_accesses | 3382 | 3089 |3382 | 3089 |
| l2.demand_accesses | - | - |-| - |


## Step 3
### Benchmarks other statistics and many more
We run the benchmarks provided in spec_cpu2006 folder with ```bash res1.sh``` and then we collect the neccesary data. It should be noted that we also run the read_results.sh script with our mypar.ini configuration file which let us create a Result1.txt file with the relevant data. 

#### Memory info 
As we did in Step 1 we search in config.ini and stats.txt for some memory information. All of the benchmarks utilised the same basic memory configurations which is listed below 
>- l1 data size = (l1.dcache.size) = 65536
>- l1 instruction size = (l1.icache.size) = 32768
>- l1 data associativity = 2
>- l1 instruction associativity = 2 
>- cache line size = 64
>- l2 size = 2097152
>- l2 associativity = 8
>- ram size = DDR3_1600_x64 (default as in step 1)

Also we plot some graphs here:

### Simulated seconds
![sim_seconds](Gem5/results1/sim_seconds.png)

### CPI
![cpi](Gem5/results1/system.cpu.cpi.png)

### L1 Data cache miss rate
![l1 data cache miss rate](Gem5/results1/system.cpu.dcache.overall_miss_rate::total.png)

### L1 instruction cache miss rate
![l1 instrtuctions miss rate](Gem5/results1/system.cpu.icache.overall_miss_rate::total.png)

### L2 cache miss rate
![l2 cache miss rate](Gem5/results1/system.l2.overall_miss_rate::total.png)


Now it is required from us to run the same plots in 1 Ghz and 4Ghz

## 1Ghz:

## Simulated seconds
![sim_seconds](Gem5/results2/sim_seconds.png)

### CPI
![cpi](Gem5/results2/system.cpu.cpi.png)

### L1 Data cache miss rate
![l1 data cache miss rate](Gem5/results2/system.cpu.dcache.overall_miss_rate::total.png)

### L1 instruction cache miss rate
![l1 instrtuctions miss rate](Gem5/results2/system.cpu.icache.overall_miss_rate::total.png)

### L2 cache miss rate
![l2 cache miss rate](Gem5/results2/system.l2.overall_miss_rate::total.png)


## 4Ghz:

## Simulated seconds
![sim_seconds](Gem5/results3/sim_seconds.png)

### CPI
![cpi](Gem5/results3/system.cpu.cpi.png)

### L1 Data cache miss rate
![l1 data cache miss rate](Gem5/results3/system.cpu.dcache.overall_miss_rate::total.png)

### L1 instruction cache miss rate
![l1 instrtuctions miss rate](Gem5/results3/system.cpu.icache.overall_miss_rate::total.png)

### L2 cache miss rate
![l2 cache miss rate](Gem5/results3/system.l2.overall_miss_rate::total.png)


## System clock and Cpu clock;

There two entries from the stats: system.clk_domain.clock and  cpu_cluster.clk_domain.clock 
>- system.clk_domain.clock which is the top level / system clock. It's different from cpu clock and it's default is 1000 or 1Ghz. It’s the default domain that many system-level components inherit unless they override it. 
>- cpu_cluster.clk_domain.clock is cpu speed and it is the one we can affect with option --cpu-clock 

If we add a cpu core inside the cluster it will effectively have the same frequency as the others cpu (cpu domain). On the other hand if it's not added on the same cluster of cpu's it will inherit the clock from System.

### What is even perfect scaling pff.

![perfect scale](Gem5/results3/perfect_scale.png)
Here we should add the fact that a 4 time speedup in frequency doesn't really add up to 4 times less the simulation time.


![scale_cpi](Gem5/results3/scale_cpi.png)
Higher CPU frequency, each cycle is shorter, so memory stalls take more cycles to resolve. Memory hierarchy latency (especially beyond L1/L2) doesn’t shrink proportionally in time. The bottleneck now is memory-bound(accesses cache /DRAM latency or bandwidth).

| Benchmarks | seconds | cpi |dcache msrt|icache msrt|l2 msrt |instsructions| systemclock | cpuclock |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| specbzip | 0.045270 | 1.810810 | 0.014937 | 0.000077 | 0.282169 | 100000001 | 1000 | 250 |
| spechmmer | 0.029818 | 1.192726 | 0.001638 | 0.000221 | 0.077761 | 100000000 | 1000 | 250 |
| speclibm | 0.127319 | 5.092743 | 0.060972 | 0.000094 | 0.999944 | 100000000 | 1000 | 250 |
| specmcf | 0.033434 | 1.337373 | 0.002108 | 0.023609 | 0.055046 | 100000001 | 1000 | 250 |
| specsjeng | 0.399979 | 15.999166 | 0.121831 | 0.000020 | 0.999972 | 100000000 | 1000 | 250 |

## Time for trial and error

We are asked to optimize the following :
- L1 instruction cache size
- L1 instruction cache associativity
- L1 data cache size
- L1 data cache associativity
- L2 cache size
- L2 cache associativity
- Μέγεθος cache line

For this we created our own script optimal.sh ! It just runs the benchmark we selected (specsjeng) with different parameters as we given in a fairly random way in our PB12 function and writes the output in the log file run_specsjeng.log. We can access this file to create the relevant stats and data. 


We get the following graph with some randomized parameters:
![cl](Gem5/results5/cl.png)
Since the the biggest change is attributed to cache line size or block size there is little reason to show the other graphs that way.We can assess the impact of the parameters only when keeping cache line size the same.
#### You may ask why is block size so important ;
The simplest way to reduce miss rate is to increase the block size.Larger block sizes will reduce also compulsory misses. This reduction occurs
because the principle of locality has two components: temporal locality and spatial
locality. Larger blocks take advantage of spatial locality.
#### Note from author:
Before giving new data I need to stress that I only experiment with one benchmark specificaly specsjeng . What we conclude is not generally optimal variables just the ones that work on our specific benchmark. They may vary greatly in importance from one benchmark to another.  
#### New data with same optimal block size :
![significance](Gem5/results5/significance.png)

We can deduct that l2 size has the biggest significance outside of block size. It may not be shown in the graph but we achieved that difference in CPI by reducing L2 size. As we are inclined to keep CPI smaller we shouldn't reduce L2 for better performance.

L2 asscociativity also seems to be playing a moderate role in our benchmarks. Other than that we could probably argue the same about L1 dcache size. L1 icache size , L1 icache associativity and l1 dcache associativity seem pretty insignificant. 
## Cost function

How do we approach this problem. Let's normalize the values first in a range 0-1.
- $$x_{l1d} = \frac{L1Dsize}{128Kb}$$  
- $$x_{l1i} = \frac{L1Isize}{128Kb}  $$
- $$x_{l2} = \frac{L2size}{2Mb}$$
- $$x_{l1dAss} = \frac{L1DAss}{4}$$
- $$x_{l1iAss} = \frac{L1IAss}{4}$$
- $$x_{l2Ass} = \frac{L2Ass}{16}$$
- $$x_{cl} =\frac{cl}{64}$$  

An example of cost function :

$$ Cost_{performance} = x_{l1d}+x_{l1i}+x_{l1dAss}+x_{l1iAss}+x_{l2}+x_{l2Ass}+x_{cl} $$

Still not quite it should be showing this:
cache line size &uarr; &rarr; Performance &uarr;  &rarr; $Cost_{performance}$ &darr;

We have inverse analogy which can be expressed as: $$\frac{1}{x_{cl}}$$

We apply the same whenever it is needed.

$$ Cost_{performance} =  x_{l1d} + \frac{1}{x_{l1i}}  + x_{l1dAss} + x_{l1iAss} + x_{l2} + \frac{1}{x_{l2Ass}} + \frac{1}{x_{cl}} $$

### Weights
In our case we used only two values for each parameter so low setting is half the high setting. What is now asked of us is also to give the appropriate weights for each one of the costs. From our experiments we can see that some parameters give more boost in performance than others. The most obvious one being cache line size (block size) which is also not that costly .With low cost we have higher performance (it may just give some complexity but you don't require more chips to implement). We also know that L2 did have an impact altough a bad one and for a good reason.Almost every time we access L2 we miss so perhaps lowering it we also lower the miss penalty. Also lowering the dcache size positively affects the time probably for the same reasons -miss penalty-. Associativity is of moderate importance it gives more complexity to the hardware and it impacts our performance less in L1 and more in L2. The weights we will be adding are a direct correlation to the graph above. The bigger the weight we assign the bigger the importance.

$$ Cost_{performance} =  2x_{l1d} + 0.1\frac{1}{x_{l1i}}  + x_{l1dAss} + 0.2x_{l1iAss} + 10x_{l2} + 2\frac{1}{x_{l2Ass}} + 100\frac{1}{x_{cl}} $$



Altough in a theoretical context we can safely simulate what is giving better performance, we are also obliged to be mindfull of the cost of such an implementation. As engineers we want our choices to have value. L1 technology is more expenisive than L2 but block size not at all. Associativity introduces some complexity which probably can also drive the price up.
We also can't normalize in the same way the values.
Just for the size of l1 and l2 we will use the maximum size from both in order to be in equal terms. It could be like so:

$$ x_{l1d}= \frac{L1size}{L2maxsiz} = \frac{L1size}{2Mb}= \frac{x_{l1d}}{2Mb/128Kb} = \frac{x_{l1d}}{16} $$ 

Same in associativity.

Thus we have:

$$ Cost_{money} =  \frac{x_{l1d}}{16} +\frac{x_{l1i}}{16} + \frac{x_{l1dAss}}{4} + \frac{x_{l1iAss}}{4} + x_{l2} + x_{l2Ass} + x_{cl} $$

Now to add some weigths too..

$$ Cost_{money} = 20 \frac{x_{l1d}}{16} + 20\frac{x_{l1i}}{16} + 2\frac{x_{l1dAss}}{4} + 2\frac{x_{l1iAss}}{4} + 5 x_{l2} + 1 x_{l2Ass} + 0.1x_{cl} $$


To conlcude, in order to judge our investment we use the value-for-money formula which is considering both performance and price to pay. Our newly created Cost function.

$$ Cost = Cost_{money} + Cost_{performance} $$ $$ Cost = \frac{x_{l1d}}{16} +\frac{x_{l1i}}{16} + \frac{x_{l1dAss}}{4} + \frac{x_{l1iAss}}{4} + x_{l2} + x_{l2Ass} + x_{cl} + 20 \frac{x_{l1d}}{16} + $$ $$ + 20\frac{x_{l1i}}{16} + 2\frac{x_{l1dAss}}{4} + 2\frac{x_{l1iAss}}{4} + 5 x_{l2} + 1 x_{l2Ass} + 0.1x_{cl} $$

## Sources

- gem5 SimpleCPU: https://www.gem5.org/documentation/general_docs/cpu_models/SimpleCPU
- gem5 O3CPU: https://www.gem5.org/documentation/general_docs/cpu_models/O3CPU
- gem5 TraceCPU: https://www.gem5.org/documentation/general_docs/cpu_models/TraceCPU
- gem5 MinorCPU: https://www.gem5.org/documentation/general_docs/cpu_models/minor_cpu
- Computer Architecture: A Quantitative Approach, John L. Hennessy, David A. Patterson
- https://en.wikipedia.org/wiki/CPU_cache
- https://www.gem5.org/documentation/learning_gem5/part2/parameters/
- https://hazelcast.com/foundations/caching/caching/
- https://en.wikipedia.org/wiki/Cache_(computing)
