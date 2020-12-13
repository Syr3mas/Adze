#!/bin/sh

### -------------------------
### ----TRACETAKE------------
### -------------------------
### Cardano-node Management Cli for NixOS ###


CETAK_PATH=$(eval echo "~$USER")

MAIN_FOLDER=adze

NODE_IP=127.0.0.1 # NODE_IP
NODE_PORT=3001 # NODE_PORT

CN_GIT_WEB="https://github.com/input-output-hk/cardano-node.git"
CNtag=1.24.2					# Git Tag

### -----------------------------

MNT_NODE_LINK="mainnet-node-internal"	# Name of autobuilt script link mainnet
TNT_NODE_LINK="testnet-node-internal"	# Name of autobuilt script link testnet

MNT_TAIL_FILE="cnRelayMainNet.log"
TNT_TAIL_FILE="cnRelayTestNet.log"

### -----------------------------
        mnnetConfig="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-config.json"
        mnnetByronGenesis="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-byron-genesis.json"
        mnnetShelleyGenesis="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-shelley-genesis.json"
        mnnetTopology="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-topology.json"

	ttnetConfig="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-config.json"
        ttnetByronGenesis="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-byron-genesis.json"
        ttnetShelleyGenesis="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-shelley-genesis.json"
        ttnetTopology="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-topology.json"
### -----------------------------

### -----------------------------
#INITIALIZE ALL NECESSARY DIRECTORIES

        CETAK_PATH_TT=${CETAK_PATH}/${MAIN_FOLDER}
        CETAK_PATH_CNF=${CETAK_PATH_TT}/CONF
        CETAK_PATH_SNM=${CETAK_PATH_TT}/state-node-mainnet
        CETAK_PATH_SNT=${CETAK_PATH_TT}/state-node-testnet
        CETAK_PATH_DB=${CETAK_PATH_SNM}/db-mainnet
        CETAK_PATH_TDB=${CETAK_PATH_SNM}/db-testnet
        #----------------------------------------------------------------------
        CETAK_PATH_TMP=${CETAK_PATH_TT}/TMP_FOLDER
        #----------------------------------------------------------------------
	CETAK_PATH_CNF_MNT=${CETAK_PATH_CNF}/mainnet
        CETAK_PATH_CNF_TNT=${CETAK_PATH_CNF}/testnet

#INITIALIZE ALL NECESSARY DIRECTORIES
### -----------------------------

### -----------------------------
### DIRECTORY INFORMATION
### -----------------------------

### -----------------------------
InitializeFolders() {   	#INITIALIZE ALL NECESSARY DIRECTORIES

        [[ -d ${CETAK_PATH_TT} ]] || mkdir -p -- ${CETAK_PATH}/${MAIN_FOLDER}
        [[ -d ${CETAK_PATH_CNF} ]] || mkdir -p -- ${CETAK_PATH_TT}/CONF
        [[ -d ${CETAK_PATH_SNM} ]] || mkdir -p -- ${CETAK_PATH_TT}/state-node-mainnet
        [[ -d ${CETAK_PATH_SNT} ]] || mkdir -p -- ${CETAK_PATH_TT}/state-node-testnet
        [[ -d ${CETAK_PATH_DB} ]] || mkdir -p -- ${CETAK_PATH_SNM}/db-mainnet
        [[ -d ${CETAK_PATH_TDB} ]] || mkdir -p -- ${CETAK_PATH_SNM}/db-testnet
        #----------------------------------------------------------------------
        [[ -d ${CETAK_PATH_TMP} ]] || mkdir -p -- ${CETAK_PATH_TT}/TMP_FOLDER
        #----------------------------------------------------------------------
        [[ -d ${CETAK_PATH_CNF_MNT} ]] || mkdir -p -- ${CETAK_PATH_CNF}/mainnet         # Make Folder if non existant
        [[ -d ${CETAK_PATH_CNF_TNT} ]] || mkdir -p -- ${CETAK_PATH_CNF}/testnet         # Make Folder if non existant

}				#INITIALIZE ALL NECESSARY DIRECTORIES
### -----------------------------

# -------------------------------
MAINNET() {                   	# MAINNET CONFIGURATION

local vMnTOPOLOGY="$CETAK_PATH_CNF_MNT/mainnet-topology.json" # TOPOLOGY
local vMnDATABASE="${CETAK_PATH_SNM}/db-mainnet" # DATABASE
local vMnSOCKET="${CETAK_PATH_SNM}/node.socket" # SOCKET

local LAUNCHv2="${CETAK_PATH_TT}/${MNT_NODE_LINK}/bin/cardano-node"
local vMnCONFIG="${CETAK_PATH_CNF_MNT}/mainnet-config.json" # CONF

rm ${CETAK_PATH_TMP}/${MNT_TAIL_FILE}

nohup ${LAUNCHv2} run \
        --topology ${vMnTOPOLOGY} \
        --database-path ${vMnDATABASE} \
        --socket-path ${vMnSOCKET} \
        --config ${vMnCONFIG} \
        --host-addr ${NODE_IP} \
        --port ${NODE_PORT} \
        --validate-db \
        &> ${CETAK_PATH_TMP}/${MNT_TAIL_FILE} &

}                               # MAINNET CONFIGURATION
# -------------------------------

