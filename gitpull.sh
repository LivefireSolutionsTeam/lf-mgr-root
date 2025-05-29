#! /bin/sh
# version 1.3 - 29-April 2025

# the only job of this script is to do the initial git pull for the root account

# because we're running as a cron job, source the environment variables
. /root/.bashrc

# initialize the logfile
logfile='/tmp/mount.log'
> ${logfile}

cd /root || exit

proxyready=$(nmap -p 3128 proxy | grep open)
while [ $? != 0 ];do
   echo "Waiting for proxy to be ready..." >> ${logfile}
   export proxyready=$(nmap -p 3128 proxy | grep open)
   sleep 1
done

ctr=0
while true;do
   if [ "$ctr" -gt 30 ];then
      echo "FATAL could not perform git pull." >> ${logfile}
      exit  # do we exit here or just report?
   fi
   git pull origin main >> ${logfile} 2>&1
   if [ $? = 0 ];then
      > /tmp/rootgitdone
      break
   else
      export gitresult=$(grep 'could not be found' ${logfile})
      if [ $? = 0 ];then
         echo "The git project ${gitproject} does not exist." >> ${logfile}
         echo "FAIL - No GIT Project" > "$startupstatus"
         exit 1
      else
         echo "Could not complete git pull. Will try again." >> ${logfile}
      fi
  fi
  ctr=$(expr "$ctr" + 1)
  sleep 5
done

