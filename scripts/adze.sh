#!/bin/sh

### -------------------------
### ----TRACETAKE------------
### -------------------------

### Cardano-node Management Cli for NixOS ###


CETAK_PATH=$(eval echo "~$USER")

MAIN_FOLDER=adze  ### Dragons in the main folder

NODE_IP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p') # NODE_IP
MTRCS_IP="127.0.0.1" # MTRCS_IP

NODE_PORT=3010 # NODE_PORT
MTRCS_PORT=12798 # METRICS
NODES_NAME=Rhesus #NAME OF NODE 

CN_GIT_WEB="https://github.com/input-output-hk/cardano-node.git"
CNtag=1.33.0					# Git Tag

NETWORK_IDENTIFIER="--mainnet"
NWMAGIC="1097911063"
NETID_TESTNET="--testnet-magic ${NWMAGIC}"

						# MAIN VARIABLES
# -----------------------------------------------

# -----------------------------------------------
						# INITIALIZE ALL NECESSARY DIRECTORIES

        CETAK_PATH_TT=${CETAK_PATH}/${MAIN_FOLDER}
        CETAK_PATH_CNF=${CETAK_PATH_TT}/CONF
        CETAK_PATH_TMP=${CETAK_PATH_TT}/TMP_FOLDER
        CETAK_PATH_PF=${CETAK_PATH_TT}/portableFolder
        #----------------------------------------------------------------------
        NODERUNNER_STATE=${CETAK_PATH_TT}/state-node-noderunner
        NODERUNNER_DB=${NODERUNNER_STATE}/db-noderunner
        NODERUNNER_CONF=${CETAK_PATH_CNF}

						# INITIALIZE ALL NECESSARY DIRECTORIES
# -----------------------------------------------
CCLI="$CETAK_PATH_TT/cardano-cli-cetak/bin/cardano-cli" # MAIN VARIABLES CLI

# -----------------------------------------------
InitializeFolders() {           		# INITIALIZE ALL NECESSARY DIRECTORIES

        [[ -d ${CETAK_PATH_TT} ]] || mkdir -p -- ${CETAK_PATH}/${MAIN_FOLDER}
        [[ -d ${CETAK_PATH_CNF} ]] || mkdir -p -- ${CETAK_PATH_TT}/CONF
        [[ -d ${CETAK_PATH_TMP} ]] || mkdir -p -- ${CETAK_PATH_TT}/TMP_FOLDER
        #----------------------------------------------------------------------
        [[ -d ${NODERUNNER_STATE} ]] || mkdir -p -- ${CETAK_PATH_TT}/state-node-noderunner
        [[ -d ${NODERUNNER_DB} ]] || mkdir -p -- ${NODERUNNER_STATE}/db-noderunner
        [[ -d ${CETAK_PATH_PF} ]] || mkdir -p -- ${CETAK_PATH_TT}/portableFolder

}                               		# INITIALIZE ALL NECESSARY DIRECTORIES
# -----------------------------------------------