# -------------------------------
TESTNET() {			# TESTNET CONFIGURATION

local vTnTOPOLOGY="$CETAK_PATH_CNF_TNT/testnet-topology.json" # TOPOLOGY
local vTnDATABASE="${CETAK_PATH_SNT}/db-testnet" # DATABASE
local vTnSOCKET="${CETAK_PATH_SNT}/node.socket" # SOCKET

local LAUNCHv2="${CETAK_PATH_TT}/${TNT_NODE_LINK}/bin/cardano-node"
local vTnCONFIG="${CETAK_PATH_CNF_TNT}/testnet-config.json" # CONF

rm ${CETAK_PATH_TMP}/${TNT_TAIL_FILE}

nohup ${LAUNCHv2} run \
        --topology ${vTnTOPOLOGY} \
        --database-path ${vTnDATABASE} \
        --socket-path ${vTnSOCKET} \
        --config ${vTnCONFIG} \
        --host-addr ${NODE_IP} \
        --port ${NODE_PORT} \
        --validate-db \
        &> ${CETAK_PATH_TMP}/${TNT_TAIL_FILE} &

}				# TESTNET CONFIGURATION
# -------------------------------

### -----------------------------
### -----------------------------

InstallCMD() {

        cmdArray=( git wget tmux htop )
        for vCmd in "${cmdArray[@]}"
        do
	if ! command -v "$vCmd" > /dev/null 2>&1
	then
		read -p " Can't find $vCmd. Do you wish to install this program? " yn
		case $yn in
    			[Yy]* ) nix-env -iA nixos.${vCmd};;
    			[Nn]* ) exit;;
			* ) echo " Please answer yes or no. ";;
		esac
	fi
        done
}

# -----------------------------------------------
CNBuild() {					# INSTALL

                nix-collect-garbage -d
                cd "${CETAK_PATH_TT}/cardano-node"
                nix-build -A cardano-node -o ${CETAK_PATH_TT}/${MNT_NODE_LINK}
                nix-build -A cardano-node -o ${CETAK_PATH_TT}/${TNT_NODE_LINK}
                nix-build -A cardano-cli -o ${CETAK_PATH_TT}/cardano-cli-cetak
                sleep 5
                nix-collect-garbage -d

}						# INSTALL
# -----------------------------------------------

