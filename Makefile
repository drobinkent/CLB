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


p4-leaf-cp-assisted-multicriteria-policy-routing-without-rate-control: p4src/src/leaf.p4
	$(info *** Building P4 program for the leaf switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/leaf.json \
		--p4runtime-files p4src/Build/leaf_p4info.txt --Wdisable=unsupported \
		p4src/src/leaf.p4 -Dports=256 -DENABLE_DEBUG_TABLES -DDP_ALGO_CP_ASSISTED_POLICY_ROUTING
	sudo cp ./p4src/Build/leaf.json /tmp/
	sudo cp ./p4src/Build/leaf_p4info.txt /tmp/
	@echo "*** P4 program for leaf switch compiled successfully! Output files are in p4src/Build"

p4-spine-cp-assisted-multicriteria-policy-routing-without-rate-control: p4src/src/spine.p4
	$(info *** Building P4 program for the spine switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/spine.json \
		--p4runtime-files p4src/Build/spine_p4info.txt --Wdisable=unsupported \
		p4src/src/spine.p4 -Dports=256  -DENABLE_DEBUG_TABLES -DDP_ALGO_CP_ASSISTED_POLICY_ROUTING
	sudo cp ./p4src/Build/spine.json /tmp/
	sudo cp ./p4src/Build/spine_p4info.txt /tmp/
	@echo "*** P4 program for spine switch compiled successfully! Output files are in p4src/Build"

p4-cp-assisted-multicriteria-policy-routing-without-rate-control: p4-leaf-cp-assisted-multicriteria-policy-routing-without-rate-control p4-spine-cp-assisted-multicriteria-policy-routing-\
	without-rate-control
	$(info *** Building P4 program with CP assisted multicriteria policy based routing -without-rate-control for the leaf and spine switch...)

p4-leaf-cp-assisted-multicriteria-policy-routing-with-path-reveirication--without-rate-control: p4src/src/leaf.p4
	$(info *** Building P4 program for the leaf switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/leaf.json \
		--p4runtime-files p4src/Build/leaf_p4info.txt --Wdisable=unsupported \
		p4src/src/leaf.p4 -Dports=256 -DENABLE_DEBUG_TABLES -DDP_ALGO_CP_ASSISTED_POLICY_ROUTING -DPATH_REVERIFICATION_ENABLED
	sudo cp ./p4src/Build/leaf.json /tmp/
	sudo cp ./p4src/Build/leaf_p4info.txt /tmp/
	@echo "*** P4 program for leaf switch compiled successfully! Output files are in p4src/Build"

p4-spine-cp-assisted-multicriteria-policy-routing-with-path-reveirication-without-rate-control: p4src/src/spine.p4
	$(info *** Building P4 program for the spine switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/spine.json \
		--p4runtime-files p4src/Build/spine_p4info.txt --Wdisable=unsupported \
		p4src/src/spine.p4 -Dports=256  -DENABLE_DEBUG_TABLES -DDP_ALGO_CP_ASSISTED_POLICY_ROUTING -DPATH_REVERIFICATION_ENABLED
	sudo cp ./p4src/Build/spine.json /tmp/
	sudo cp ./p4src/Build/spine_p4info.txt /tmp/
	@echo "*** P4 program for spine switch compiled successfully! Output files are in p4src/Build"

p4-cp-assisted-multicriteria-policy-routing-with-path-reveirication-without-rate-control: p4-leaf-cp-assisted-multicriteria-policy-routing-with-path-reveirication-without-rate-control p4-spine-cp-assisted-multicriteria-policy-routing-with-path-reveirication-without-rate-control
	$(info *** Building P4 program with CP assisted multicriteria policy based routing -with-path-reveirication but -without-rate-control for the leaf and spine switch...)



p4-leaf-cp-assisted-multicriteria-policy-routing-with-rate-control: p4src/src/leaf.p4
	$(info *** Building P4 program for the leaf switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/leaf.json \
		--p4runtime-files p4src/Build/leaf_p4info.txt --Wdisable=unsupported \
		p4src/src/leaf.p4 -Dports=256 -DENABLE_DEBUG_TABLES -DDP_ALGO_CP_ASSISTED_POLICY_ROUTING -DDP_BASED_RATE_CONTROL_ENABLED
	sudo cp ./p4src/Build/leaf.json /tmp/
	sudo cp ./p4src/Build/leaf_p4info.txt /tmp/
	@echo "*** P4 program for leaf switch compiled successfully! Output files are in p4src/Build"

p4-spine-cp-assisted-multicriteria-policy-routing-with-rate-control: p4src/src/spine.p4
	$(info *** Building P4 program for the spine switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/spine.json \
		--p4runtime-files p4src/Build/spine_p4info.txt --Wdisable=unsupported \
		p4src/src/spine.p4 -Dports=256  -DENABLE_DEBUG_TABLES -DDP_ALGO_CP_ASSISTED_POLICY_ROUTING -DDP_BASED_RATE_CONTROL_ENABLED
	sudo cp ./p4src/Build/spine.json /tmp/
	sudo cp ./p4src/Build/spine_p4info.txt /tmp/
	@echo "*** P4 program for spine switch compiled successfully! Output files are in p4src/Build"

p4-cp-assisted-multicriteria-policy-routing-with-rate-control: p4-leaf-cp-assisted-multicriteria-policy-routing-with-rate-control p4-spine-cp-assisted-multicriteria-policy-routing-with-rate-control
	$(info *** Building P4 program with CP assisted multicriteria policy based routing -with-rate-control for the leaf and spine switch...)

p4-leaf-dp-only-multicriteria-policy-routing: p4src/src/leaf.p4
	$(info *** Building P4 program for the leaf switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/leaf.json \
		--p4runtime-files p4src/Build/leaf_p4info.txt --Wdisable=unsupported \
		p4src/src/leaf.p4 -Dports=256 -DENABLE_DEBUG_TABLES -DDP_ALGO_DP_ONLY_POLICY_ROUTING
	sudo cp ./p4src/Build/leaf.json /tmp/
	sudo cp ./p4src/Build/leaf_p4info.txt /tmp/
	@echo "*** P4 program for leaf switch compiled successfully! Output files are in p4src/Build"

p4-spine-dp-only-multicriteria-policy-routing: p4src/src/spine.p4
	$(info *** Building P4 program for the spine switch...)
	@mkdir -p p4src/Build
	p4c-bm2-ss --arch v1model -o p4src/Build/spine.json \
		--p4runtime-files p4src/Build/spine_p4info.txt --Wdisable=unsupported \
		p4src/src/spine.p4 -Dports=256  -DENABLE_DEBUG_TABLES -DDP_ALGO_DP_ONLY_POLICY_ROUTING
	sudo cp ./p4src/Build/spine.json /tmp/
	sudo cp ./p4src/Build/spine_p4info.txt /tmp/
	@echo "*** P4 program for spine switch compiled successfully! Output files are in p4src/Build"

p4-dp-only-multicriteria-policy-routing: p4-leaf-dp-only-multicriteria-policy-routing p4-spine-dp-only-multicriteria-policy-routing 
	$(info *** Building P4 program with dp only multicriteria policy based routing for the leaf and spine switch...)

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
