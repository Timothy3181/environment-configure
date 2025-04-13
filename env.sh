#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

ABSEIL_PATH="https://github.com/abseil/abseil-cpp/releases/download/20250127.1/abseil-cpp-20250127.1.tar.gz"
GOOGLE_TEST_PATH="https://github.com/google/googletest/releases/download/v1.16.0/googletest-1.16.0.tar.gz"
CERES_PATH="https://github.com/ceres-solver/ceres-solver.git"
SOPHUS_PATH="https://github.com/strasdat/Sophus.git"
G2O_PATH="https://github.com/RainerKuemmerle/g2o.git"

TEMP_DIR="$HOME/env_temp"
INSTALL_DIR="/usr/local"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

DEPENDENCIES_EXIST=false
MAKE_ENVIRONMENT_EXIST=false

ABSEIL_EXIST=false
GOOGLE_TEST_EXIST=false
CERES_EXIST=false
SOPHUS_EXIST=false
G2O_EXIST=false

SUDO_USE=false

return_to_the_temp() {
    cd "${TEMP_DIR}"
}

deal_with_fail() {
    cd "$HOME"
    rm -rf "${TEMP_DIR}"
    exit 1
}

check_make_env() {
    echo -e "${YELLOW}Checking make environment${NC}"
    local make_packages=("build-essential" "cmake" "make" "libtool")
    for m_pkg in "${make_packages[@]}"; do
        echo -e "Finding $m_pkg"
        if apt list "$m_pkg" 2>/dev/null | grep -q "installed"; then
            echo -e "$m_pkg: ${GREEN}Found${NC}"
        else
            echo -e "$m_pkg: Missing, trying to install..."
            if apt install -y "$m_pkg"; then
                echo -e "$m_pkg: ${GREEN}Installed successfully${NC}"
            else
                echo -e "$m_pkg: ${RED}Installation failed. Please check the problem and fix it manually.${NC}"
                exit 1
            fi
        fi
    done
    MAKE_ENVIRONMENT_EXIST=true
}

check_abseil() {
    echo -e "${YELLOW}Checking Abseil-CPP${NC}"
    if [ -d "/usr/local/include/absl" ]; then
        if ls /usr/local/lib/libabsl_* &>/dev/null; then
            ABSEIL_EXIST=true
        else
            ABSEIL_EXIST=false
            return 1
        fi
    else
        ABSEIL_EXIST=false
        return 1
    fi
}

check_gtest() {
    echo -e "${YELLOW}Checking GoogleTest${NC}"
    if [ -d "/usr/local/include/gmock" ]; then
        if ls /usr/local/lib/libgmock* &>/dev/null; then
            if [ -d "/usr/local/include/gtest" ]; then
                if ls /usr/local/lib/libgtest* &>/dev/null; then
                    GOOGLE_TEST_EXIST=true
                else
                    GOOGLE_TEST_EXIST=false
                    return 1
                fi
            else
                GOOGLE_TEST_EXIST=false
                return 1
            fi
        else
            GOOGLE_TEST_EXIST=false
            return 1
        fi
    else
        GOOGLE_TEST_EXIST=false
        return 1
    fi
}

check_ceres() {
    echo -e "${YELLOW}Checking Ceres Solver${NC}"
    if [ -d "/usr/local/include/ceres" ]; then
        if ls /usr/local/lib/libceres* &>/dev/null; then
            CERES_EXIST=true
        else
            CERES_EXIST=false
            return 1
        fi
    else
        CERES_EXIST=false
        return 1
    fi
}

check_sophus() {
    echo -e "${YELLOW}Checking Sophus${NC}"
    if [ -d "/usr/local/include/sophus" ]; then
        SOPHUS_EXIST=true
    else
        SOPHUS_EXIST=false
        return 1
    fi
}

check_g2o() {
    echo -e "${YELLOW}Checking g2o${NC}"
    if [ -d "/usr/local/include/g2o" ]; then
        if ls /usr/local/lib/libg2o* &>/dev/null; then
            G2O_EXIST=true
        else
            G2O_EXIST=false
            return 1
        fi
    else
        G2O_EXIST=false
        return 1
    fi
}

