
sudo mkdir /usr/local/lib/python3.8/site-packages


first modification -- behavioral-model install-deps

Upper 2 are for Jfingerhuts script for ubuntu 20


bazel installation --- required for p4runtime compilation 

echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
If you want to install the testing version of Bazel, replace stable with testing.

Step 3: Install and update Bazel
sudo apt-get update && sudo apt-get install bazel
Once installed, you can upgrade to a newer version of Bazel with the following command:

sudo apt-get install --only-upgrade bazel

for p4runtime 

https://github.com/p4lang/p4runtime.git
cd p4runtime
cd proto && bazel build //...


pip3 install git+https://github.com/Yi-Tseng/p4runtime.git@pip-support
 pip3 install spec
  pip3 install IPython
pip3 install matplotlib

Add user to sudoers on sudoers file 
the permission of TEST_RESULTS should be rwxrw-rw-



http://intronetworks.cs.luc.edu/current/uhtml/mininet.html


Somehow bmv2 target er jonno age compile kore tarpore main ta compile koralagte pare.

sudo apt install iperf3
