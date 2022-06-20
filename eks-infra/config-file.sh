#!/bin/bash
echo install kubectl
cd /home/runner/
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.22.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir /home/runner/.kube/
file_name="config-custom.cfg"
if [ ! -f /home/runner/.kube/config-custom.cfg ];
then
   s3=`aws s3 ls s3://landg-terraform-state/eks/configfile/config-custom.cfg | awk '{print $4}'`
   echo "config file is available in s3 with filename=" $s3
   if [ "$s3" == "$file_name" ];
   then
      echo "pull file from s3"   
      copy_file=`aws s3 cp s3://landg-terraform-state/eks/configfile/config-custom.cfg /home/runner/.kube/`
      echo "file copied from s3" $copy_file
   else
      echo "create a folder structure and file"    
      touch /home/runner/.kube/config-custom.cfg
      chmod -R 777 /home/runner/.kube/
   fi
else
   echo "config file is present"
fi