check_the_installation() {
    check_dependencies
    check_make_env
    check_abseil
    check_gtest
    check_ceres
    check_sophus
    check_g2o
    if [[ $DEPENDENCIES_EXIST == true ]]; then
        echo -e "${GREEN}Dependencies Ready${NC}"
    else
        echo -e "${RED}Dependencies Error${NC}"
        exit 1
    fi
    sleep 1

    if [[ $MAKE_ENVIRONMENT_EXIST == true ]]; then
        echo -e "${GREEN}Make Environment Ready${NC}"
    else
        echo -e "${RED}Make Environment Error${NC}"
        exit 1
    fi
    sleep 1
    
    echo -e "+-----------List-----------+"

    if [[ $ABSEIL_EXIST == true ]]; then
        echo -e "|${GREEN}Libabsl Ready               ${NC}|"
    else
        echo -e "|${RED}Cannot Find Libabsl       ${NC}|"
    fi

    if [[ $GOOGLE_TEST_EXIST == true ]]; then
        echo -e "|${GREEN}Gtest Ready                 ${NC}|"
    else
        echo -e "|${RED}Cannot Find Gtest         ${NC}|"
    fi

    if [[ $CERES_EXIST == true ]]; then
        echo -e "|${GREEN}Ceres-solver Ready        ${NC}|"
    else
        echo -e "|${RED}Cannot Find Ceres-solver${NC}|"
    fi

    if [[ $SOPHUS_EXIST == true ]]; then
        echo -e "|${GREEN}Sophus Ready              ${NC}|"
    else
        echo -e "|${RED}Cannot Find Sophus      ${NC}|"
    fi

    if [[ $G2O_EXIST == true ]]; then
        echo -e "|${GREEN}G2O Ready                 ${NC}|"
    else
        echo -e "|${RED}Cannot Find G2O         ${NC}|"
    fi
    echo -e "+--------------------------+"
}