# -----------------------------------------------
InstallMN() {					# INSTALL MAINNET

        # Default to Yes if the user presses enter without giving an answer:
        echo " USER YOUR ATTENTION IS NEEDED "
        echo

        # Only do something if you say Yes
        if ask "Should I Fetch configuration files?"; then
         rm -fv ${CETAK_PATH_CNF_MNT}/*.json
        	cd $CETAK_PATH_CNF_MNT
        	wget $mnnetConfig
        	wget $mnnetByronGenesis
        	wget $mnnetShelleyGenesis
        	wget $mnnetTopology
	fi
        ### Check if a directory does not exist ###
        if [ ! -L "${CETAK_PATH_TT}/${MNT_NODE_LINK}" ] # IF LINK DON'T EXIST
         then
		CNBuild
                exit # die with error code
        fi
}						# INSTALL MAINNET
# -----------------------------------------------

# -----------------------------------------------
InstallTN() {					# INSTALL TESTNET

	# Default to Yes if the user presses enter without giving an answer:
	echo " USER YOUR ATTENTION IS NEEDED "
	echo

	# Only do something if you say Yes
	if ask "Should I Fetch configuration files?"; then
         rm -fv ${CETAK_PATH_CNF_TNT}/*.json
                cd $CETAK_PATH_CNF_TNT
                wget $ttnetConfig
                wget $ttnetByronGenesis
                wget $ttnetShelleyGenesis
                wget $ttnetTopology
	fi

        ### Check if a directory does not exist ###

        if [ ! -L "${CETAK_PATH_TT}/${TNT_NODE_LINK}" ] # IF LINK DON'T EXIST
         then
                CNBuild
                exit # die with error code
        fi


}						# INSTALL TESTNET
# -----------------------------------------------

# -----------------------------------------------
getCN() {					# NODE

	cd $CETAK_PATH_TT
	git clone --recurse-submodules $CN_GIT_WEB
	cd $CETAK_PATH_TT/cardano-node
	git fetch --all --tags
	git tag

	git checkout tags/${CNtag}
	git submodule update

}						# NODE
# -----------------------------------------------

# -----------------------------------------------
NodeEnvnmt() {					# NODE ENVIRONEMENT

        InitializeFolders
        InstallCMD

}						# NODE ENVIRONEMENT
# -----------------------------------------------

# -----------------------------------------------
NodeMaintenance() {                             # NODE

        # Only do something if you say Yes
        if ask "Attention this will update the Node any changes will permanently be removed!"; then
	 case "$1" in
        	1)
		 pkill cardano-node -SIGINT
                 rm -rf $CETAK_PATH_TT/cardano-node
                 rm -rf ${CETAK_PATH_TT}/${MNT_NODE_LINK}
                 getCN
            	 InstallMN
            	;;

        	2)
                 pkill cardano-node -SIGINT
		 rm -rf $CETAK_PATH_TT/cardano-node
         	 rm -rf ${CETAK_PATH_TT}/${TNT_NODE_LINK}
		 getCN
            	 InstallTN
            	;;

        	9)
            	echo " This is Optional Node Maintenance "
            	;;

         *)
            echo " Error $1 is'nt a good choice."
            exit 1

	 esac
	fi
}						# NODE
# -----------------------------------------------

# -----------------------------------------------
MultiChoiceNode() {                             # NODE

         case "$1" in
                1)
			# Default to Yes if the user presses enter without giving an answer:
			if ask "Are we running Mainnet Mode?" Y; then
    				tail -f ${CETAK_PATH_TMP}/${MNT_TAIL_FILE}
			else
    				tail -f ${CETAK_PATH_TMP}/${TNT_TAIL_FILE}
			fi
                ;;
                2)
                	echo "Shutting down Node"
                	pkill cardano-node -SIGINT
			# Only do something if you say Yes
			if ask "Do you want to shutdown the system?"; then
    			sudo shutdown
			fi
                ;;

         *)
            echo " Error $1 is'nt a good choice."
            exit 1

         esac
}                                               # NODE
# -----------------------------------------------


# -----------------------------------------------
ask() {						# NODE

    local prompt default reply

    if [ "${2:-}" = "Y" ]; then
        prompt="Y/n"
        default=Y
    elif [ "${2:-}" = "N" ]; then
        prompt="y/N"
        default=N
    else
        prompt="y/n"
        default=
    fi

    while true; do

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}						# NODE
# -----------------------------------------------
while :
do
	clear
        # display menu
        echo "Today is $(date)"
	echo "Server Name - $(hostname)"
	echo "-------------------------------"
	echo "     M A I N - M E N U"
	echo "-------------------------------"
	echo "1. Install Default Command."
	echo "2. Install or Update MainNet."
	echo "3. Install or Update TestNet."
        echo "4. Optional install mode."
        echo "5. Default Tail."
        echo "6. Launch MAINnet Node."
        echo "7. Launch TESTnet Node."
        echo "8. SHUTDOWN"
	echo "9. Exit"
        # get input from the user
	read -p "Enter your choice [ 1 - 7 ] " choice
        # make decision using case..in..esac
	case $choice in
		1)
			ask "Do you want to install suggested commands?" && NodeEnvnmt # Only do something if you say Yes
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
		2)
			ask "Install/Update Mainnet?" && NodeMaintenance 1 # Only do something if you say Yes
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
		3)
			ask "Install/Update TestNet?" && NodeMaintenance 2 # Only do something if you say Yes
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
                4)
                        ask "This is the optional install mode!" && NodeMaintenance 9 # Only do something if you say Yes
                        read -p "Press [Enter] key to continue..." readEnterKey
                        ;;
                5)
                        ask "Default Tail?" && MultiChoiceNode 1 # Only do something if you say Yes
                        read -p "Press [Enter] key to continue..." readEnterKey
                        ;;
                6)
                        ask "Launch MAINnet Node?" && MAINNET # Only do something if you say Yes
			exit
                        #read -p "Press [Enter] key to continue..." readEnterKey
                        ;;
                7)
                        ask "Launch TESTnet Node?" && TESTNET # Only do something if you say Yes
                        exit
                        #read -p "Press [Enter] key to continue..." readEnterKey
                        ;;
                8)
                        ask "SHUTDOWN" && MultiChoiceNode 2 # Only do something if you say Yes
                        exit
                        #read -p "Press [Enter] key to continue..." readEnterKey
                        ;;
		9)
			echo "Be Seing you!"
			exit 0
			;;
		*)
			echo "Sorry: Invalid option..."
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
	esac

done