# -----------------------------------------------
cnfFileCN() {					# CONF FILES

        local cnfFileChoice=$1
        echo
        if ask " Should I Fetch ${cnfFileChoice} configuration files?" N; then # Only do something if you say Yes
        	rm -fv ${NODERUNNER_CONF}/*.json
		cd ${NODERUNNER_CONF}

		local HTTP_CONF="https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1"
        	wget ${HTTP_CONF}/${cnfFileChoice}-config.json
        	wget ${HTTP_CONF}/${cnfFileChoice}-byron-genesis.json
        	wget ${HTTP_CONF}/${cnfFileChoice}-shelley-genesis.json
        	wget ${HTTP_CONF}/${cnfFileChoice}-topology.json
        fi

}						# CONF FILES
# -----------------------------------------------

# -----------------------------------------------
metricsQueryTip() {                    		# NODE

	rm $CETAK_PATH_TMP/metrics.json
	curl -s http://$MTRCS_IP:$MTRCS_PORT/metrics > $CETAK_PATH_TMP/metrics.json | jq '.'
	if [ -f "$CETAK_PATH_TMP/metrics.json" ]; then
        	CETAK_BLOCK=$(sed -n -e 's/^.*cardano_node_metrics_blockNum_int //p' $CETAK_PATH_TMP/metrics.json)
        	CETAK_SLOT=$(sed -n -e 's/^.*cardano_node_metrics_slotNum_int //p' $CETAK_PATH_TMP/metrics.json)
        	CETAK_SLOT_EPOCH=$(sed -n -e 's/^.*cardano_node_metrics_slotInEpoch_int //p' $CETAK_PATH_TMP/metrics.json)
        	CETAK_EPOCH=$(sed -n -e 's/^.*cardano_node_metrics_epoch_int //p' $CETAK_PATH_TMP/metrics.json)
        	CETAK_PID=$(sed -n -e 's/^.*cardano_node_metrics_Sys_Pid_int //p' $CETAK_PATH_TMP/metrics.json)
        	CETAK_STATUS=$(pgrep -x cardano-node >/dev/null && echo "RUNNING" || echo "OFFLINE")
        	#CETAK_CN_VERS=$($CCLI version | grep cli)
	fi

}                                               # NODE
# -----------------------------------------------


# -----------------------------------------------
NODERUNNER() {                  		# NODERUNNER CONFIGURATION

	local NR_CHOICE=$1

	local NODERUNNER_TAIL="${NR_CHOICE}tail.log"
	local NODERUNNER_LINK="${NR_CHOICE}-node-manual"

        local LAUNCH="${CETAK_PATH_TT}/${NODERUNNER_LINK}/bin/cardano-node run"
        local CONFIG="${NODERUNNER_CONF}/${NR_CHOICE}-config.json" # CONF

	cnfFileCN ${NR_CHOICE}

        [[ -d ${NODERUNNER_STATE} ]] || mkdir -p -- ${CETAK_PATH_TT}/state-node-noderunner
        [[ -d ${NODERUNNER_DB} ]] || mkdir -p -- ${NODERUNNER_STATE}/db-noderunner

        rm ${NODERUNNER_STATE}/${NR_CHOICE}-node.socket
        rm ${CETAK_PATH_TMP}/${NODERUNNER_TAIL}

        nohup ${LAUNCH} \
                --topology ${NODERUNNER_CONF}/${NR_CHOICE}-topology.json \
                --database-path ${NODERUNNER_DB}/${NR_CHOICE}-db \
                --socket-path ${NODERUNNER_STATE}/${NR_CHOICE}-node.socket \
                --config ${CONFIG} \
                --host-addr ${NODE_IP} \
                --port ${NODE_PORT} \
                --validate-db \
                &> ${CETAK_PATH_TMP}/${NODERUNNER_TAIL} &

        echo
        echo " LAUNCH command: $LAUNCH"
        echo " CONFIG command: $CONFIG"
        echo

        exit
}                               		# NODERUNNER CONFIGURATION
# -----------------------------------------------

# -----------------------------------------------
InstallCMD() {					# Required CMD

        cmdArray=( curl jq git wget tmux htop )
        for vCmd in "${cmdArray[@]}"
        do
	if ! command -v "$vCmd" > /dev/null 2>&1
	 then
		read -p " Can't find $vCmd. Do you wish to install this program [y/n]? " yn
		case $yn in
    			[Yy]* ) nix-env -iA nixos.${vCmd};;
    			[Nn]* ) continue;;
			* ) echo " Please answer Yes[Yy] or No[Nn]. ";;
		esac
	fi
        done
}						# Required CMD
# -----------------------------------------------

# -----------------------------------------------
getCN() {					# CARDANO NODE

	rm -rf $CETAK_PATH_TT/cardano-node
	cd $CETAK_PATH_TT
	git clone --recurse-submodules $CN_GIT_WEB
	cd $CETAK_PATH_TT/cardano-node
	# git fetch --all --tags
	# git tag

	git checkout tags/${CNtag}
	git submodule update

}						# CARDANO NODE
# -----------------------------------------------

# -----------------------------------------------
NodeMaintenance() {                             # MAINTENANCE NODE

	local ENV_NODE=testnet
	ask " Attention! Do you want to Install the $ENV_NODE environement?" Y || ENV_NODE=mainnet
        if ask " Attention! This process will remove any previous $ENV_NODE installation in Folder ${MAIN_FOLDER}!" Y; then
        	pkill cardano-node -SIGINT
          	InitializeFolders
          	InstallCMD
          	getCN
	  	local NODERUNNER_LINK=$ENV_NODE-node-manual
                rm -rf ${CETAK_PATH_TT}/${NODERUNNER_LINK}
                cd ${CETAK_PATH_TT}/cardano-node
                nix-build -A cardano-node -o ${CETAK_PATH_TT}/${NODERUNNER_LINK}
		clear
        	if ask " Attention! Should I install Cardano-cli?" N; then # Only do something if you say Yes
                	nix-build -A cardano-cli -o ${CETAK_PATH_TT}/cardano-cli-cetak
        	fi
		clear
		ask "Attention! Do you want to collect garbage? Choose No if you haven't a clue." N && nix-collect-garbage -d
	fi
}						# MAINTENANCE NODE
# -----------------------------------------------

# -----------------------------------------------
NodeSearch() {                             	# SEARCH NODE

local NR_CHOICE="mainnet"
local NETID_EXP="${NETWORK_IDENTIFIER}"
if ask " Are we on *** TESTNET *** ?" Y; then NR_CHOICE="testnet" && NETID_EXP="${NETID_TESTNET}"; fi
export CARDANO_NODE_SOCKET_PATH="${NODERUNNER_STATE}/${NR_CHOICE}-node.socket"

echo " || Information Management || "
echo

DIRECTIVES=("SEARCH" "NODE UTXO" "QUIT")
PS3="Select action: "

select directives in "${DIRECTIVES[@]}"
do
    case $directives in

        "SEARCH")
                echo -n " Search for < || Payment/Stake  Address | Pool ID || > [ENTER] "
                read SEARCH_QUERY
                echo
                if [[ ${#SEARCH_QUERY} -gt 55 ]] && [[ ${#SEARCH_QUERY} -lt 110 ]]; then local TYPEOF=`expr match "$SEARCH_QUERY" '\(addr\|stake\|pool\)'`; fi
                case $TYPEOF in
                  addr) ${CCLI} query utxo --mary-era ${NETID_EXP} --address "${SEARCH_QUERY}"  ### Search Address
                        ${CCLI} address info --address "${SEARCH_QUERY}"
                  ;;
                  stake) ${CCLI} query stake-address-info --mary-era ${NETID_EXP} --address "${SEARCH_QUERY}" ;; ### Shelley stake address commands

                  pool) ${CCLI} query stake-distribution --mary-era ${NETID_EXP} | grep "$SEARCH_QUERY" ;;  ### Shelley pool commands

                  *) echo " Search Options : < Payment Address | Stake Address | Pool ID > " ;;
                esac
         break ;;

        "NODE UTXO") ${CCLI} query utxo --mary-era ${NETID_EXP} > nodeutxo.json ### Search Address
         break ;;

        "QUIT") break ;;
    esac
done
exit 0

}						# SEARCH NODE
# -----------------------------------------------

# -----------------------------------------------
MultiChoiceNode() {                             # NODE

         case $1 in
                1)
			# Default to Yes if the user presses enter without giving an answer:
			if ask " Are we tailing TESTNET?" Y; then
				tail -f ${CETAK_PATH_TMP}/testnettail.log
                                # tail -f ${CETAK_PATH_TMP}/${TNT_TAIL_FILE}
			else
                                tail -f ${CETAK_PATH_TMP}/mainnettail.log
                                # tail -f ${CETAK_PATH_TMP}/${MNT_TAIL_FILE}
			fi
                ;;
                2)
                	echo " Shutting down Node"
                	pkill cardano-node -SIGINT
			# Only do something if you say Yes
			MultiChoiceNode 3
                ;;
                3)
                        if ask " Do you want to shutdown the system?" N; then
                        sudo shutdown
                        fi
			exit
                ;;

         *)
            echo " Error $1 isn't a good choice."
            exit 1

         esac

}                                               # NODE
# -----------------------------------------------


### -----------------------------
### LAUNCH OR SHUTING NODE
### -----------------------------
fctn_activation() {	#LAUNCH OR SHUTDOWN CETAK
        echo " ### INVOKING ${NODES_NAME} OPTIONS ###"
        echo
        if [[ $1 -eq 1 ]]; then echo -n " Launch ${NODES_NAME}? [yes or no]"; else echo  -n " Shutdown ${NODES_NAME}? [yes or no]"; fi
        read yno
        case $yno in
                [yY] | [yY][Ee][Ss] )
                        if [[ $1 -eq 1 ]]; then 
                        # Default to Yes if the user presses enter without giving an answer:
                        	if ask " Are we launching on the *** TESTNET *** ?" Y; then
                                	NODERUNNER testnet #TESTNET
                        	else
					echo " You have chosen MAINNET."
					sleep 3
                                	NODERUNNER mainnet #MAINNET
                        	fi

			else 
				MultiChoiceNode 2 
			fi
                break
                ;;
                [nN] | [n|N][O|o] )

                        if [[ $1 -eq 1 ]]; then MultiChoiceNode 3 exit 1; fi   #NODE MODE
                break
                ;;
        *) echo " Invalid input"
        ;;
        esac
}

### -----------------------------

### -----------------------------
### NODE STATUS
### -----------------------------
cetak_status() {
	metricsQueryTip
        clear
        case ${CETAK_STATUS} in
        	RUNNING)
                        echo " STATUS           : $CETAK_STATUS "
                        echo " EPOCH            : $CETAK_EPOCH "
                        echo " BLOCK NUM        : $CETAK_BLOCK "
                        echo " SLOT EPOCH       : $CETAK_SLOT_EPOCH "
                        echo " SLOT             : $CETAK_SLOT "
                        echo
			if [[ $1 -eq 0 ]]; then fctn_activation $1 exit 1; fi 	#NODE MODE
			if [[ $1 -eq 2 ]]; then NodeSearch exit 0; fi 	#NODE MODE
                ;;
                OFFLINE)
                        echo " ### ---- STATUS: ${CETAK_STATUS} ---- ###"
			fctn_activation 1
                ;;
                *)
                        echo " ### ----  ERROR  ---- ###"
                ;;
        esac
}

### -------------------------

# -----------------------------------------------
ask() {						# PROMPT NODE

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
}						# PROMPT NODE
# -----------------------------------------------

# -----------------------------------------------
MenuRerun() {					# NODE
	vSKIPMENU=0
        read -p " Press [Enter] key to continue..." readEnterKey
}						# NODE
# -----------------------------------------------

vSKIPMENU=$1 # SKIP MENU OPTION

# -----------------------------------------------
while :						# MAIN NODE
do
	clear
        # display menu
        echo "Today is $(date)"
	echo "Server Name - $(hostname)"
        echo "IP - $NODE_IP"
        echo "PORT - $NODE_PORT"
	echo "-------------------------------"
	echo "     M A I N - M E N U"
	echo "-------------------------------"
	echo "1. Install Cardano"
        echo "2. Status of $NODES_NAME"
        echo "3. Default Tail"
        echo "4. Search"
        echo "6. NETWORK"
        echo "8. HTOP"
	echo "9. Exit"
        # get input from the user

	vINT='^[1-9]+$'
        if ! [[ $vSKIPMENU =~ $vINT ]] || [[ -z "$vSKIPMENU" ]] ; then
        	read -p " Enter your choice [ 1 - 9 ] " choice
        else
        	choice=$vSKIPMENU
		echo " OPTION $vSKIPMENU SELECTED"
        fi
        # make decision using case..in..esac
	case $choice in
		1)
			ask " Ready to install Cardano-node?" Y && NodeMaintenance # Only do something if you say Yes
			MenuRerun
			;;
                2)
                        ask " Status of Node designated $NODES_NAME?" Y && cetak_status 0 # Only do something if you say Yes
			MenuRerun
                        ;;
                3)
                        ask " Show default Tail?" Y && MultiChoiceNode 1 # Only do something if you say Yes
			MenuRerun
                        ;;
                4)
                        ask " Search < POOL | ADDRESS >" Y && cetak_status 2 # Only do something if you say Yes
			MenuRerun
                        ;;
                6)
                        echo
                        netstat -atun | awk '{print $5}' | cut -d: -f1 | sed -e '/^$/d' |sort | uniq -c | sort -n
                        exit
                        ;;

		8)	htop -u $(whoami)
			MenuRerun
			;;

		9)	echo " Be Seing you!"
			exit 0
			;;
		*)
			echo " Sorry: Invalid option..."
			MenuRerun
			;;
	esac

done