install_abseil() {
    echo -e "${YELLOW}Ready to install abseil-cpp by source${NC}"
    sleep 1
    cd "${TEMP_DIR}" || {
        echo -e "${RED}Cannot turn the ~/env_temp${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Downloading abseil-cpp${NC}"
    wget "${ABSEIL_PATH}" || {
        echo -e "${RED}Download failed${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Decompressing${NC}"
    tar -xzvf "${TEMP_DIR}/abseil-cpp-20250127.1.tar.gz" || {
        echo -e "${RED}Decompress failed${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Build and run${NC}"
    mkdir -p "${TEMP_DIR}/abseil-cpp-20250127.1/build"
    cd "${TEMP_DIR}/abseil-cpp-20250127.1/build"
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DABSL_PROPAGATE_CXX_STD=ON || {
            echo -e "${RED}Failed to install abseil-cpp${NC}"
            deal_with_fail
        }
    sleep 1
    echo -e "${YELLOW}Make install${NC}"
    make -j1 || {
        echo -e "${RED}Make failed${NC}"
        deal_with_fail
    }
    make install || {
        echo -e "${RED}Make install failed${NC}"
        deal_with_fail
    }
    echo -e "${GREEN}Installation successful${NC}"
}

install_gtest() {
    echo -e "${YELLOW}Ready to install gtest by source${NC}"
    sleep 1
    cd "${TEMP_DIR}" || {
        echo -e "${RED}Cannot turn the ~/env_temp${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Downloading ceres-solver${NC}"
    wget "${GOOGLE_TEST_PATH}" || {
        echo -e "${RED}Download failed${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Decompressing${NC}"
    tar -xzvf "${TEMP_DIR}/googletest-1.16.0.tar.gz" || {
        echo -e "${RED}Decompress failed${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Build and run${NC}"
    mkdir -p "${TEMP_DIR}/googletest-1.16.0/build"
    cd "${TEMP_DIR}/googletest-1.16.0/build"
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON || {
            echo -e "${RED}Failed to install gtest${NC}"
            deal_with_fail
        }
    sleep 1
    echo -e "${YELLOW}Make install${NC}"
    make -j1 || {
        echo -e "${RED}Make failed${NC}"
        deal_with_fail
    }
    make install || {
        echo -e "${RED}Make install failed${NC}"
        deal_with_fail
    }
    echo -e "${GREEN}Installation successful${NC}"
}

install_ceres() {
    echo -e "${YELLOW}Ready to install ceres-solver by source${NC}"
    sleep 1
    cd "${TEMP_DIR}" || {
        echo -e "${RED}Cannot turn the ~/env_temp${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Downloading ceres-solver${NC}"
    git clone "${CERES_PATH}" || {
        echo -e "${RED}Download failed${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Build and run${NC}"
    mkdir -p "${TEMP_DIR}/ceres-solver/build"
    cd "${TEMP_DIR}/ceres-solver/build"
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON || {
            echo -e "${RED}Failed to install ceres-solver${NC}"
            deal_with_fail
        }
    sleep 1
    echo -e "${YELLOW}Make install${NC}"
    make -j1 || {
        echo -e "${RED}Make failed${NC}"
        deal_with_fail
    }
    make install || {
        echo -e "${RED}Make install failed${NC}"
        deal_with_fail
    }
    echo -e "${GREEN}Installation successful${NC}"
}

install_sophus() {
    echo -e "${YELLOW}Ready to install sophus by source${NC}"
    sleep 1
    cd "${TEMP_DIR}" || {
        echo -e "${RED}Cannot turn the ~/env_temp${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Downloading sophus${NC}"
    git clone "${SOPHUS_PATH}" || {
        echo -e "${RED}Download failed${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Build and run${NC}"
    cd "${TEMP_DIR}/Sophus"
    sed -i 's/cmake_minimum_required(VERSION 3\.24)/cmake_minimum_required(VERSION 3.18)/' CMakeLists.txt
    mkdir -p "${TEMP_DIR}/Sophus/build"
    cd "${TEMP_DIR}/Sophus/build"
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON || {
            echo -e "${RED}Failed to install Sophus${NC}"
            deal_with_fail
        }
    sleep 1
    echo -e "${YELLOW}Make install${NC}"
    make -j1 || {
        echo -e "${RED}Make failed${NC}"
        deal_with_fail
    }
    make install || {
        echo -e "${RED}Make install failed${NC}"
        deal_with_fail
    }
    echo -e "${GREEN}Installation successful${NC}"
}

install_g2o() {
    echo -e "${YELLOW}Ready to install g2o by source${NC}"
    sleep 1
    cd "${TEMP_DIR}" || {
        echo -e "${RED}Cannot turn the ~/env_temp${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Downloading g2o${NC}"
    git clone "${SOPHUS_PATH}" || {
        echo -e "${RED}Download failed${NC}"
        deal_with_fail
    }
    sleep 1
    echo -e "${YELLOW}Build and run${NC}"
    mkdir -p "${TEMP_DIR}/g2o/build"
    cd "${TEMP_DIR}/g2o/build"
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON || {
            echo -e "${RED}Failed to install g2o${NC}"
            deal_with_fail
        }
    sleep 1
    echo -e "${YELLOW}Make install${NC}"
    make -j1 || {
        echo -e "${RED}Make failed${NC}"
        deal_with_fail
    }
    make install || {
        echo -e "${RED}Make install failed${NC}"
        deal_with_fail
    }
    echo -e "${GREEN}Installation successful${NC}"
}

install_whole_environment() {
    install_abseil
    install_gtest
    install_ceres
    install_sophus
    install_g2o
}

check_dependencies() {
    echo "Checking dependencies"
    local packages=("libfmt-dev" "liblapack-dev" "libsuitesparse-dev" "libcxsparse3" "libgflags-dev" "libgoogle-glog-dev" "libgtest-dev" "libceres-dev" "git")
    for pkg in "${packages[@]}"; do
        echo -e "${YELLOW}Finding $pkg${NC}"
        if apt list "$pkg" 2>/dev/null | grep -q "installed"; then
            echo -e "$pkg: ${GREEN}Found${NC}"
        else
            echo "$pkg: Missing, trying to install..."
            if apt install -y "$pkg"; then
                echo -e "$pkg: ${GREEN}Installed successfully${NC}"
            else
                echo -e "$pkg: ${RED}Installation failed. Please check the problem and fix it manually.${NC}"
                exit 1
            fi
        fi
    done
    echo -e "${GREEN}Finish dependencies checking${NC}"
    DEPENDENCIES_EXIST=true
}

sudo_check() {
    local text1=(
        "This shell script can help you check or configure your environment of rm_vision."
        "The script will check your file system so make sure you run the script by 'sudo'."
        "Checking..."
    )
    for text in "${text1[@]}"; do 
        for (( i=0; i<${#text}; i++ )); do
            printf "%s" "${text:$i:1}"
            sleep 0.04
        done
        echo
    done
    sleep 2
    if [ -n "$SUDO_USER" ]; then
        SUDO_USE=true
    else
        SUDO_USE=false
    fi
    if [[ $SUDO_USE == false ]]; then
        echo -e "${RED}Please run the script by 'sudo'${NC}"
    else
        echo -e "${GREEN}IN SUDO STATUS${NC}"
    fi
}

show_menu() {
    local texts=(
        "Select your installation choice:"
        "[1]Only install abseil-cpp"
        "[2]Only install googletest"
        "[3]Only install ceres-solver"
        "[4]Only install Sophus"
        "[5]Only install g2o"
        "[6]Install the whole environment"
        "[0]Exit"
    )
    for text in "${texts[@]}"; do
        for (( i=0; i<${#text}; i++ )); do
            printf "%s" "${text:$i:1}"
            sleep 0.04
        done
        echo
    done
}

deal_with_choice() {
    read -p "Please enter:" choice
    case $choice in
        1)
            install_abseil
            ;;
        2)
            install_gtest
            ;;
        3)
            install_ceres
            ;;
        4)
            install_sophus
            ;;
        5)
            install_g2o
            ;;
        6)
            install_whole_environment
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "${RED}Error typing.${NC}"
            sleep 0.1
            ;;
    esac
}

main() {
    sudo_check
    check_the_installation
    show_menu
    while true; do
        deal_with_choice
    done
}

echo -e "${YELLOW}Start to configure the environment${NC}"

mkdir -p "${TEMP_DIR}"

main

rm -rf "${TEMP_DIR}"
