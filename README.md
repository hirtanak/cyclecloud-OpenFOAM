# Azure CycleCloud template for OpenFOAM

Automatic build and install scripts with Azure Cyecloud for OpenFOAM. We have a couple of usefull environemnt as below.
 - 1TB NSF in master server. execute node can be automtic mount as ~/apps
 - Support Azure IB Nodes, H16r, HC44rs, HB60rs, HB120_v2
 - OSS PBS install. job scheduler environmnet
 - Static IP Address for master node
 - Support visual windows node for pre/post use (application installation is working on progress)
 - Automatic Compile by Execute Node for each OpenFOAM version.

## Prerequisites

1. Install CycleCloud CLI

## Applications

CAE Cluster - master node and execute node
1. Fundation OpenFOAM
   1. OpenFOAM-7 (Checking)
1. ESI OpenFOAM+
   1. OpenFOAM+ v1906
   1. OpenFOAM+ v1812 (Checking)
   1. OpenFOAM+ v1806 (Checking)
   1. OpenFOAM+ v1712 (Checking)
   1. OpenFOAM+ v1706 (Checking)
 
Prepost Node - NVIDIA driver installation and paraview 5.7.0 installation

## How to install 

1. tar zxvf cyclecloud-OpenFOAM.tar.gz
1. cd cyclecloud-OpenFOAM
1. put OpenFOAM library/model on /blob directory.
1. run "cyclecloud project upload azure-storage" for uploading template to CycleCloud
1. "cyclecloud import_template -f templates/pbs_extended_nfs_starccm.txt" for register this template to your CycleCloud

<pre><code>
#!/usr/bin/bash 
#PBS -j oe
#PBS -l select=2:ncpus=3

source ~/apps/installOpenFOAM/install.sh -s '.*OpenFOAM-v1906.*Gcc4_8_5.*'

if [[ ! -d ~/apps/motorBike ]]; then
   cp -r ~/apps/OpenFOAM/OpenFOAM-v1906/tutorials/incompressible/simpleFoam/motorBike ~/apps/
fi

~/apps/motorBike/Allclean

~/apps/motorBike/Allrun
</pre></code>

## Known Issues
1. This tempate support only single administrator. So you have to use same user between superuser(initial Azure CycleCloud User) and deployment user of this template

# Azure CycleCloud用テンプレート:OpenFOAM(NFS/PBSPro)

[Azure CycleCloud](https://docs.microsoft.com/en-us/azure/cyclecloud/) はMicrosoft Azure上で簡単にCAE/HPC/Deep Learning用のクラスタ環境を構築できるソリューションです。

![Azure CycleCloudの構築・テンプレート構成](https://raw.githubusercontent.com/hirtanak/osspbsdefault/master/AzureCycleCloud-OSSPBSDefault.png "Azure CycleCloudの構築・テンプレート構成")

Azure CyceCloudのインストールに関しては、[こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/quickstart-install-cyclecloud) のドキュメントを参照してください。

OpenFOAM用のテンプレートになっています。OpenFOAMのダウンロード、コンパイルが自動的に行われます。
以下の構成、特徴を持っています。

1. OSS PBS ProジョブスケジューラをMasterノードにインストール
1. H16r, H16r_Promo, HC44rs, HB60rs, HB120rs_v2を想定したテンプレート、イメージ
	 - OpenLogic CentOS 7.6 HPC を利用 
1. Masterノードに512GB * 2 のNFSストレージサーバを搭載
	 - Executeノード（計算ノード）からNFSをマウント
1. MasterノードのIPアドレスを固定設定
	 - 一旦停止後、再度起動した場合にアクセスする先のIPアドレスが変更されない
1. クラスタ作成時に選択したOpenFOAMのバージョンがダウンロードされ、OpenMPI環境でインストールされます。
1. サンプルからモーターバイクがコピーされテスト実行可能になります。

![OSS PBS Default テンプレート構成](https://raw.githubusercontent.com/hirtanak/osspbsdefault/master/OSSPBSDefaultDiagram.png "OSS PBS Default テンプレート構成")

OSS PBS Defaultテンプレートインストール方法

前提条件: テンプレートを利用するためには、Azure CycleCloud CLIのインストールと設定が必要です。詳しくは、 [こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/install-cyclecloud-cli) の文書からインストールと展開されたAzure CycleCloudサーバのFQDNの設定が必要です。

1. テンプレート本体をダウンロード
2. 展開、ディレクトリ移動
3. cyclecloudコマンドラインからテンプレートインストール 
   - tar zxvf cyclecloud-OpenFOAM<version>.tar.gz
   - cd cyclecloud-OpenFOAM<version>
   - cyclecloud project upload azure-storage
   - cyclecloud import_template -f templates/pbs_extended_nfs_starccm.txt
4. 削除したい場合、 cyclecloud delete_template OpenFOAM コマンドで削除可能

***
Copyright Hiroshi Tanaka, hirtanak@gmail.com, @hirtanak All rights reserved.
Use of this source code is governed by MIT license that can be found in the LICENSE file.
