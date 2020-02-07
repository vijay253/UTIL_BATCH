#!/bin/bash

echo "Starting Proton Yield Estimation"
echo "I take as arguments the Run Number and max number of events!"
RUNNUMBER=$1
MAXEVENTS=$2
if [[ $1 -eq "" ]]; then
    echo "I need a Run Number!"
    echo "Please provide a run number as input"
    exit 2
fi

if [[ $2 -eq "" ]]; then
    echo "Only Run Number entered...I'll assume -1 events!" 
    MAXEVENTS=-1 
fi

# Set path depending upon hostname. Change or add more as needed  
# Set path depending upon hostname. Change or add more as needed  
if [[ "${HOSTNAME}" = *"farm"* ]]; then  
    CentOSVer="$(cat /etc/centos-release)"
    REPLAYPATH="/group/c-kaonlt/USERS/${USER}/hallc_replay_lt"
    if [[ "${HOSTNAME}" != *"ifarm"* ]]; then
	if [[ $CentOSVer = *"7.2"* ]]; then 
	    source /site/12gev_phys/softenv.sh 2.1
	elif [[ $CentOSVer = *"7.7"* ]]; then 
	    source /site/12gev_phys/softenv.sh 2.3
	    source /apps/root/6.10.02/setroot_CUE.csh
	fi
    fi
    cd "/group/c-kaonlt/hcana/"
    source "/group/c-kaonlt/hcana/setup.sh"
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh"
elif [[ "${HOSTNAME}" = *"qcd"* ]]; then
    CentOSVer="$(cat /etc/centos-release)"
    REPLAYPATH="/group/c-kaonlt/USERS/${USER}/hallc_replay_lt"
	if [[ $CentOSVer = *"7.2"* ]]; then 
	    source /site/12gev_phys/softenv.sh 2.1
	elif [[ $CentOSVer = *"7.7"* ]]; then 
	    source /site/12gev_phys/softenv.sh 2.3
	    source /apps/root/6.10.02/setroot_CUE.csh
	fi
    cd "/group/c-kaonlt/hcana/"
    source "/group/c-kaonlt/hcana/setup.sh" 
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh" 
elif [[ "${HOSTNAME}" = *"cdaq"* ]]; then
    REPLAYPATH="/home/cdaq/hallc-online/hallc_replay_lt"
elif [[ "${HOSTNAME}" = *"phys.uregina.ca"* ]]; then
    REPLAYPATH="/home/${USER}/work/JLab/hallc_replay_lt"
fi
cd $REPLAYPATH
if [ ! -f "$REPLAYPATH/UTIL_PROTON/ROOTfilesProton/Proton_coin_replay_production_${RUNNUMBER}_${MAXEVENTS}.root" ]; then
    eval "$REPLAYPATH/hcana -l -q \"UTIL_PROTON/scripts_Replay/replay_production_coin.C($RUNNUMBER,$MAXEVENTS)\"" | tee $REPLAYPATH/UTIL_PROTON/REPORT_OUTPUT/Proton_output_coin_production_${RUNNUMBER}_${MAXEVENTS}.report
fi
sleep 5
cd "$REPLAYPATH/UTIL_PROTON/scripts_Yield/"
if [[ ("${HOSTNAME}" = *"farm"* || "${HOSTNAME}" = *"qcd"*) && "${HOSTNAME}" != *"ifarm"* ]]; then
    root -l -b -q "run_ProtonYield.C($RUNNUMBER,$MAXEVENTS,5,1)"
else
    root -l "run_ProtonYield.C($RUNNUMBER,$MAXEVENTS,5,1)"
fi
exit 0
