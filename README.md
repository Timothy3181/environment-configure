## ⭐RM_PKA的自瞄系统环境配置脚本  
**⚡目前已经实现的功能：**  
1. 自动检查源码编译环境是否完全  
2. 自动检查各库是否已经安装  
3. 即使没有某个库也可以自由选择是否安装  
4. 一键配置OpenSSH

**⚡可以安装的库：**  
1. abseil-cpp
2. googletest
3. ceres-solver（依赖于abseil-cpp和googletest）
4. Sophus
5. g2o
6. OpenCV v4.11.0
7. ROS2 Humble(Desktop Version)

**⚡正在实现的功能：**  
1. 优化史山
2. MVViewer v2.3.1 x86的安装
3. rosdep

**⚡将要实现的功能：**  
1. 根据使用习惯和网络环境自动选择合适的下载源
2. 安装更多有关SLAM的库，比如Pangolin  
3. 更换apt源

**1.2.0**
1. 目前已经可以通过清华源安装ROS2 Humble
2. 调快了文字加载速度（🐌）

**1.1.0/1.1.1**
1. 完成OpenCV v4.11.0的安装集成
2. 一键配置OpenSSH
3. 修了点史山
