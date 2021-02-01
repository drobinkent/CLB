p4-leaf-ecmp: p4src/src/leaf.p4
	$(info *** Building P4 program for the leaf switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/leaf.json \
		--p4runtime-files p4src/Build/leaf_p4info.txt --Wdisable=unsupported \
		p4src/src/leaf.p4 -Dports=256 -DENABLE_DEBUG_TABLES -DDP_ALGO_ECMP -DECN_ENABLED
	sudo cp ./p4src/Build/leaf.json /tmp/
	sudo cp ./p4src/Build/leaf_p4info.txt /tmp/
	@echo "*** P4 program for leaf switch compiled successfully! Output files are in p4src/Build"

p4-spine-ecmp: p4src/src/spine.p4
	$(info *** Building P4 program for the spine switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/spine.json \
		--p4runtime-files p4src/Build/spine_p4info.txt --Wdisable=unsupported \
		p4src/src/spine.p4 -Dports=256  -DENABLE_DEBUG_TABLES -DDP_ALGO_ECMP -DECN_ENABLED
	sudo cp ./p4src/Build/spine.json /tmp/
	sudo cp ./p4src/Build/spine_p4info.txt /tmp/
	@echo "*** P4 program for spine switch compiled successfully! Output files are in p4src/Build"

p4-ecmp: p4-leaf-ecmp p4-spine-ecmp
	$(info *** Building P4 program with ECMP routing for the leaf and spine switch...)


p4-leaf-clb: p4src/src/leaf.p4
	$(info *** Building P4 program for the leaf switch for CLB...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/leaf.json \
		--p4runtime-files p4src/Build/leaf_p4info.txt --Wdisable=unsupported \
		p4src/src/leaf.p4 -Dports=256 -DENABLE_DEBUG_TABLES -DDP_ALGO_CLB  -DBITMASK_LENGTH=16  -DBITMASK_POSITION_INDICATOR_BITS_LENGTH=4  -DPRECISION_FACTOR=1
	sudo cp ./p4src/Build/leaf.json /tmp/
	sudo cp ./p4src/Build/leaf_p4info.txt /tmp/
	@echo "*** P4 program for leaf switch compiled successfully! Output files are in p4src/Build"

p4-spine-clb: p4src/src/spine.p4
	$(info *** Building P4 program for the spine switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/spine.json \
		--p4runtime-files p4src/Build/spine_p4info.txt --Wdisable=unsupported \
		p4src/src/spine.p4 -Dports=256  -DENABLE_DEBUG_TABLES  -DBITMASK_LENGTH=16  -DBITMASK_POSITION_INDICATOR_BITS_LENGTH=4  -DPRECISION_FACTOR=1
	sudo cp ./p4src/Build/spine.json /tmp/
	sudo cp ./p4src/Build/spine_p4info.txt /tmp/
	@echo "*** P4 program for spine switch compiled successfully! Output files are in p4src/Build"

p4-clb: p4-leaf-clb p4-spine-clb
	$(info *** Building P4 program with CLB load balancing for the leaf and spine switch...)


start_clos: MininetSimulator/clos.py
	$(info *** Starting clos topology DCN using MininetSimulator/clos.py...)
	sudo  python3 -E MininetSimulator/clos.py

start_ctrlr: Mycontroller.py
	$(info *** Starting Mycontroller...)
	rm -rf log/controller.log
	python3 Mycontroller.py


clear-logs:
	sudo rm -rf /tmp/*
	rm -rf testAndMeasurement/TEST_RESULTS/*
	rm -rf testAndMeasurement/TEST_LOG/*
	rm -rf result/*
	rm -rf log/*
	rm -rf result/*
	sudo pkill -f iperf

clear-iperf-processes:
	sudo pkill -f iperf

count-iperf-processes:
	ps -aux | grep -c "iperf"



process-high-contention-window-1400:
	python3 ResultProcessorExecutor.py testAndMeasurement/TEST_RESULTS-window-1400/ecmp/highContention testAndMeasurement/TEST_RESULTS-window-1400/P4TE/highContention ECMP P4TE /home/deba/Desktop/P4TE/ProcessedResultImages/high-contention-window-1400



process-strideSmallLarge-window-1400:
	python3 ResultProcessorExecutor.py testAndMeasurement/TEST_RESULTS-window-1400/ecmp/strideSmallLarge testAndMeasurement/TEST_RESULTS-window-1400/P4TE/strideSmallLarge ECMP P4TE /home/deba/Desktop/P4TE/ProcessedResultImages/strideSmallLarge-window-1400



process-high-contention-window-16000:
	python3 ResultProcessorExecutor.py testAndMeasurement/TEST_RESULTS_WWITH_16K_WINDOW/ecmp/highContention testAndMeasurement/TEST_RESULTS_WWITH_16K_WINDOW/P4TE/highContention ECMP P4TE /home/deba/Desktop/P4TE/ProcessedResultImages/high-contention--window-16000



process-strideSmallLarge-window-16000:
	python3 ResultProcessorExecutor.py testAndMeasurement/TEST_RESULTS_WWITH_16K_WINDOW/ecmp/strideSmallLarge testAndMeasurement/TEST_RESULTS_WWITH_16K_WINDOW/P4TE/strideSmallLarge ECMP P4TE /home/deba/Desktop/P4TE/ProcessedResultImages/strideSmallLarge-window-16000


process-l2strideSmallLarge:
	python3 ResultProcessorExecutor.py testAndMeasurement/TEST_RESULTS/ecmp/l2strideSmallLarge testAndMeasurement/TEST_RESULTS/P4TE/l2strideSmallLarge ECMP P4TE /home/deba/Desktop/CLB/ProcessedResultImages/l2strideSmallLarge


process-l2highContention:
	python3 ResultProcessorExecutor.py testAndMeasurement/TEST_RESULTS/ecmp/l2highContention testAndMeasurement/TEST_RESULTS/P4TE/l2highContention ECMP P4TE /home/deba/Desktop/CLB/ProcessedResultImages/l2highContention


process-stride-custom:
	python3 ResultProcessorExecutor.py testAndMeasurement/TEST_RESULTS/P4TE/l2strideSmallLarge-80-20/ testAndMeasurement/TEST_RESULTS/P4TE/l2strideSmallLarge Custom P4TE /home/deba/Desktop/CLB/ProcessedResultImages/custom
